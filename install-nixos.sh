#!/bin/bash

set -e

# Create the nixbld group and user (Necessary for Non-Nixos distributions)
sudo groupadd -g 30000 nixbld
sudo useradd -u 30000 -g nixbld -G nixbld nixbld
#normal installation
sudo PATH="$PATH" NIX_PATH="$NIX_PATH" `which nixos-install` --root /mnt
#clean up
sudo userdel nixbld
sudo groupdel nixbld
