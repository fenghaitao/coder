#!/bin/bash

# Script to run the Docker container
# Usage: ./run_coder_docker.sh [--shell]
#        --shell: Enter interactive shell instead of running the service
# To use a different port: PORT=8080 ./scripts/run_coder_docker.sh

# Parse command line arguments
SHELL_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --shell)
            SHELL_MODE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--shell]"
            exit 1
            ;;
    esac
done

# Set PORT environment variable (default 7860)
PORT="${PORT:-7860}"
CODE_SERVER_PORT="${CODE_SERVER_PORT:-9888}"

# Grant X11 access (allow connections from localhost)
if [ -n "$DISPLAY" ]; then
    xhost +local: 2>/dev/null || echo "Warning: xhost not available, X11 forwarding may not work"
fi

if [ "$SHELL_MODE" = true ]; then
    echo "Entering Docker container shell"
    echo "DISPLAY is set to: $DISPLAY"
    echo "Type 'exit' to leave the container shell."
    
    docker run -it --rm \
      --user $(id -u):$(id -g) \
      --security-opt seccomp=unconfined \
      --cap-add=SYS_ADMIN \
      --device /dev/fuse \
      --ipc=host \
      -e http_proxy=$http_proxy \
      -e https_proxy=$https_proxy \
      -e no_proxy=$no_proxy \
      -e DISPLAY=$DISPLAY \
      -v /nfs/site/home/hfeng1:/nfs/site/home/hfeng1 \
      -v /nfs:/nfs \
      -v /usr/intel:/usr/intel \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      --entrypoint /bin/bash \
      coder:latest
else
    echo "Running Docker container on port $PORT"
    echo "DISPLAY is set to: $DISPLAY"

    docker run \
      --user $(id -u):$(id -g) \
      --security-opt seccomp=unconfined \
      --cap-add=SYS_ADMIN \
      --device /dev/fuse \
      --ipc=host \
      -e http_proxy=$http_proxy \
      -e https_proxy=$https_proxy \
      -e no_proxy=$no_proxy \
      -e PORT=$PORT \
      -e DISPLAY=$DISPLAY \
      -p $PORT:$PORT \
      -p $CODE_SERVER_PORT:$CODE_SERVER_PORT \
      -v /nfs/site/home/hfeng1:/nfs/site/home/hfeng1 \
      -v /nfs:/nfs \
      -v /usr/intel:/usr/intel \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      coder:latest
fi
