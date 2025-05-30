#!/bin/bash

# Define variables
BUCKET_NAME="ff-backups"
BACKUP_DIR="/media/backup-temp"  # Local directory for storing temporary backup files
FOLDER_NAME="CHANGEME"
DATE=$(date +%F)
DOCKER_COMPOSE_PATH="/root/docker-compose.yml"

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Get a list of all currently running container IDs
RUNNING_CONTAINERS=$(docker ps -q)

stop_running_containers() {
    # Stop all running containers
    if [ ! -z "$RUNNING_CONTAINERS" ]; then
        echo "Stopping running containers..."
        docker stop $RUNNING_CONTAINERS
    else
        echo "No containers are currently running."
    fi
}

# Function to backup all Docker images
backup_docker_images() {
    echo "Backing up Docker images..."

    # List all Docker images
    IMAGES=$(docker image ls --format "{{.Repository}}:{{.Tag}}")

    for IMAGE in $IMAGES; do
        # Skip internal none:<tag> images
        if [[ "$IMAGE" =~ "<none>" ]]; then
            continue
        fi

        IMAGE_NAME=$(echo $IMAGE | tr '/' '_' | tr ':' '_')
        docker save $IMAGE -o $BACKUP_DIR/${IMAGE_NAME}.tar
        echo "$IMAGE saved as ${IMAGE_NAME}.tar"
    done
}

# Function to backup Docker volumes
backup_docker_volumes() {
    echo "Backing up Docker volumes..."

    # List all Docker volumes
    VOLUMES=$(docker volume ls --format "{{.Name}}")

    for VOLUME in $VOLUMES; do
        DEST_FILE="$BACKUP_DIR/${VOLUME}.tar.gz"
        # Create a temporary container to copy the volume's data
        docker run --rm -v ${VOLUME}:/volume -v $BACKUP_DIR:/backup busybox tar czf /backup/${VOLUME}.tar.gz -C /volume ./
        echo "Volume $VOLUME saved as ${VOLUME}.tar.gz"
    done
}

start_stopped_containers() {
    # Start only the containers that were running before the backup
    if [ ! -z "$RUNNING_CONTAINERS" ]; then
        echo "Starting previously running containers..."
        docker start $RUNNING_CONTAINERS
    else
        echo "No containers were stopped, so none to restart."
    fi
}

# Function to copy docker_compose.yaml to backup-dir
export_docker_configurations() {
    cp "$DOCKER_COMPOSE_PATH" "$BACKUP_DIR" 2>/dev/null || echo "No docker-compose.yml found."
}

# Function to upload files to S3
upload_to_s3() {
    echo "Uploading backup files to S3..."

    s3cmd sync $BACKUP_DIR/ s3://$BUCKET_NAME/$FOLDER_NAME/$DATE/ --recursive

    if [ $? -eq 0 ]; then
        echo "Backup files successfully uploaded to s3://$BUCKET_NAME/$FOLDER_NAME/$DATE/"
    else
        echo "Failed to upload files to S3"
        exit 1
    fi
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

# Execute backup functions
stop_running_containers
backup_docker_images
backup_docker_volumes
export_docker_configurations
start_stopped_containers
upload_to_s3
cleanup_local_files

echo "Backup process completed."
