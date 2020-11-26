FROM ubuntu:20.04

##############################################
# Install deps
##############################################

# Install depencies to build iso: mkisofs & isohybrid
RUN apt-get update \
    && apt-get install -y mkisofs syslinux-utils grub2-common mtools xorriso grub-pc-bin grub-efi-amd64-bin