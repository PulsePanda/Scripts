#!/bin/bash

# Define variables
BUCKET_NAME="ff-backups"
BACKUP_DIR="/media/backup-temp"  # Local directory for storing downloaded backup files
FOLDER_NAME="mediadocker"
DATE="your-backup-date"  # e.g., "2023-10-05" or any date format matching your backup structure

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Function to download backups from S3
download_from_s3() {
    echo "Downloading backup files from S3..."

    s3cmd sync s3://$BUCKET_NAME/$FOLDER_NAME/$DATE/ $BACKUP_DIR --recursive

    if [ $? -eq 0 ]; then
        echo "Backup files successfully downloaded from s3://$BUCKET_NAME/$FOLDER_NAME/$DATE/"
    else
        echo "Failed to download files from S3"
        exit 1
    fi
}

# Function to restore Docker images
restore_docker_images() {
    echo "Restoring Docker images..."

    for IMAGE_TAR in $BACKUP_DIR/*.tar; do
        docker load -i $IMAGE_TAR
        if [ $? -eq 0 ]; then
            echo "Loaded image from $IMAGE_TAR"
        else
            echo "Failed to load image from $IMAGE_TAR"
        fi
    done
}

# Function to restore Docker volumes
restore_docker_volumes() {
    echo "Restoring Docker volumes..."

    for VOLUME_TAR_GZ in $BACKUP_DIR/*.tar.gz; do
        VOLUME_NAME=$(basename $VOLUME_TAR_GZ .tar.gz)

        # Create volume if it doesn't exist
        docker volume create $VOLUME_NAME

        # Create a temporary container to restore the volume's data
        docker run --rm -v ${VOLUME_NAME}:/volume -v $BACKUP_DIR:/backup ubuntu sh -c "tar xzf /backup/${VOLUME_NAME}.tar.gz -C /volume"
        if [ $? -eq 0 ]; then
            echo "Restored volume data in $VOLUME_NAME from $VOLUME_TAR_GZ"
        else
            echo "Failed to restore volume data in $VOLUME_NAME from $VOLUME_TAR_GZ"
        fi
    done
}

# Function to cleanup local backup files
cleanup_local_files() {
    echo "Cleaning up local backup files..."

    rm -rf $BACKUP_DIR/*
    if [ $? -eq 0 ]; then
        echo "Local backup files cleaned."
    else
        echo "Failed to clean local backup files."
    fi
}

# Execute restore functions
download_from_s3
restore_docker_images
restore_docker_volumes
cleanup_local_files

echo "Restore process completed."
