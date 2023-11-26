#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3

import os
import fileinput

# Define the directory name
dirname = "/home/mikilio/dev/nur-packages/overlays/vimPlugins"

# Define the old and new strings
old_string = "buildVimPluginFrom2Nix"
new_string = "buildVimPlugin"

# Function to replace text in a file
def replace_in_file(file_path):
    with fileinput.FileInput(file_path, inplace=True) as file:
        for line in file:
            print(line.replace(old_string, new_string), end='')

# Walk through the directory and its subdirectories
for dirpath, dirnames, filenames in os.walk(dirname):
    for filename in filenames:
        file_path = os.path.join(dirpath, filename)
        replace_in_file(file_path)

print(f"Replaced '{old_string}' with '{new_string}' in all files in '{dirname}'.")

