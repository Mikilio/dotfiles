#!/bin/bash

set -e

# Function to prompt for user confirmation
confirm() {
    read -r -p "$1 [Y/n] " response
    response=${response,,}  # convert to lowercase
    if [[ $response =~ ^(yes|y| ) || -z $response ]]; then
        true
    else
        false
    fi
}

# Function to display the disk selection menu
select_disk() {
    local disks=()
    while IFS= read -r disk; do
        disks+=("$disk")
    done < <(lsblk -rno name,type | awk '$2=="disk"{print "/dev/"$1}' | grep -v $(df --output=source / | tail -1) | sort -z)

    select disk in "${disks[@]}"; do
        if [[ -n $disk ]]; then
            echo "$disk"
            break
        else
            echo "Invalid option. Please try again."
        fi
    done
}

# Use select_disk function to choose the disk
echo "Select disk:"
DISK=$(select_disk)

if [[ -z $DISK ]]; then
    echo "No disk selected. Exiting."
    exit 1
fi

# Determine the disk type (nvme or non-nvme)
if [[ $DISK == /dev/sd* ]]; then
    NAME_DIVIDER=""
elif [[ $DISK == /dev/nvme* ]]; then
    NAME_DIVIDER="p"
else
    echo "Unknown disk type. Exiting."
    exit 1
fi

echo ""
echo "Formatting $DISK to create partitions."

echo ""
echo "Partitioning "
echo "Note: You can safely ignore parted's informational message about needing to update /etc/fstab."
sleep 0.5s

# Create a GPT partition table.
sudo parted "$DISK" -- mklabel gpt
# Add the root partition. This will fill the disk except for the end part, where the swap will live, and the space left in front (512MiB) which will be used by the boot partition.
sudo parted "$DISK" -- mkpart primary 512MiB -8GiB
# Next, add a swap partition. The size required will vary according to needs, here an 8GiB one is created.
sudo parted "$DISK" -- mkpart primary linux-swap -8GiB 100%
# Finally, the boot partition. NixOS by default uses the ESP (EFI system partition) as its /boot partition. It uses the initially reserved 512MiB at the start of the disk.
sudo parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
sudo parted "$DISK" -- set 3 boot on

echo ""
echo "Formatting "
sleep 0.5s

# For initializing Ext4 partitions: mkfs.ext4. It is recommended that you assign a unique symbolic label to the file system using the option -L label, since this makes the file system configuration independent from device changes. For example:
if ! confirm "Format root partition with ext4?"; then
    echo "Aborted. Exiting."
    exit 1
fi
mkfs.ext4 -L nixos "${DISK}${NAME_DIVIDER}1"

# For creating swap partitions: mkswap. Again, it’s recommended to assign a label to the swap partition: -L label. For example:
if ! confirm "Format swap partition?"; then
    echo "Aborted. Exiting."
    exit 1
fi
sudo mkswap -L swap "${DISK}${NAME_DIVIDER}2"

# For creating boot partitions: mkfs.fat. Again, it’s recommended to assign a label to the boot partition: -n label. For example:
if ! confirm "Format boot partition with FAT32?"; then
    echo "Aborted. Exiting."
    exit 1
fi
sudo mkfs.fat -F 32 -n boot "${DISK}${NAME_DIVIDER}3"

echo ""
echo "Installing "
sleep 0.5s
# Mount the target file system on which NixOS should be installed on /mnt, e.g.
sudo mount /dev/disk/by-label/nixos /mnt
# Mount the boot file system on /mnt/boot, e.g.
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
# If your machine has a limited amount of memory, you may want to activate swap devices now (swapon device). The installer (or rather, the build actions that it may spawn) may need quite a bit of RAM, depending on your configuration.
sudo swapon "${DISK}${NAME_DIVIDER}2"

# The command nixos-generate-config can generate an initial configuration file for you:
sudo nixos-generate-config --root /mnt

echo "More info on https://nixos.org/nixos/manual/index.html#sec-installation-installing "
echo ""
echo "You should edit /mnt/etc/nixos/configuration.nix to suit your needs, then run the nixos-install command."

