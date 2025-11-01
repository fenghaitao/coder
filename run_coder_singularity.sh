#!/bin/bash

# Script to run the Singularity container with HOME environment reset
# Usage: ./run_coder_singularity.sh [new_home_path]
#        If no path provided, defaults to /nfs/site/home/$(whoami)

SINGULARITY_IMAGE="coder.sif"
DEFAULT_HOME="/nfs/site/home/$(whoami)"
NEW_HOME="${1:-$DEFAULT_HOME}"

echo "Running Singularity container with HOME=$NEW_HOME"

# Check if Singularity image exists
if [ ! -f "$SINGULARITY_IMAGE" ]; then
    echo "Error: Singularity image '$SINGULARITY_IMAGE' not found!"
    echo "Please run ./docker_to_singularity.sh first to create the image."
    exit 1
fi

# Run Singularity container with custom HOME directory
# Use --home to set the HOME directory inside the container
# Mount necessary system directories for proper functionality
singularity run \
    --home "$NEW_HOME" \
    --bind /nfs:/nfs \
    --bind /usr:/usr \
    --bind /etc:/etc \
    --bind /var/tmp:/var/tmp \
    --bind /tmp:/tmp \
    --bind /opt:/opt \
    "$SINGULARITY_IMAGE"
