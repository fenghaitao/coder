# Quick Start Guide

<cite>
**Referenced Files in This Document**
- [README.md](file://README.md)
- [Dockerfile](file://Dockerfile)
- [scripts/build_coder.sh](file://scripts/build_coder.sh)
- [scripts/run_coder_docker.sh](file://scripts/run_coder_docker.sh)
- [scripts/docker_to_singularity.sh](file://scripts/docker_to_singularity.sh)
- [scripts/run_coder_singularity.sh](file://scripts/run_coder_singularity.sh)
- [scripts/setup_env_in_container.sh](file://scripts/setup_env_in_container.sh)
- [scripts/setup-kiro-xdg.sh](file://scripts/setup-kiro-xdg.sh)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Initial Setup](#initial-setup)
4. [Docker Development Environment](#docker-development-environment)
5. [Singularity HPC Environment](#singularity-hpc-environment)
6. [Environment Verification](#environment-verification)
7. [Common Issues and Troubleshooting](#common-issues-and-troubleshooting)
8. [Next Steps](#next-steps)

## Introduction

This Quick Start Guide provides step-by-step instructions for setting up the Coder development environment using either Docker for local development or Singularity for High-Performance Computing (HPC) environments. The environment includes VS Code Server with pre-installed extensions, Node.js and Python development tools, and Atlassian CLI for project management.

The development environment offers two primary pathways:
- **Docker**: Ideal for local development with easy setup and immediate access
- **Singularity**: Optimized for HPC environments requiring container isolation

Both setups provide a web-based IDE accessible at `http://localhost:7860` for seamless development workflows.

## Prerequisites

### System Requirements

Before proceeding, ensure your system meets the following requirements:

#### For Docker Setup:
- **Operating System**: Linux, macOS, or Windows with WSL2
- **Docker**: Version 20.10 or higher
- **Memory**: Minimum 4GB RAM available for Docker
- **Storage**: At least 10GB free disk space
- **Network**: Internet connection for downloading dependencies

#### For Singularity Setup:
- **Operating System**: Linux (recommended for optimal performance)
- **Singularity**: Version 3.0 or higher
- **Docker**: Required for building the initial Docker image
- **Memory**: Minimum 4GB RAM
- **Storage**: At least 15GB free disk space (due to conversion overhead)

#### Shared Requirements:
- **Git**: Version 2.0 or higher
- **Submodule Dependencies**: Properly initialized Git submodules
- **Port Availability**: Port 7860 must be available for Docker or configurable for Singularity

### Installation Commands

#### Docker Installation (Linux):
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group (requires relogin)
sudo usermod -aG docker $USER
```

#### Docker Installation (macOS):
```bash
# Using Homebrew
brew install --cask docker
```

#### Docker Installation (Windows):
Download and install Docker Desktop from: https://www.docker.com/products/docker-desktop

#### Singularity Installation:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install singularity-container

# RHEL/CentOS/Fedora
sudo yum install singularity
```

## Initial Setup

### Repository Cloning and Submodule Initialization

Begin by cloning the repository and initializing the required submodules:

```bash
# Clone the repository
git clone https://github.com/fenghaitao/coder /nfs/site/home/$(whoami)/coder
cd /nfs/site/home/$(whoami)/coder

# Initialize submodules
git submodule update --init --recursive
```

**Section sources**
- [README.md](file://README.md#L15-L23)

### Directory Structure Overview

After initialization, your workspace will contain:

```
coder/
├── Dockerfile                 # Container definition
├── scripts/                   # Utility scripts
│   ├── build_coder.sh         # Build Docker image
│   ├── run_coder_docker.sh    # Run Docker container
│   ├── docker_to_singularity.sh # Convert to Singularity
│   ├── run_coder_singularity.sh # Run Singularity container
│   ├── setup_env_in_container.sh # Environment setup
│   └── setup-kiro-xdg.sh      # Kiro URL handler setup
├── vsix/                      # VS Code extensions
└── hf/                        # Additional configurations
```

## Docker Development Environment

### Step 1: Building the Docker Image

The Docker image builds with your user ID and group ID preserved for proper file permissions, along with corporate proxy support.

```bash
# Navigate to the repository directory
cd /nfs/site/home/$(whoami)/coder

# Build the Docker image
./scripts/build_coder.sh
```

**Expected Output:**
```
[+] Building 12.3s (23/23) FINISHED
 => [internal] load build definition from Dockerfile
 => [internal] load .dockerignore
 => [internal] load metadata for docker.io/library/ubuntu:24.04
 => [1/1] FROM docker.io/library/ubuntu:24.04
 => ...
 => [stage-1 1/1] COPY --from=builder /usr/bin/code-server /usr/bin/code-server
 => [final] WORKDIR /nfs/site/home/$(whoami)/coder
 => [final] ENTRYPOINT ["dumb-init", "/bin/bash", "-c", "exec /usr/bin/code-server --bind-addr 0.0.0.0:7860 --auth none ."]
 => exporting to image
 => exporting layers
 => writing image sha256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
 => naming to docker.io/library/coder:latest
```

**Key Features of the Build Process:**
- Preserves your user ID and group ID for file permissions
- Supports corporate proxy settings via environment variables
- Tags the image as `coder:latest`
- Includes all development dependencies and tools

**Section sources**
- [scripts/build_coder.sh](file://scripts/build_coder.sh#L1-L9)
- [Dockerfile](file://Dockerfile#L1-L150)

### Step 2: Running the Docker Container

Once the image is built, start the container using the run script:

```bash
# Run the Docker container
./scripts/run_coder_docker.sh
```

**Expected Output:**
```
Running Docker container on port 7860
DISPLAY is set to: :0
[2024-01-15T10:30:00.123Z] info  code-server 4.106.2
[2024-01-15T10:30:00.124Z] info  Using user-data-dir ~/.local/share/code-server
[2024-01-15T10:30:00.125Z] info  Using config-file ~/.config/code-server/config.yaml
[2024-01-15T10:30:00.126Z] info  HTTP server listening on http://0.0.0.0:7860
[2024-01-15T10:30:00.127Z] info  Started successfully
[2024-01-15T10:30:00.128Z] info  Tip: You can also access via a web browser on this machine at http://127.0.0.1:7860
```

**Container Features:**
- Maps port 7860 for web access
- Mounts home directory and system paths
- Preserves user permissions
- Forwards proxy environment variables
- Enables X11 forwarding for GUI applications

**Alternative: Interactive Shell Mode**
```bash
# Enter interactive shell instead of running the service
./scripts/run_coder_docker.sh --shell
```

**Section sources**
- [scripts/run_coder_docker.sh](file://scripts/run_coder_docker.sh#L1-L78)

### Step 3: Accessing the Web-Based IDE

Open your web browser and navigate to:
```
http://localhost:7860
```

**First-Time Access:**
- No authentication required (configured with `--auth none`)
- Direct access to the VS Code Server interface
- Full development environment ready for use

**Section sources**
- [README.md](file://README.md#L39-L41)

## Singularity HPC Environment

### Step 1: Building the Docker Image

Before converting to Singularity, build the Docker image first:

```bash
# Navigate to the repository directory
cd /nfs/site/home/$(whoami)/coder

# Build the Docker image
./scripts/build_coder.sh
```

**Expected Output:**
Same as Docker build process, confirming successful image creation.

### Step 2: Converting to Singularity Format

Convert the Docker image to Singularity format using the conversion script:

```bash
# Convert Docker image to Singularity
./scripts/docker_to_singularity.sh
```

**Expected Output:**
```
Converting Docker image coder:latest to Singularity image coder.sif...
INFO:    Converting OCI blobs to SIF format
INFO:    Starting build...
INFO:    Extracting base image
INFO:    Creating SIF file...
INFO:    Build complete: coder.sif
Conversion successful! Singularity image created: coder.sif
```

**Important Notes:**
- This process creates a `coder.sif` file in the current directory
- Requires Singularity to be installed and properly configured
- May take several minutes depending on system performance

**Section sources**
- [scripts/docker_to_singularity.sh](file://scripts/docker_to_singularity.sh#L1-L17)

### Step 3: Running the Singularity Container

Execute the Singularity container with optional custom home path:

```bash
# Use default HOME directory (recommended)
./scripts/run_coder_singularity.sh

# Or use custom HOME directory
./scripts/run_coder_singularity.sh /path/to/custom/home
```

**Default Behavior:**
- Uses `/nfs/site/home/$(whoami)/coder` as the home directory
- Maps necessary system directories for proper functionality
- Sets up X11 forwarding for GUI applications
- Configures port 7860 for web access

**Interactive Shell Mode:**
```bash
# Enter interactive shell
./scripts/run_coder_singularity.sh --shell

# With custom home path
./scripts/run_coder_singularity.sh --shell /path/to/custom/home
```

**Expected Output (Normal Mode):**
```
Running Singularity container with HOME=/nfs/site/home/$(whoami)/coder on port 7860
DISPLAY is set to: :0
[2024-01-15T10:30:00.123Z] info  code-server 4.106.2
[2024-01-15T10:30:00.124Z] info  HTTP server listening on http://0.0.0.0:7860
[2024-01-15T10:30:00.125Z] info  Started successfully
```

**Section sources**
- [scripts/run_coder_singularity.sh](file://scripts/run_coder_singularity.sh#L1-L115)

## Environment Verification

### Basic Functionality Tests

After starting either environment, verify the setup with these checks:

#### 1. Web Interface Access
- Open `http://localhost:7860` in your browser
- Verify VS Code Server loads without errors
- Check for proper theme and extension availability

#### 2. Development Tools Verification
```bash
# Test Node.js installation
node --version
npm --version

# Test Python installation
python --version
pip --version

# Test uv package manager
uv --version

# Test Atlassian CLI
acli --version
```

#### 3. Extension Verification
Verify that pre-installed extensions are available:
- GitHub Copilot (v1.325.0)
- GitHub Copilot Chat (v0.27.2)
- Python (v2024.8.1)
- C/C++ Tools (v1.7.1)
- C/C++ Extension Pack (v1.3.1)

### File Permissions Check

Ensure proper file permissions are maintained:

```bash
# Create a test file
touch ~/test_file.txt

# Verify ownership matches your user
ls -la ~/test_file.txt
```

**Expected Ownership:**
```
-rw-r--r-- 1 $(whoami) $(whoami) 0 Jan 15 10:30 test_file.txt
```

## Common Issues and Troubleshooting

### Docker-Specific Issues

#### Port Conflicts
**Problem:** Port 7860 already in use
**Solution:**
```bash
# Check which process is using the port
lsof -i :7860

# Use custom port
PORT=8080 ./scripts/run_coder_docker.sh
```

#### Docker Daemon Not Running
**Problem:** Docker daemon not accessible
**Solution:**
```bash
# Check Docker status
sudo systemctl status docker

# Start Docker service
sudo systemctl start docker
```

#### Proxy Configuration Issues
**Problem:** Behind corporate firewall
**Solution:**
```bash
# Set proxy environment variables
export http_proxy=http://proxy.company.com:8080
export https_proxy=http://proxy.company.com:8080
export no_proxy=localhost,127.0.0.1

# Rebuild with proxy settings
./scripts/build_coder.sh
```

### Singularity-Specific Issues

#### Missing coder.sif File
**Problem:** Singularity conversion failed or file not found
**Solution:**
```bash
# Verify Docker image exists
docker images | grep coder

# Rebuild Docker image
./scripts/build_coder.sh

# Convert to Singularity
./scripts/docker_to_singularity.sh
```

#### Mount Path Issues
**Problem:** Required directories not accessible
**Solution:**
```bash
# Check directory existence
ls -la /nfs
ls -la /usr/intel

# Adjust mount paths in run script if needed
```

#### X11 Forwarding Problems
**Problem:** GUI applications not displaying
**Solution:**
```bash
# Enable X11 access
xhost +local:

# Verify DISPLAY variable
echo $DISPLAY
```

### General Issues

#### Permission Problems
**Problem:** Files created with incorrect ownership
**Solution:**
```bash
# Rebuild image to preserve correct user ID
./scripts/build_coder.sh

# Or manually adjust permissions
sudo chown -R $(whoami):$(whoami) ~/coder
```

#### Network Access Issues
**Problem:** Cannot access web interface
**Solution:**
```bash
# Check firewall settings
sudo ufw status
sudo iptables -L

# Verify port accessibility
netstat -tlnp | grep 7860
```

**Section sources**
- [README.md](file://README.md#L180-L217)

## Next Steps

### Initial Environment Setup

After successful setup, run the environment initialization script inside the container:

```bash
# For Docker: Enter container shell
./scripts/run_coder_docker.sh --shell

# Inside container, run setup script
./scripts/setup_env_in_container.sh
```

**Setup Script Features:**
- Installs Node.js via nvm (Node Version Manager)
- Installs Python package manager (uv)
- Installs Atlassian CLI
- Configures Git globally
- Builds VS Code from source

### Customization Options

#### Adding New Extensions
1. Place `.vsix` files in the `vsix/` directory
2. Modify `setup_env_in_container.sh` to install them
3. Rebuild the image

#### Changing Port Configuration
Edit `run_coder_docker.sh` or use environment variable:
```bash
PORT=8080 ./scripts/run_coder_docker.sh
```

#### Custom Mount Points
Add additional `-v` flags in the run scripts to mount extra directories.

### Development Workflow

1. **Start Development Environment**: Choose Docker or Singularity based on your needs
2. **Access Web Interface**: Navigate to `http://localhost:7860`
3. **Install Extensions**: Use the VS Code interface or modify setup scripts
4. **Configure Tools**: Set up Git, Node.js, Python, and other development tools
5. **Begin Coding**: Start your development projects

### Advanced Configuration

For production deployments or specialized environments, consider:

- **Custom Dockerfiles**: Extend the base image with additional tools
- **Volume Management**: Configure persistent storage for projects
- **Security Hardening**: Implement proper authentication and access controls
- **Resource Limits**: Set CPU and memory limits for containers

**Section sources**
- [scripts/setup_env_in_container.sh](file://scripts/setup_env_in_container.sh#L1-L81)