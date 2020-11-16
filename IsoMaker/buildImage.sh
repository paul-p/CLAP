#!/bin/bash

# Doc of Docker in Docker: https://devopscube.com/run-docker-in-docker/
# Doc of Custom ISO with Docker: https://slai.github.io/posts/customising-ubuntu-live-isos-with-docker/

echo '# Script starts at:' `date`

# Ask for root rights
sudo ls>/dev/null

# Init directories
SHARED_DIRECTORY='/data'
BUILD_DIRECTORY=$SHARED_DIRECTORY/build
ISO_DATA=$BUILD_DIRECTORY/isoData
TARGET_DIRECTORY=$SHARED_DIRECTORY/target
NEW_ISO_DATA=$BUILD_DIRECTORY/newIsoData
DOWNLOAD_DIRECTORY='/data/downloads'


ISO_64_PATH="http://cdimage.ubuntu.com/xubuntu/releases/18.04.5/release/"
ISO_64_NAME="xubuntu-18.04.5-desktop-amd64.iso"
ISO_64_URL=$ISO_64_PATH$ISO_64_NAME
ISO_32_PATH="http://cdimage.ubuntu.com/xubuntu/releases/18.04.5/release/"
ISO_32_NAME="xubuntu-18.04.5-desktop-i386.iso"
ISO_32_URL=$ISO_32_PATH$ISO_32_NAME

# Clean
rm -rf .$BUILD_DIRECTORY

# Create
mkdir .$BUILD_DIRECTORY
mkdir .$ISO_DATA
mkdir .$TARGET_DIRECTORY

# Select the right image type
echo "Choisissez le type de poste: \n"
archs=("Postes Invités" "Poste Administrateur")
select arch in "${archs[@]}"; do
    case $arch in
        "Postes Invités")
            DOCKER_FILE_PATH='/data/Dockerfile_guest'
            TARGET_NAME='ClaviersPartages_Guest'
            echo "Génération de l'image des postes invités"
            break
            ;;
        "Poste Administrateur")
            DOCKER_FILE_PATH='/data/Dockerfile_admin'
            TARGET_NAME='ClaviersPartages_Admin'
            echo "Génération de l'image du poste d'administration"
	        break
            ;;
	"Quit")
	    echo "Fin du programme \n"
	    exit
	    ;;
        *) echo "Option invalide $REPLY";;
    esac
done

# Select the right architecture
echo "Choisissez votre architecture: \n"
archs=("64 bits / amd64" "32 bits / i386")
select arch in "${archs[@]}"; do
    case $arch in
        "64 bits / amd64")
            ARCH=64
            UBUNTU_ISO_PATH=$DOWNLOAD_DIRECTORY/$ISO_64_NAME
            echo "Selection de l'architecture 64 bits avec Ubuntu. Téléchargement en cours..."
            wget --directory-prefix ./data/downloads -c $ISO_64_URL
            break
            ;;
        "32 bits / i386")
            ARCH=32
            UBUNTU_ISO_PATH=$DOWNLOAD_DIRECTORY/$ISO_32_NAME
            echo "Selection de l'architecture 32 bits avec Xubuntu. Téléchargement en cours..."
            wget --directory-prefix ./data/downloads -c $ISO_32_URL
	        break
            ;;
	"Quit")
	    echo "Fin du programme"
	    exit
	    ;;
        *) echo "Option invalide $REPLY";;
    esac
done

# Add date to the target name
TARGET_NAME=$TARGET_NAME-$ARCH-bits-`date "+%m.%d.%y-%Hh%M"`.iso

# Mount ISO
echo '# mount ISO'
sudo mount -o loop .$UBUNTU_ISO_PATH .$ISO_DATA

# Copy ISO data
echo '# copy files from iso'
rm -rf .$NEW_ISO_DATA
mkdir .$NEW_ISO_DATA
cp -aR .$ISO_DATA/* .$NEW_ISO_DATA
sudo chmod +w -R .$NEW_ISO_DATA

# Umount ISO
echo '# umount ISO'
sudo umount .$ISO_DATA

# Build a docker image with dependencies
sudo docker build --rm -t isobuilder .

# Call the script in docker
sudo docker run -u=$(id -u) -v `pwd`$SHARED_DIRECTORY:$SHARED_DIRECTORY \
                -e ISO_DATA=$ISO_DATA\
                -e BUILD_DIRECTORY=$BUILD_DIRECTORY\
                -e TARGET_DIRECTORY=$TARGET_DIRECTORY\
                -e TARGET_NAME=$TARGET_NAME\
                -e ARCH=$ARCH\
                -e NEW_ISO_DATA=$NEW_ISO_DATA\
                -ti --rm isobuilder /data/isoBuilder.sh 

echo '# Script completes at:' `date`
exit