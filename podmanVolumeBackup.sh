#!/bin/bash

# Volume name
VOLUME_NAME="eventbookingbackend_event_pg_data"

# Output directory (must exist)
BACKUP_DIR="/home/ubuntu/Backups"

# Create a timestamped filename
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="${VOLUME_NAME}_${TIMESTAMP}.tar.gz"

# Run backup using a temporary container
podman run --rm \
  -v ${VOLUME_NAME}:/data:ro \
  -v ${BACKUP_DIR}:/backup \
  alpine sh -c "tar -czf /backup/${FILENAME} -C /data ."