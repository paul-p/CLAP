#!/bin/bash

# Doc of Docker in Docker: https://devopscube.com/run-docker-in-docker/
# Doc of Custom ISO with Docker: https://slai.github.io/posts/customising-ubuntu-live-isos-with-docker/

# Select the right image type
question='Choisissez le type de poste: '
archs=("Postes Invités" "Poste Administrateur")
select arch in "${archs[@]}"; do
    case $arch in
        "Postes Invités")
            DOCKER_FILE_PATH='/data/Dockerfile_guest'
            echo "Génération de l'image des postes invités"
            break
            ;;
        "Poste Administrateur")
            DOCKER_FILE_PATH='/data/Dockerfile_admin'
            echo "Génération de l'image du poste d'administration"
	        break
            ;;
	"Quit")
	    echo "Fin du programme"
	    exit
	    ;;
        *) echo "Option invalide $REPLY";;
    esac
done

# Select the right architecture
question='Choisissez votre architecture: '
archs=("64 bits / amd64" "32 bits / i386")
select arch in "${archs[@]}"; do
    case $arch in
        "64 bits / amd64")
            UBUNTU_ISO_PATH='/data/downloads/ubuntu-18.04.5-desktop-amd64.iso'
            echo "Selection de l'architecture 64 bits avec Ubuntu. Téléchargement en cours..."
            wget --directory-prefix ./data/downloads -c "https://releases.ubuntu.com/18.04/ubuntu-18.04.5-desktop-amd64.iso"
            break
            ;;
        "32 bits / i386")
            UBUNTU_ISO_PATH='/data/downloads/xubuntu-18.04.5-desktop-i386.iso'
            echo "Selection de l'architecture 32 bits avec Xubuntu. Téléchargement en cours..."
            wget --directory-prefix ./data/downloads -c "http://cdimage.ubuntu.com/xubuntu/releases/18.04/release/xubuntu-18.04.5-desktop-i386.iso"
	        break
            ;;
	"Quit")
	    echo "Fin du programme"
	    exit
	    ;;
        *) echo "Option invalide $REPLY";;
    esac
done


# Build a docker image with dependencies
sudo docker build --rm -t isobuilder .

# Call docker by sharing the docker.sock to make it able to run a docker in docker (https://devopscube.com/run-docker-in-docker/)
sudo docker run -v /var/run/docker.sock:/var/run/docker.sock \
                 -v `pwd`/data:/data \
                 -e UBUNTU_ISO_PATH=$UBUNTU_ISO_PATH\
                 -e DOCKER_FILE_PATH=$DOCKER_FILE_PATH\
                 -e BUILD_DIRECTORY='/data/build'\
                 -e TARGET_DIRECTORY='/data/target'\
                 -ti --rm isobuilder /data/isoBuilder.sh 