#!/bin/bash

# Script to run the Docker container
# Usage: ./run_coder_docker.sh
# To use a different port: PORT=8080 ./scripts/run_coder_docker.sh

# Set PORT environment variable (default 7860)
PORT="${PORT:-7860}"

echo "Running Docker container on port $PORT"

docker run \
  --user $(id -u):$(id -g) \
  -e http_proxy=$http_proxy \
  -e https_proxy=$https_proxy \
  -e no_proxy=$no_proxy \
  -e PORT=$PORT \
  -p $PORT:$PORT \
  -v /nfs/site/home/hfeng1:/nfs/site/home/hfeng1 \
  -v /nfs:/nfs \
  -v /usr/intel:/usr/intel \
  coder:latest
