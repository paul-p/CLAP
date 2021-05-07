#!/bin/bash
# A bash script to install the basics on the admin PC

# Install ansible, docker, docker-compose, python
# sudo apt update
sudo apt-get install -y git
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible

CLAP_PATH="/opt/clap"
CLAP_INSTALL=$CLAP_PATH/INSTALL
rm -rf $CLAP_INSTALL
mkdir $CLAP_PATH

git clone -b main https://github.com/paul-p/CLAP.git $CLAP_INSTALL
# Create group docker and add user to it
#sudo groupadd docker
#userId=`whoami`
#sudo usermod -a -G docker $userId

# Run the AWX server
#CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ansible-playbook -K $CLAP_INSTALL/ansiblePlaybooks/00-Init_Administrator.yml
