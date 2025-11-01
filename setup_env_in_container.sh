#!/bin/bash

# setup_env.sh - Setup development environment inside the container
# This script should be run inside the container as the user

set -e  # Exit on any error

echo "Setting up development environment..."

# Clone the coder repository and install extensions
echo "Installing VS Code extensions..."
git clone https://github.com/fenghaitao/coder.git /tmp/coder
code-server --install-extension /tmp/coder/vsix/github.copilot-1.325.0.vsix
code-server --install-extension /tmp/coder/vsix/github.copilot-chat-0.27.2.vsix
code-server --install-extension /tmp/coder/vsix/ms-python.python-2024.8.1.vsix
code-server --install-extension /tmp/coder/vsix/ms-vscode.cpptools-1.7.1.vsix
code-server --install-extension /tmp/coder/vsix/ms-vscode.cpptools-extension-pack-1.3.1.vsix

# Install nvm (Node Version Manager)
echo "Installing Node Version Manager (nvm)..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
echo 'export NVM_DIR="$HOME/.nvm"' >> $HOME/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> $HOME/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use' >> $HOME/.profile

# Install Node.js using nvm
echo "Installing Node.js..."
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install node

# Install uv (Python package manager)
echo "Installing uv (Python package manager)..."
curl -LsSf https://astral.sh/uv/install.sh | sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.profile

# Install Atlassian CLI (acli)
echo "Installing Atlassian CLI..."
curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli"
chmod +x acli

echo "Development environment setup complete!"
echo "Please run 'source ~/.bashrc' or restart your shell to use the new tools."
