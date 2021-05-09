#!/bin/bash
# A bash script to install the basics on the admin PC
set +e

CLAP_PATH="/opt/clap"
CLAP_INSTALL=$CLAP_PATH/Install
VIRTUAL_GUEST_INSTALL=$CLAP_PATH/VirtualGuestDockerImage
UNISTALL_FILE=$CLAP_INSTALL/unistall.sh

VIRTUAL_GUEST_IMAGE_NAME="clap_virtual_guest_image"
VIRTUAL_GUEST_CONTAINER_NAME="clap_virtual_guest_container"

if [ -d "$VIRTUAL_GUEST_INSTALL" ]; then
  read -p "Voulez vous installer désinstaller poste invité virtuel (y/n) " UNINSTALLVIRTUALGUEST  
fi
if [ -f "$UNISTALL_FILE" ]; then
  read -p "Voulez vous installer désinstaller le serveur CLAP (y/n) " UNINSTALL  
fi
read -p "Voulez vous installer / re-installer le serveur CLAP (Serveur AWX dockerisé et configuré) (y/n) " CLAP
read -p "Voulez vous installer / re-installer un poste invité virtuel (Xubuntu dockerisée) (y/n) " VIRTUALGUEST

if [ "$UNINSTALLVIRTUALGUEST" = "y" ]; then
    # Ask sudo rights
    sudo ls > /dev/null
    echo "Suppression d'un éventuel poste invité virtuel antérieur..."
    sudo docker stop $VIRTUAL_GUEST_CONTAINER_NAME
    sudo docker rm $VIRTUAL_GUEST_CONTAINER_NAME
    sudo docker image rm $VIRTUAL_GUEST_IMAGE_NAME
    sudo rm -rf $VIRTUAL_GUEST_INSTALL
fi

if [ "$UNINSTALL" = "y" ]; then
    # Ask sudo rights
    sudo ls > /dev/null
    sudo $UNISTALL_FILE
fi

if [ "$CLAP" = "y" ] || [ "$VIRTUALGUEST" = "y" ]; then
    echo "Installation des dépendances..."

    # Ask sudo rights
    sudo ls > /dev/null

    # Install ansible, docker, docker-compose, python
    sudo apt-get install -y git
    sudo apt install -y software-properties-common

    sudo dpkg -s ansible &> /dev/null
    if [ $? -ne 0 ]; then
        sudo apt-add-repository --yes --update ppa:ansible/ansible
        sudo apt-get install -y ansible
    fi

    # Update the installation directory
    sudo rm -rf $CLAP_INSTALL
    sudo rmkdir $CLAP_PATH
    sudo git clone -b main https://github.com/paul-p/CLAP.git $CLAP_INSTALL
fi

if [ "$CLAP" = "y" ]; then
    sudo ls > /dev/null
    echo "Installation du serveur CLAP..."
    sudo ansible-playbook -K $CLAP_INSTALL/ansiblePlaybooks/00-Init_Administrator.yml
    # Start the browser on the AWX URL
    echo "The serveur CLAP est accessible à l'adresse http://127.0.0.1:8081"
    open http://127.0.0.1:8081  > /dev/null
fi

if [ "$VIRTUALGUEST" = "y" ]; then
    sudo ls > /dev/null
    read -p "Entrez le login de l'utilisateur sur le poste invité virtuel " GUEST_USERNAME  
    read -p "Entrez le mot de passe de l'utilisateur sur le poste invité virtuel   " GUEST_PASSWORD  
    set GUEST_USERNAME=$GUEST_USERNAME
    set GUEST_PASSWORD=$GUEST_PASSWORD

    echo "Suppression d'un éventuel poste invité virtuel antérieur..."
    sudo docker stop $VIRTUAL_GUEST_CONTAINER_NAME
    sudo docker rm $VIRTUAL_GUEST_CONTAINER_NAME
    sudo docker image rm $VIRTUAL_GUEST_IMAGE_NAME

    echo "Installation du poste invité virtuel ..."
    sudo ansible-playbook -K $CLAP_INSTALL/ansiblePlaybooks/00-Virtual_Guests.yml
    unset GUEST_USERNAME
    unset GUEST_PASSWORD
    echo "Le poste invité virtuel est maintenant installé et expose un port SSH sur cette adresse: $(docker inspect $VIRTUAL_GUEST_CONTAINER_NAME --format '{{.NetworkSettings.Networks.bridge.IPAddress}}'):22"
fi
