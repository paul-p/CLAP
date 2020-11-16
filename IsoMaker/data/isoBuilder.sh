#!/bin/bash

# Script inspired from http://www.tuxfixer.com/mount-modify-edit-repack-create-uefi-iso-including-kickstart-file/

###############################################
# Extract Image
##############################################

cd $BUILD_DIRECTORY
echo '# PWD:' `pwd`

##############################################
# Add kickstart and modify
##############################################

echo '# Customize image'
#mkdir $NEW_ISO_DATA/home/paul2

##############################################
# Repacking the ISO Image
##############################################

# Build a new grub on 32 bits images
if [ $ARCH -eq "32" ]; then
    grub-mkimage --verbose --output $NEW_ISO_DATA'/boot/grub/efi.img' -p "/boot/grub/" --format 'i386-pc' --compression 'auto'  --config $NEW_ISO_DATA'/boot/grub/loopback.cfg' 'ext2' 'part_msdos' 'biosdisk' 'tar' 'memdisk' 'echo' 'keylayouts' 'at_keyboard' 'font' 'gfxterm' 'all_video' 'terminal' 'png' 'jpeg' 'gfxterm_background' 'reboot' 'cat' 'help' 'minicmd' 'videoinfo' 'linux'
fi

echo '# Build iso'
mkisofs -o $TARGET_DIRECTORY/$TARGET_NAME -b isolinux/isolinux.bin -J -R -l -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -graft-points -V "clavierspartages" $NEW_ISO_DATA

echo '# Let the iso work with 2 filesystem'
isohybrid --uefi $TARGET_DIRECTORY/$TARGET_NAME

exit


