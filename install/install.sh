addHostname () {
	if [ -z "$(grep ansible /etc/hosts)" ]; then echo "" | sudo tee -a /etc/hosts; echo $ansiblestring | sudo tee -a /etc/hosts; fi
	if [ -z "$(grep $ipAddress /etc/hosts)" ]; then echo  $hoststring | sudo tee -a /etc/hosts; fi
}

read -p "Enter Desired Hostname: " hostname
read -p "Enter IP Address: " ipAddress
ansiblestring="### Ansible Hosts ###"
hoststring="${hostname} ${ipAddress}"
echo "Hostname: $hostname"
echo "IP Address: $ipAddress"
read -p "Please Confirm Above (y or n): " confirm
if [[ ${confirm,,} =~ "y" ]]; then addHostname;
else echo "aborted"; fi
