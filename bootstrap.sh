#!/bin/bash
# A bash script to install the basics on the admin PC

# Install ansible, docker, docker-compose, python
# sudo apt update
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible

# Create group docker and add user to it
sudo groupadd docker
userId=`whoami`
sudo usermod -a -G docker $userId
CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
newgrp docker << FOO
# Run the AWX server
ansible-playbook -K $CURRENT_PATH/ansiblePlaybooks/Init_Administrator.yml
FOO