#!/usr/bin/env bash
set -u

VAGRANT_USER=$(id -nu 1000)
VAGRANT_USER_HOME=$(getent passwd $VAGRANT_USER | cut -d: -f6)
MOUNTPOINT=/nfs-data

if mount | grep $MOUNTPOINT; then
    echo "$MOUNTPOINT already mounted"
else
    # Create partition
    (
    #echo o # Create a new empty DOS partition table
    echo n # Add a new partition
    #echo p # Primary partition
    echo 4  # Partition number
    echo   # First sector (Accept default: 1)
    echo   # Last sector (Accept default: varies)
    echo w # Write changes
    ) | sudo fdisk /dev/sda

    # Create Filesystem
    mkfs.ext4 /dev/sda4

    # Mount Filesystem
    sudo -u $VAGRANT_USER sh -c "mkdir -p $MOUNTPOINT"
    BLKID=$(blkid | grep /dev/sda4 | awk -F '"' '{ print $2}')
    echo "UUID=$BLKID  $MOUNTPOINT       ext4    defaults      0       0" >> /etc/fstab
    mount -a

    # Fix Permission
    chown $VAGRANT_USER:$VAGRANT_USER $MOUNTPOINT
fi