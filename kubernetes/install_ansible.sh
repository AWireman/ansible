#!/bin/bash
#set -x
install () {
	echo "installing ansible...";
	sudo yum install -y epel-release >> /dev/null 2>&1;
	sudo yum install -y ansible >> /dev/null 2>&1;
}

addHostname () {
	if [[ $hostname =~ '.' ]]; then host=$(echo $hostname | cut -d '.' -f 1);
	else host=$(echo $hostname); fi
	hosts=$(echo $ip $hostname $host)
	echo $hosts | sudo tee -a /etc/hosts >> /dev/null
	echo $hostname | sudo tee /etc/hostname >> /dev/null
	echo "[master]" | sudo tee /etc/ansible/hosts >> /dev/null
	echo $ip | sudo tee -a /etc/ansible/hosts >> /dev/null
	echo "[minions]" | sudo tee -a /etc/ansible/hosts >> /dev/null
	mkdir -p ~/.ssh
	touch ~/.ssh/known_hosts
	ssh-keyscan -H $ip >> ~/.ssh/known_hosts
}

connectSSH () {
if [[ $hostname =~ '.' ]]; then host=$(echo $hostname | cut -d '.' -f 1); else host=$(echo $hostname); fi
hosts=$(echo $ip $hostname $host) >> /dev/null
echo $ip | sudo tee -a /etc/ansible/hosts >> /dev/null
ssh-keyscan -H $ip >> ~/.ssh/known_hosts
echo "adding unique hostname on remote host..."
sshpass -p $pass ssh -tt "root@$ip" "echo $hosts | sudo tee -a /etc/hosts; echo $host | sudo tee /etc/hostname; reboot"
}

userInput() {
	#Create Hostname for Kube Master
	echo "adding unique hostnames for kubernetes..."
	read -p "enter the ip for kube master: " ip
	read -p "enter the hostname for kube master: " hostname
	addHostname;

	#Create Hostnames for Kube Minions
	read -p "add a minion node? (y or n): " moreNodes
	while echo $moreNodes | grep -iqF y;
	do
		read -p "enter the ip for the kube minion: " ip
		read -p "enter the hostname for the kube minion: " hostname
		read -sp "enter the root password for the kube minion: " pass
		echo ""
		connectSSH;
		read -p "add another minion node? (y or n): " moreNodes
	done
	echo "rebooting to apply changes..."
	sudo reboot;

}

install;
userInput;
