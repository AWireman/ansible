#!/bin/bash

#Vars
hostname=""
ipAddress=""
hoststring=""
confirm=""
cont=""
ansiblestring="### Ansible Hosts ###"

#Install Ansible on Ubuntu Master
installAnsible () {
	echo "Installing Ansible...";
	sudo apt update;
	sudo apt install -y software-properties-common;
	sudo apt-add-repository --yes --update ppa:ansible/ansible;
	sudo apt install -y ansible;
}

#Add Servers to Hosts File and Known-Hosts
addHostname () {
	if [ -z "$(grep "Ansible" /etc/hosts)" ]; then 
		echo "" | sudo tee -a /etc/hosts >> /dev/null;
		echo $ansiblestring | sudo tee -a /etc/hosts >> /dev/null;
	fi
	if [ -z "$(grep $ipAddress /etc/hosts)" ]; then
		echo  $hoststring | sudo tee -a /etc/hosts >> /dev/null;
		ssh-keyscan -H $ipAddress >> ~/.ssh/known_hosts;
		#TODO add to servers file, add to ansible config
	fi
}

populateVault () {
	echo ""
	#TODO create vault, add to ansible config, populate
}

#Get User Input
getInfo () {
	echo " "
	read -p "Enter Desired Hostname: " hostname
	read -p "Enter IP Address: " ipAddress
	hoststring="${hostname} ${ipAddress}"

	#confirm with user
	echo " "
	echo "Hostname: $hostname"
	echo "IP Address: $ipAddress"
	read -p "Please Confirm Above (y or n): " confirm
	if [[ ${confirm,,} =~ "y" ]]; then
		addHostname;
		
		#add more hosts?
		echo " ";
		read -p "Add Another Host? (y or n): " cont
		if [[ ${cont,,} =~ "y" ]]; then getInfo;
		else
			echo "Please Verify Host(s) are Added to /etc/hosts and Reboot this Machine";
		fi
	else 
		echo "aborted";
	fi
}

installAnsible;
getInfo;
