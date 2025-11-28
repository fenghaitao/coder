#!/bin/bash

# Script to run the Docker container
# Usage: ./run_coder_docker.sh
# To use a different port: PORT=8080 ./scripts/run_coder_docker.sh

# Set PORT environment variable (default 7860)
PORT="${PORT:-7860}"
CODE_SERVER_PORT="${CODE_SERVER_PORT:-9888}"

# Grant X11 access (allow connections from localhost)
if [ -n "$DISPLAY" ]; then
    xhost +local: 2>/dev/null || echo "Warning: xhost not available, X11 forwarding may not work"
fi

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
