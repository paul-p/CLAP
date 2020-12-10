#!/bin/bash
# A bash script to install the basics on the admin PC

# Install ansible, docker, docker-compose, python
sudo apt update
sudo apt install -y software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install -y ansible

# Run the AWX server
ansible-playbook ansiblePlaybooks/Init_Administrator.yml