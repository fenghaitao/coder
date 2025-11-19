#!/bin/bash

# Script to run the Singularity container with HOME environment reset
# Usage: ./run_coder_singularity.sh [new_home_path]
#        If no path provided, defaults to /nfs/site/home/$(whoami)/coder
# To use a different port: PORT=8080 ./scripts/run_coder_singularity.sh

SINGULARITY_IMAGE="./coder.sif"
DEFAULT_HOME="/nfs/site/home/$(whoami)/coder"
NEW_HOME="${1:-$DEFAULT_HOME}"

# Set PORT environment variable (default 7860)
export SINGULARITYENV_PORT="${PORT:-7860}"

# Set DISPLAY environment variable for X11 forwarding
export SINGULARITYENV_DISPLAY="${DISPLAY}"

# Grant X11 access (allow connections from localhost)
if [ -n "$DISPLAY" ]; then
    xhost +local: 2>/dev/null || echo "Warning: xhost not available, X11 forwarding may not work"
fi

echo "Running Singularity container with HOME=$NEW_HOME on port $SINGULARITYENV_PORT"
echo "DISPLAY is set to: $DISPLAY"

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
    --bind /var/tmp:/var/tmp \
    --bind /tmp:/tmp \
    --bind /opt:/opt \
    --bind /tmp/.X11-unix:/tmp/.X11-unix \
    "$SINGULARITY_IMAGE"
