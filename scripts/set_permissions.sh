#!/usr/bin/env bash
# Permission fix script for /home/mikilio
# Run as: sudo bash fix-permissions.sh
set -e
echo "Setting up permissions for /home/mikilio..."
# === STEP 1: Set home directory to 755 ===
chmod 755 /home/mikilio
# === STEP 2: Default ALL subdirs to 700 (protected) ===
chmod 700 /home/mikilio/Code/Private/mcloud
chmod 700 /home/mikilio/Code/Private/base16-generator
chmod 700 /home/mikilio/Downloads
chmod 700 /home/mikilio/.ssh
chmod 700 /home/mikilio/.thunderbird
chmod 700 /home/mikilio/.zen
chmod 700 /home/mikilio/.config
chmod 700 /home/mikilio/.yubico
chmod 700 /home/mikilio/.zcn
chmod 700 /home/mikilio/Zotero
chmod 700 /home/mikilio/Documents/Bureaucracy
chmod 700 /home/mikilio/Documents/Freelance/Invoices
chmod 700 /home/mikilio/Documents/Uni
# === STEP 3: Explicitly make public (755) ===
chmod 755 /home/mikilio/Code
chmod 755 /home/mikilio/Code/Private
chmod 755 /home/mikilio/Code/Public
chmod 755 /home/mikilio/Desktop
chmod 755 /home/mikilio/Documents
chmod 755 "/home/mikilio/Documents/Obsidian Vault"
chmod 755 /home/mikilio/Documents/Freelance
chmod 755 "/home/mikilio/Documents/Freelance/Certificates&Search"
chmod 755 /home/mikilio/Documents/Freelance/Duckrabbit
chmod 755 /home/mikilio/Music
chmod 755 /home/mikilio/Pictures
chmod 755 /home/mikilio/Public
chmod 755 /home/mikilio/Templates
chmod 755 /home/mikilio/Videos
# === STEP 4: Protect specific sensitive files ===
chmod 600 /home/mikilio/Downloads/github-recovery-codes.txt 2>/dev/null || true
find /home/mikilio -name ".env" -type f ! -name ".env.example" ! -name ".env.template" ! -name ".envrc" -exec chmod 600 {} \; 2>/dev/null || true
echo "Done! Permissions have been set."
