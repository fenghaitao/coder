#!/bin/bash

# Convert Docker image to Singularity image
DOCKER_IMAGE="coder:latest"
SINGULARITY_IMAGE="coder.sif"

echo "Converting Docker image ${DOCKER_IMAGE} to Singularity image ${SINGULARITY_IMAGE}..."

singularity build ${SINGULARITY_IMAGE} docker-daemon://${DOCKER_IMAGE}

if [ $? -eq 0 ]; then
    echo "Conversion successful! Singularity image created: ${SINGULARITY_IMAGE}"
else
    echo "Conversion failed!"
    exit 1
fi
