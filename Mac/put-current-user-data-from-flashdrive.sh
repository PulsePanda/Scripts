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

# Define source directory on the flash drive and destination directories
source_directory="$flash_drive_path/Backup"
destination_directories=("$HOME/Desktop" "$HOME/Documents" "$HOME/Downloads" "$HOME/Pictures")

# Copy data from the flash drive to user's profile directories
for dest_dir in "${destination_directories[@]}"; do
    source_path="$source_directory/$(basename "$dest_dir")"
    if [ -e "$source_path" ]; then
        echo "Copying $source_path to $dest_dir"
        rsync -av "$source_path/" "$dest_dir/"
    else
        echo "$source_path not found. Skipping."
    fi
done

# Prepare the flash drive for the next computer by deleting copied data
echo "Deleting copied data from the flash drive..."
rm -rf "$source_directory"

echo "Data transfer completed."
