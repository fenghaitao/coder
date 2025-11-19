# Coder Development Environment

This repository contains scripts and configurations to set up a containerized development environment using VS Code Server (coder) with Docker and Singularity support.

## Overview

The environment includes:
- VS Code Server with pre-installed extensions (Copilot, Python, C++ tools)
- Node.js and Python development tools
- Atlassian CLI for project management
- Support for both Docker and Singularity containers

## Initial Setup

First, clone this repository and initialize submodules:

```bash
git clone https://github.com/fenghaitao/coder /nfs/site/home/$(whoami)/coder
cd /nfs/site/home/$(whoami)/coder
git submodule update --init --recursive
```

This will checkout the vscode and vscode-copilot-chat submodules required for the development environment.

## Quick Start

### Option 1: Docker (Recommended for local development)

1. **Build the Docker image:**
   ```bash
   ./scripts/build_coder.sh
   ```

2. **Run the container:**
   ```bash
   ./scripts/run_coder_docker.sh
   ```

3. **Access the environment:**
   Open your browser and navigate to `http://localhost:7860`

### Option 2: Singularity (For HPC environments)

1. **Build the Docker image first:**
   ```bash
   ./scripts/build_coder.sh
   ```

2. **Convert to Singularity:**
   ```bash
   ./scripts/docker_to_singularity.sh
   ```

3. **Run the Singularity container:**
   ```bash
   ./scripts/run_coder_singularity.sh [optional_home_path]
   ```

## Script Details

### `scripts/build_coder.sh`
Builds the Docker image with proper user permissions and proxy settings.

**Features:**
- Preserves your user ID and group ID for file permissions
- Supports corporate proxy settings
- Tags the image as `coder:latest`

**Usage:**
```bash
./scripts/build_coder.sh
```

### `scripts/run_coder_docker.sh`
Runs the Docker container with all necessary mounts and port forwarding.

**Features:**
- Maps port 7860 for web access
- Mounts home directory and system paths
- Preserves user permissions
- Forwards proxy environment variables

**Usage:**
```bash
./scripts/run_coder_docker.sh
```

**Access:** http://localhost:7860

### `scripts/docker_to_singularity.sh`
Converts the Docker image to a Singularity image file.

**Features:**
- Creates `coder.sif` from `coder:latest` Docker image
- Useful for HPC environments that require Singularity
- Includes error checking and status reporting

**Usage:**
```bash
./scripts/docker_to_singularity.sh
```

**Output:** Creates `coder.sif` file

### `scripts/run_coder_singularity.sh`
Runs the Singularity container with proper environment setup.

**Features:**
- Customizable HOME directory
- Mounts necessary system directories
- Defaults to `/nfs/site/home/$(whoami)/coder` if no path provided

**Usage:**
```bash
# Use default HOME directory
./scripts/run_coder_singularity.sh

# Use custom HOME directory
./scripts/run_coder_singularity.sh /path/to/custom/home
```

### `scripts/setup_env_in_container.sh`
Sets up the development environment inside the container.

**Features:**
- Installs VS Code extensions from local vsix files
- Installs Node.js via nvm
- Installs Python package manager (uv)
- Installs Atlassian CLI

**Note:** This script only needs to be run once during initial setup.

**Usage:**
```bash
# Run inside the container (only needed once)
./scripts/setup_env_in_container.sh
```

## Pre-installed Extensions

The environment comes with these VS Code extensions:
- GitHub Copilot (v1.325.0)
- GitHub Copilot Chat (v0.27.2)
- Python (v2024.8.1)
- C/C++ Tools (v1.7.1)
- C/C++ Extension Pack (v1.3.1)

## Development Tools

### Node.js
- Managed via nvm (Node Version Manager)
- Latest stable version installed

### Python
- System Python available
- `uv` package manager for fast Python package installation

### Atlassian CLI
- Command-line interface for Jira and Confluence
- Located in container after setup

## File Structure

```
.
├── Dockerfile              # Main container definition
├── .gitignore              # Git ignore rules (excludes .sif files)
├── scripts/                # Utility scripts
│   ├── build_coder.sh      # Build Docker image
│   ├── docker_to_singularity.sh  # Convert to Singularity
│   ├── run_coder_docker.sh # Run Docker container
│   ├── run_coder_singularity.sh # Run Singularity container
│   └── setup_env_in_container.sh # Environment setup
├── vsix/                   # VS Code extensions
└── hf/                     # Additional configurations
```

## Troubleshooting

### Docker Issues
- Ensure Docker daemon is running
- Check proxy settings if behind corporate firewall
- Verify port 7860 is not in use

### Singularity Issues
- Ensure Singularity is installed and available
- Check that `coder.sif` exists (run `docker_to_singularity.sh` first)
- Verify mount paths exist on the host system

### Permission Issues
- The scripts preserve your user ID/group ID for proper file permissions
- If files are created with wrong ownership, rebuild the image

### Network Access
- VS Code Server runs on port 7860
- Ensure firewall allows access to this port
- For remote access, use SSH port forwarding if needed

## Customization

### Adding Extensions
1. Place `.vsix` files in the `vsix/` directory
2. Modify `setup_env_in_container.sh` to install them
3. Rebuild the image

### Changing Ports
Modify the `-p` flag in `run_coder_docker.sh` to change the port mapping.

### Custom Mounts
Add additional `-v` flags in the run scripts to mount additional directories.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify all prerequisites are installed
3. Check container logs for error messages