#!/bin/bash

# Script to run the Singularity container with HOME environment reset
# Usage: ./run_coder_singularity.sh [--shell] [new_home_path]
#        --shell: Enter interactive shell instead of running the service
#        If no path provided, defaults to /nfs/site/home/$(whoami)/coder
# To use a different port: PORT=8080 ./scripts/run_coder_singularity.sh

SINGULARITY_IMAGE="./coder.sif"
DEFAULT_HOME="/nfs/site/home/$(whoami)/coder"

# Parse command line arguments
SHELL_MODE=false
NEW_HOME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --shell)
            SHELL_MODE=true
            shift
            ;;
        *)
            NEW_HOME="$1"
            shift
            ;;
    esac
done

# Set default HOME if not provided
NEW_HOME="${NEW_HOME:-$DEFAULT_HOME}"

# Set PORT environment variable (default 7860)
export SINGULARITYENV_PORT="${PORT:-7860}"

# Set DISPLAY environment variable for X11 forwarding
export SINGULARITYENV_DISPLAY="${DISPLAY}"

# Ensure XAUTHORITY is set for xhost to work
if [ -z "$XAUTHORITY" ]; then
    export XAUTHORITY="$HOME/.Xauthority"
fi

# Grant X11 access
if [ -n "$DISPLAY" ]; then
    # Extract hostname from DISPLAY (e.g., hostname:1.0 -> hostname)
    DISPLAY_HOST=$(echo "$DISPLAY" | cut -d: -f1)
    
    if [ -z "$DISPLAY_HOST" ] || [ "$DISPLAY_HOST" = "localhost" ]; then
        # Local display - use secure local access
        XAUTHORITY="$XAUTHORITY" xhost +SI:localuser:$(whoami) 2>/dev/null || \
        XAUTHORITY="$XAUTHORITY" xhost +local: 2>/dev/null || \
        echo "Warning: xhost not available, X11 forwarding may not work"
    else
        # Network display - allow specific hostname
        echo "Detected network DISPLAY: $DISPLAY"
        XAUTHORITY="$XAUTHORITY" xhost +SI:localuser:$(whoami) 2>/dev/null || \
        XAUTHORITY="$XAUTHORITY" xhost +"$DISPLAY_HOST" 2>/dev/null || \
        echo "Warning: Could not grant X11 access for $DISPLAY_HOST"
    fi
fi

# Check if Singularity image exists
if [ ! -f "$SINGULARITY_IMAGE" ]; then
    echo "Error: Singularity image '$SINGULARITY_IMAGE' not found!"
    echo "Please run ./docker_to_singularity.sh first to create the image."
    exit 1
fi

if [ "$SHELL_MODE" = true ]; then
    echo "Entering Singularity container shell with HOME=$NEW_HOME"
    echo "DISPLAY is set to: $DISPLAY"
    echo "Type 'exit' to leave the container shell."
    
    # Enter interactive shell
    singularity shell \
        --home "$NEW_HOME" \
        --bind /nfs:/nfs \
        --bind /var/lib/ca-certificates:/var/lib/ca-certificates \
        --bind /var/tmp:/var/tmp \
        --bind /tmp:/tmp \
        --bind /tmp/.X11-unix:/tmp/.X11-unix \
        --bind /dev/fuse:/dev/fuse \
        "$SINGULARITY_IMAGE"
else
    echo "Running Singularity container with HOME=$NEW_HOME on port $SINGULARITYENV_PORT"
    echo "DISPLAY is set to: $DISPLAY"
    
    # Run Singularity container with custom HOME directory
    # Use --home to set the HOME directory inside the container
    # Mount necessary system directories for proper functionality
    singularity run \
        --home "$NEW_HOME" \
        --bind /nfs:/nfs \
        --bind /var/lib/ca-certificates:/var/lib/ca-certificates \
        --bind /var/tmp:/var/tmp \
        --bind /tmp:/tmp \
        --bind /tmp/.X11-unix:/tmp/.X11-unix \
        --bind /dev/fuse:/dev/fuse \
        "$SINGULARITY_IMAGE"
fi

# Revoke X11 access after container exits
if [ -n "$DISPLAY" ]; then
    DISPLAY_HOST=$(echo "$DISPLAY" | cut -d: -f1)
    
    if [ -z "$DISPLAY_HOST" ] || [ "$DISPLAY_HOST" = "localhost" ]; then
        XAUTHORITY="$XAUTHORITY" xhost -SI:localuser:$(whoami) 2>/dev/null || \
        XAUTHORITY="$XAUTHORITY" xhost -local: 2>/dev/null || \
        echo "Warning: Could not revoke X11 access"
    else
        XAUTHORITY="$XAUTHORITY" xhost -SI:localuser:$(whoami) 2>/dev/null || \
        XAUTHORITY="$XAUTHORITY" xhost -"$DISPLAY_HOST" 2>/dev/null || \
        echo "Warning: Could not revoke X11 access for $DISPLAY_HOST"
    fi
    echo "X11 access revoked"
fi
