#!/bin/bash

# Define variables 
BUCKET_NAME="ff-backups"
BACKUP_DIR="/media/backup-temp"  # Local directory for storing downloaded backup files
FOLDER_NAME="backuptest1"
DATE="2025-03-16"  # e.g., "2023-10-05" or any date format matching your backup structure
DOCKER_COMPOSE_PATH="/root/docker-compose.yml"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR/

# Function to download backups from S3
download_from_s3() {
    echo "Downloading backup files from S3..."

    s3cmd sync s3://$BUCKET_NAME/$FOLDER_NAME/$DATE/ $BACKUP_DIR/ --recursive

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
        docker run --rm -v ${VOLUME_NAME}:/volume -v $BACKUP_DIR:/backup busybox sh -c "tar xzf /backup/${VOLUME_NAME}.tar.gz -C /volume"
        if [ $? -eq 0 ]; then
            echo "Restored volume data in $VOLUME_NAME from $VOLUME_TAR_GZ"
        else
            echo "Failed to restore volume data in $VOLUME_NAME from $VOLUME_TAR_GZ"
        fi
    done
}

restore_docker_compose() {
    cp "$BACKUP_DIR" "$DOCKER_COMPOSE_PATH" 2>/dev/null || echo "No docker-compose.yml found."
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

# List all images
run_all_images() {
    IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>")

    # Run a container from each image
    for IMAGE in $IMAGES; do
        echo "Attempting to run container from image: $IMAGE"
        docker run -d $IMAGE || echo "Failed to run container from image: $IMAGE"
    done
}

# Execute restore functions
download_from_s3
restore_docker_images
restore_docker_volumes
restore_docker_compose
cleanup_local_files
#run_all_images

echo "Restore process completed."
