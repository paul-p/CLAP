#!/bin/bash

# Script inspired from https://slai.github.io/posts/customising-ubuntu-live-isos-with-docker/

###############################################
# Extract Image
##############################################

echo '# Script starts at:' `date`
mkdir $TARGET_DIRECTORY
mkdir $BUILD_DIRECTORY
rm -rf $BUILD_DIRECTORY/*
rm -rf $TARGET_DIRECTORY/*
cd $BUILD_DIRECTORY
cp $DOCKER_FILE_PATH ./Dockerfile
echo '# PWD:' `pwd`


echo '# extract the squashfs image from the ISO'
7z e -o. "$UBUNTU_ISO_PATH" casper/filesystem.squashfs

echo '# import that squashfs image into Docker images lists (opération longue)'
sqfs2tar filesystem.squashfs | docker import - "ubuntulive:base"


#echo '# exclude the squashfs image and ISO from your build context to save time'
#echo "**/*.squashfs" >> .dockerignore
#echo "**/*.iso" >> .dockerignore

##############################################
# Modify and build
##############################################

echo '# Build the customised image in a second container'
docker build -t ubuntulive:image .

##############################################
# Repacking the squashfs image
##############################################

echo '# run an instance of the Docker image'
CONTAINER_ID=$(docker run -d ubuntulive:image /usr/bin/tail -f /dev/null)
echo "#delete the auto-created .dockerenv marker file so it doesn't end up in the squashfs image"
docker exec "${CONTAINER_ID}" rm /.dockerenv
echo '#extract the Docker image contents to a tarball'
docker cp "${CONTAINER_ID}:/" - > newfilesystem.tar
echo '#get the package listing for installation from ISO'
docker exec "${CONTAINER_ID}" dpkg-query -W --showformat='${Package} ${Version}\n' > newfilesystem.manifest
echo '#kill the container instance of the Docker image'
docker rm -f "${CONTAINER_ID}"
echo '#convert the image tarball into a squashfs image (opération longue)'
tar2sqfs --quiet newfilesystem.squashfs < newfilesystem.tar

##############################################
# Repacking the ISO Image
##############################################
echo '#create a directory to build the ISO from'
mkdir iso

echo '#extract the contents of the ISO to the directory, except the original squashfs image'
echo '#UBUNTU_ISO_PATH=path to the Ubuntu live ISO downloaded earlier'
7z x '-xr!filesystem.squashfs' -oiso "$UBUNTU_ISO_PATH"

echo '#copy our custom squashfs image and manifest into place'
cp newfilesystem.squashfs iso/casper/filesystem.squashfs
stat --printf="%s"  iso/casper/filesystem.squashfs >  iso/casper/filesystem.size
cp newfilesystem.manifest  iso/casper/filesystem.manifest

echo '#update state files'
(cd iso; find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt)

echo '#remove obsolete files'
rm iso/casper/filesystem.squashfs.gpg

echo '#build the ISO image'
# Warning ! The grub-pc-bin package has to be installed !
grub-mkrescue -v -o $TARGET_DIRECTORY/ClaviersPartages.iso $BUILD_DIRECTORY/iso/ -- -volid clavierspartages

echo '# Script completes at:' `date`
exit


