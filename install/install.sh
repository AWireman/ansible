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
	printf "\n### Running Install Ansible ###\n"
	echo "Updating Apt Packages...";
	sudo apt update > /dev/null 2>&1;
	echo "Installing Software Properties Common...";
	sudo apt install -y software-properties-common > /dev/null 2>&1;
	echo "Adding Ansible Apt Repository...";
	sudo apt-add-repository --yes --update ppa:ansible/ansible > /dev/null 2>&1;
	echo "Installing Ansible...";
	sudo apt install -y ansible > /dev/null 2>&1;
}

#Add Servers to Hosts File and Known-Hosts
addHostname () {
	if [ -z "$(grep "Ansible" /etc/hosts)" ]; then 
		echo "" | sudo tee -a /etc/hosts >> /dev/null;
		echo $ansiblestring | sudo tee -a /etc/hosts >> /dev/null;
	fi
	if [ -z "$(grep $ipAddress /etc/hosts)" ]; then
		printf  "%s\t%s\n" $ipAddress $hostname | sudo tee -a /etc/hosts >> /dev/null;
		ssh-keyscan -H $hostname >> ~/.ssh/known_hosts;
		#TODO add to servers file, add to ansible config
	fi
}

populateVault () {
	printf "\n### Create Ansible Vault ###\n"
	read -p "Please enter the Ansible User Name: " auser
	read -p "Please enter the Ansible User Password: " apass
	$auser >> servers
	$apass >> servers
	echo "test" > .vaultkeyfile.txt
	chmod 600 .vaultkeyfile.txt
	ansible-vault create servers --ask-vault-pass;

	#TODO create vault, add to ansible config, populate
}

hostnameConfig () {
	read -p "Enter Desired Hostname: " hostname
	read -p "Enter IP Address: " ipAddress
	
	#confirm
	printf "\nHostname: %s\n" $hostname
	printf "IP Address: %s\n" $ipAddress
	read -p "Please Confirm Above (y or n): " confirm
	if [[ ${confirm,,} =~ "y" ]]; then
		addHostname;

		#add more hosts?
		echo " ";
		read -p "Add another Host? (y or n): " cont
		if [[ ${cont,,} =~ "y" ]]; then hostnameConfig;
		else
			echo "Please Verify Host(s) are Added to /etc/hosts and Reboot this Machine";
		fi
	else
		echo "aborted";
	fi
}

#Get User Input
getInfo () {
	#install ansible?
	read -p "Would you like to install Ansible? (y or n): " ans
	if [[ ${ans,,} =~ "y" ]]; then installAnsible; fi

	#add vault?
	read -p "Would you like to create an Ansible Vault? (y or n): " vau
	if [[ ${vau,,} =~ "y" ]]; then populateVault; fi
	
	#config hosts?
	read -p "Would you like to add hosts? (y or n): " hos
	if [[ ${hos,,} =~ "y" ]]; then
		printf "\n### Starting Hostname Config ###\n"
		hostnameConfig;
	fi
}

getInfo;
