#!/bin/bash

# Detect the flash drive and set its path
flash_drive_path=""
for drive in /Volumes/*; do
    if [ -e "$drive/flashdrive_marker.txt" ]; then
        flash_drive_path="$drive"
        break
    fi
done

# Check if the flash drive was found
if [ -z "$flash_drive_path" ]; then
    echo "Flash drive not found!"
    exit 1
fi

# Define source directories and destination directory
source_directories=("$HOME/Desktop" "$HOME/Documents" "$HOME/Downloads" "$HOME/Pictures")
destination_directory="$flash_drive_path/Backup"

# Create destination directory if it doesn't exist
mkdir -p "$destination_directory"

# Copy data to the flash drive
for source_dir in "${source_directories[@]}"; do
    if [ -e "$source_dir" ]; then
        echo "Copying $source_dir to $destination_directory"
        rsync -av "$source_dir/" "$destination_directory/$(basename "$source_dir")/"
    else
        echo "$source_dir not found. Skipping."
    fi
done

echo "Backup completed."
