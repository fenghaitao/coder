# Troubleshooting

<cite>
**Referenced Files in This Document**
- [build_coder.sh](file://scripts/build_coder.sh)
- [run_coder_docker.sh](file://scripts/run_coder_docker.sh)
- [run_coder_singularity.sh](file://scripts/run_coder_singularity.sh)
- [docker_to_singularity.sh](file://scripts/docker_to_singularity.sh)
- [Dockerfile](file://Dockerfile)
- [setup_env_in_container.sh](file://scripts/setup_env_in_container.sh)
- [setup-kiro-xdg.sh](file://scripts/setup-kiro-xdg.sh)
- [hf/Dockerfile](file://hf/Dockerfile)
- [hf/install_vscode_copilot_chat.sh](file://hf/install_vscode_copilot_chat.sh)
- [README.md](file://README.md)
</cite>

## Table of Contents
1. [Introduction](#introduction)
2. [Docker Issues](#docker-issues)
3. [Singularity Issues](#singularity-issues)
4. [Permission Problems](#permission-problems)
5. [Network Access Issues](#network-access-issues)
6. [Environment-Specific Challenges](#environment-specific-challenges)
7. [Performance Troubleshooting](#performance-troubleshooting)
8. [Diagnostic Commands](#diagnostic-commands)
9. [Prevention Strategies](#prevention-strategies)
10. [Common Error Messages](#common-error-messages)

## Introduction

This comprehensive troubleshooting guide addresses common issues encountered when using the Coder development environment. The environment supports both Docker and Singularity containerization methods, each with their own set of potential issues. This guide organizes problems by category and provides step-by-step resolution strategies based on real examples from the codebase.

## Docker Issues

### Docker Daemon Not Running

**Symptom**: `Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`

**Root Cause**: The Docker service is not started or accessible.

**Resolution Steps**:
1. Check Docker daemon status:
   ```bash
   systemctl status docker
   ```
2. Start Docker daemon if stopped:
   ```bash
   sudo systemctl start docker
   ```
3. Add user to docker group (if needed):
   ```bash
   sudo usermod -aG docker $USER
   ```
4. Log out and back in, or run:
   ```bash
   newgrp docker
   ```

**Prevention**: Ensure Docker is installed and running before attempting to build or run containers.

### Port 7860 Already in Use

**Symptom**: `Bind for 0.0.0.0:7860 failed: port is already allocated`

**Root Cause**: Another process is using port 7860, or the previous container didn't shut down properly.

**Resolution Steps**:
1. Check which process is using port 7860:
   ```bash
   sudo lsof -i :7860
   ```
2. Kill the process if appropriate:
   ```bash
   sudo kill -9 <PID>
   ```
3. Alternatively, use a different port:
   ```bash
   PORT=8080 ./scripts/run_coder_docker.sh
   ```

**Prevention**: Always check port availability before running the container.

### Proxy Configuration Issues

**Symptom**: Build failures with network timeouts or certificate errors behind corporate firewall.

**Root Cause**: Missing or incorrect proxy configuration during Docker build.

**Resolution Steps**:
1. Check current proxy settings:
   ```bash
   echo $http_proxy $https_proxy $no_proxy
   ```
2. Verify proxy settings in build script:
   ```bash
   cat scripts/build_coder.sh
   ```
3. Manually set proxy variables if needed:
   ```bash
   export http_proxy=http://proxy.company.com:8080
   export https_proxy=https://proxy.company.com:8080
   export no_proxy=localhost,127.0.0.1,.company.com
   ```
4. Rebuild the image with proper proxy settings.

**Section sources**
- [build_coder.sh](file://scripts/build_coder.sh#L1-L9)
- [run_coder_docker.sh](file://scripts/run_coder_docker.sh#L45-L47)

## Singularity Issues

### Missing coder.sif Image

**Symptom**: `Error: Singularity image './coder.sif' not found! Please run ./docker_to_singularity.sh first to create the image.`

**Root Cause**: Singularity image was not created or the path is incorrect.

**Resolution Steps**:
1. Verify Docker image exists:
   ```bash
   docker images | grep coder
   ```
2. Build Docker image if missing:
   ```bash
   ./scripts/build_coder.sh
   ```
3. Convert to Singularity:
   ```bash
   ./scripts/docker_to_singularity.sh
   ```
4. Verify Singularity image creation:
   ```bash
   ls -la coder.sif
   ```

**Prevention**: Always run `docker_to_singularity.sh` after building the Docker image.

### Singularity Not Installed

**Symptom**: `command not found: singularity`

**Root Cause**: Singularity container runtime is not installed on the host system.

**Resolution Steps**:
1. Check Singularity installation:
   ```bash
   singularity --version
   ```
2. Install Singularity based on your distribution:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install singularity-container
   
   # CentOS/RHEL
   sudo yum install singularity
   
   # From source
   git clone https://github.com/sylabs/singularity.git
   cd singularity
   ./mconfig && make -C builddir && sudo make -C builddir install
   ```
3. Verify installation:
   ```bash
   singularity --version
   ```

### Mount Path Errors

**Symptom**: `mount path /nfs does not exist on the host system` or permission denied errors.

**Root Cause**: Host directories mounted in Singularity don't exist or lack proper permissions.

**Resolution Steps**:
1. Verify mount paths exist:
   ```bash
   ls -la /nfs/site/home/hfeng1 /nfs /usr/intel
   ```
2. Create missing directories:
   ```bash
   sudo mkdir -p /nfs/site/home/hfeng1 /nfs /usr/intel
   ```
3. Check permissions:
   ```bash
   ls -la /nfs/site/home/hfeng1
   ```
4. Adjust permissions if needed:
   ```bash
   sudo chmod 755 /nfs/site/home/hfeng1
   ```

**Section sources**
- [run_coder_singularity.sh](file://scripts/run_coder_singularity.sh#L62-L67)
- [docker_to_singularity.sh](file://scripts/docker_to_singularity.sh#L1-L17)

## Permission Problems

### UID/GID Mismatch Issues

**Symptom**: Files created inside container have wrong ownership, or permission denied errors.

**Root Cause**: The container user ID doesn't match the host user ID.

**Resolution Steps**:
1. Check current user IDs:
   ```bash
   id -u && id -g
   ```
2. Rebuild Docker image with correct IDs:
   ```bash
   ./scripts/build_coder.sh
   ```
3. Verify container user:
   ```bash
   docker exec <container_id> id
   ```
4. Check file ownership inside container:
   ```bash
   docker exec <container_id> ls -la /nfs/site/home/hfeng1
   ```

**Prevention Strategy**: Always rebuild the Docker image after changing user IDs.

### Incorrect File Ownership

**Symptom**: Files created in the container appear owned by root or have permission issues.

**Root Cause**: The container creates files with different user/group IDs than the host user.

**Resolution Steps**:
1. Identify the container user:
   ```bash
   docker exec coder_container_id id
   ```
2. Change ownership recursively:
   ```bash
   sudo chown -R hfeng1:hfeng1 /nfs/site/home/hfeng1/coder
   ```
3. Fix permissions:
   ```bash
   sudo chmod -R 755 /nfs/site/home/hfeng1/coder
   ```

**Section sources**
- [Dockerfile](file://Dockerfile#L111-L114)
- [build_coder.sh](file://scripts/build_coder.sh#L2-L8)

## Network Access Issues

### Firewall Blocking Port 7860

**Symptom**: Cannot access the web interface at `http://localhost:7860`.

**Root Cause**: Local firewall blocks incoming connections on port 7860.

**Resolution Steps**:
1. Check if port is listening:
   ```bash
   netstat -tlnp | grep 7860
   ```
2. Allow port through firewall:
   ```bash
   sudo ufw allow 7860
   sudo firewall-cmd --zone=public --add-port=7860/tcp --permanent
   sudo firewall-cmd --reload
   ```
3. Verify port accessibility:
   ```bash
   curl http://localhost:7860
   ```

### Remote Access via SSH Tunneling

**Symptom**: Need to access the environment from a remote machine.

**Resolution Steps**:
1. Create SSH tunnel:
   ```bash
   ssh -L 7860:localhost:7860 user@remote-host
   ```
2. Access through local browser:
   ```bash
   http://localhost:7860
   ```
3. Alternative with dynamic port forwarding:
   ```bash
   ssh -D 8080 user@remote-host
   ```

### X11 Forwarding Issues

**Symptom**: GUI applications fail to display or show "cannot open display" errors.

**Root Cause**: X11 forwarding not properly configured or DISPLAY variable not set.

**Resolution Steps**:
1. Check DISPLAY variable:
   ```bash
   echo $DISPLAY
   ```
2. Enable X11 forwarding in SSH:
   ```bash
   ssh -X user@host
   ```
3. Verify xhost settings:
   ```bash
   xhost +local:
   ```
4. Test with a GUI application:
   ```bash
   firefox &
   ```

**Section sources**
- [run_coder_docker.sh](file://scripts/run_coder_docker.sh#L29-L32)
- [run_coder_singularity.sh](file://scripts/run_coder_singularity.sh#L38-L60)

## Environment-Specific Challenges

### Corporate Firewall Configuration

**Symptom**: Build fails with network connectivity issues despite proxy settings.

**Root Cause**: Corporate firewall blocks Docker registry access or requires additional certificates.

**Resolution Steps**:
1. Configure Docker daemon proxy:
   ```bash
   sudo mkdir -p /etc/systemd/system/docker.service.d
   sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
   [Service]
   Environment="HTTP_PROXY=http://proxy.company.com:8080"
   Environment="HTTPS_PROXY=https://proxy.company.com:8080"
   Environment="NO_PROXY=localhost,127.0.0.1,.company.com"
   EOF
   sudo systemctl daemon-reload
   sudo systemctl restart docker
   ```
2. Verify proxy configuration:
   ```bash
   docker info | grep Proxy
   ```
3. Test connectivity:
   ```bash
   docker pull hello-world
   ```

### SSL Certificate Issues

**Symptom**: HTTPS certificate verification failures during package installation.

**Resolution Steps**:
1. Update CA certificates:
   ```bash
   docker exec coder_container_id apt-get update && apt-get install -y ca-certificates
   ```
2. Add custom certificates:
   ```bash
   docker cp /path/to/cert.pem coder_container_id:/usr/local/share/ca-certificates/
   docker exec coder_container_id update-ca-certificates
   ```
3. Restart container:
   ```bash
   docker restart coder_container_id
   ```

**Section sources**
- [build_coder.sh](file://scripts/build_coder.sh#L5-L7)
- [run_coder_docker.sh](file://scripts/run_coder_docker.sh#L65-L67)

## Performance Troubleshooting

### Slow Extension Installation

**Symptom**: VS Code extensions take excessive time to install.

**Root Cause**: Network latency, insufficient resources, or concurrent downloads.

**Resolution Steps**:
1. Monitor installation progress:
   ```bash
   docker logs -f coder_container_id
   ```
2. Increase Docker resources:
   ```bash
   # Edit Docker preferences and increase CPU and memory limits
   ```
3. Install extensions individually:
   ```bash
   docker exec coder_container_id code-server --install-extension ms-python.python
   ```
4. Use offline installation:
   ```bash
   # Download VSIX files manually and place in vsix/ directory
   ```

### High Memory Usage

**Symptom**: Container consumes excessive memory or gets killed by OOM killer.

**Resolution Steps**:
1. Monitor memory usage:
   ```bash
   docker stats coder_container_id
   ```
2. Limit container memory:
   ```bash
   docker run --memory=4g --memory-swap=4g coder:latest
   ```
3. Optimize build cache:
   ```bash
   docker system prune -f
   ```
4. Reduce unnecessary packages in Dockerfile.

### Slow Extension Installation

**Symptom**: VS Code extensions take excessive time to install.

**Root Cause**: Network latency, insufficient resources, or concurrent downloads.

**Resolution Steps**:
1. Monitor installation progress:
   ```bash
   docker logs -f coder_container_id
   ```
2. Increase Docker resources:
   ```bash
   # Edit Docker preferences and increase CPU and memory limits
   ```
3. Install extensions individually:
   ```bash
   docker exec coder_container_id code-server --install-extension ms-python.python
   ```
4. Use offline installation:
   ```bash
   # Download VSIX files manually and place in vsix/ directory
   ```

**Section sources**
- [setup_env_in_container.sh](file://scripts/setup_env_in_container.sh#L59-L73)

## Diagnostic Commands

### Docker Diagnostics

```bash
# Check container status
docker ps -a

# View container logs
docker logs coder_container_id

# Inspect container configuration
docker inspect coder_container_id

# Check disk usage
docker system df

# List images
docker images
```

### Singularity Diagnostics

```bash
# Check Singularity version
singularity --version

# Inspect image metadata
singularity inspect ./coder.sif

# Test image execution
singularity exec ./coder.sif whoami

# Check image size
du -h coder.sif
```

### Container Environment Diagnostics

```bash
# Check user permissions
docker exec coder_container_id id

# Verify mounted volumes
docker exec coder_container_id df -h

# Check network configuration
docker exec coder_container_id netstat -tlnp

# Monitor resource usage
docker exec coder_container_id top
```

### System-Level Diagnostics

```bash
# Check Docker daemon status
systemctl status docker

# Verify port availability
netstat -tlnp | grep 7860

# Check proxy configuration
env | grep -E "(proxy|PROXY)"

# Verify filesystem permissions
ls -la /nfs/site/home/hfeng1
```

## Prevention Strategies

### Always Rebuild After UID Changes

**Strategy**: When your user ID changes (due to account migration, system updates, etc.), always rebuild the Docker image to maintain proper file permissions.

**Implementation**:
```bash
# Check current user ID
id -u

# Rebuild Docker image
./scripts/build_coder.sh

# Verify container user
docker exec coder_container_id id
```

### Regular Maintenance Tasks

1. **Clean up unused resources**:
   ```bash
   docker system prune -f
   docker volume prune -f
   ```

2. **Update base images regularly**:
   ```bash
   docker pull ubuntu:24.04
   ./scripts/build_coder.sh
   ```

3. **Monitor container health**:
   ```bash
   # Set up monitoring alerts for container failures
   ```

### Environment Variable Management

1. **Export proxy settings consistently**:
   ```bash
   # Add to ~/.bashrc or ~/.profile
   export http_proxy=http://proxy.company.com:8080
   export https_proxy=https://proxy.company.com:8080
   export no_proxy=localhost,127.0.0.1,.company.com
   ```

2. **Validate environment before running**:
   ```bash
   # Check essential variables
   env | grep -E "(http_proxy|https_proxy|no_proxy|DISPLAY)"
   ```

## Common Error Messages

### Docker Build Errors

| Error Message | Root Cause | Resolution |
|---------------|------------|------------|
| `Cannot connect to the Docker daemon` | Docker service not running | Start Docker daemon |
| `Permission denied while trying to connect` | User not in docker group | Add user to docker group |
| `No space left on device` | Insufficient disk space | Clean up Docker resources |
| `invalid reference format` | Tagging error | Check Docker tag syntax |

### Container Runtime Errors

| Error Message | Root Cause | Resolution |
|---------------|------------|------------|
| `port is already allocated` | Port conflict | Use different port or kill process |
| `Bind for 0.0.0.0:7860 failed` | Firewall blocking | Configure firewall rules |
| `cannot connect to X server` | X11 forwarding disabled | Enable X11 forwarding |
| `permission denied` | File ownership issue | Rebuild with correct UID/GID |

### Singularity Errors

| Error Message | Root Cause | Resolution |
|---------------|------------|------------|
| `not found` | Singularity not installed | Install Singularity runtime |
| `image not found` | Missing .sif file | Run docker_to_singularity.sh |
| `mount path does not exist` | Host directory missing | Create mount directories |
| `insufficient privileges` | Insufficient permissions | Check file permissions |

### Network Connectivity Errors

| Error Message | Root Cause | Resolution |
|---------------|------------|------------|
| `Connection refused` | Service not running | Check container status |
| `Network unreachable` | Network configuration | Verify network settings |
| `DNS resolution failed` | DNS configuration | Check DNS settings |
| `SSL handshake failed` | Certificate issues | Update CA certificates |

**Section sources**
- [README.md](file://README.md#L180-L217)