#!/bin/bash

install () {
	#sudo yum install -y epel-release;
	#sudo yum install -y ansible;
	read -p 'ip: ' ip;
	#echo '[master]' | sudo tee -a /etc/ansible/hosts;
	echo $ip | sudo tee -a /etc/ansible/hosts;
}

install;
