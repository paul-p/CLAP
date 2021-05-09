#!/bin/bash
# A bash script to install the basics on the admin PC

CLAP_PATH="/opt/clap"
CLAP_INSTALL=$CLAP_PATH/Install
VIRTUAL_GUEST_INSTALL=$CLAP_PATH/VirtualGuestDockerImage
UNISTALLFILE=$CLAP_INSTALL/unistall.sh

if [ -f "$UNISTALLFILE" ]; then
  read -p "Voulez vous installer désinstaller le serveur CLAP (y/n) " UNINSTALL  
fi
read -p "Voulez vous installer / re-installer le serveur CLAP (Serveur AWX dockerisé et configuré) (y/n) " CLAP
read -p "Voulez vous installer un poste invité virtuel (Xubuntu dockerisée) (y/n) " VIRTUALGUEST

if [ "$UNINSTALL" = "y" ]; then
    # Ask sudo rights
    sudo -A ls&
    sudo $UNISTALLFILE
fi

if [ "$CLAP" = "y" ] || [ "$VIRTUALGUEST" = "y" ]; then
    echo "Installation des dépendances..."

    # Ask sudo rights
    sudo -A ls&

    # Install ansible, docker, docker-compose, python
    sudo apt-get install -y git
    sudo apt install -y software-properties-common

    dpkg -s ansible &> /dev/null
    if [ $? -ne 0 ]; then
        sudo apt-add-repository --yes --update ppa:ansible/ansible
        sudo apt-get install -y ansible
    fi

    # Update the installation directory
    rm -rf $CLAP_INSTALL
    mkdir $CLAP_PATH
    git clone -b main https://github.com/paul-p/CLAP.git $CLAP_INSTALL
fi

if [ "$CLAP" = "y" ]; then
    echo "Installation du serveur CLAP..."
    ansible-playbook -K $CLAP_INSTALL/ansiblePlaybooks/00-Init_Administrator.yml
    # Start the browser on the AWX URL
    echo "The serveur CLAP est accessible à l'adresse http://127.0.0.1:8081"
    open http://127.0.0.1:8081&
fi

if [ "$VIRTUALGUEST" = "y" ]; then
    read -p "Entrez le login de l'utilisateur sur le poste invité virtuel " GUEST_USERNAME  
    read -p "Entrez le mot de passe de l'utilisateur sur le poste invité virtuel   " GUEST_PASSWORD  
    set GUEST_USERNAME=$GUEST_USERNAME
    set GUEST_PASSWORD=$GUEST_PASSWORD
    echo "Installation du poste invité virtuel ..."
    ansible-playbook -K $CLAP_INSTALL/ansiblePlaybooks/00-Virtual_Guests.yml
    unset GUEST_USERNAME
    unset GUEST_PASSWORD
fi
