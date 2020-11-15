FROM ubuntu:20.04

##############################################
# Install deps
##############################################

# Install depencies to build iso
# We need to install grub-pc-bin to make grub-mkrescue able to install grub
RUN apt-get update \
    && apt-get install -y p7zip-full grub2-common mtools xorriso squashfs-tools-ng grub-pc-bin

# Install docker
RUN apt-get install -y docker.io

# Install the tool isohybrid
# apt install syslinux-utils
