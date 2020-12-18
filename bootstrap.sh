#!/bin/bash
# A bash script to install the basics on the admin PC

# Install ansible, docker, docker-compose, python
sudo apt update
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible

# Create group docker and add user to it
 if grep -q docker /etc/group
    then
         echo "group docker already exists"
    else
         sudo groupadd docker
    fi
export userId=`whoami` && sudo usermod -a -G docker2 $userId && newgrp docker2

# Run the AWX server
ansible-playbook -K ansiblePlaybooks/Init_Administrator.yml
