#!/bin/bash

# Script to install additional tools and build vscode-copilot-chat VSIX
# Equivalent to additional Dockerfile sections

set -e  # Exit on any error

# Define variables
REPO_URL="https://github.com/fenghaitao/vscode-copilot-chat.git"
TARGET_DIR="$HOME/vscode-copilot-chat"
CODER_REPO_URL="https://github.com/fenghaitao/coder.git"
CODER_TARGET_DIR="$(dirname "$0")/../"
USERNAME="${USERNAME:-ubuntu}"

echo "Installing uv (Python package manager)..."
curl -LsSf https://astral.sh/uv/install.sh | sh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.profile
chown -R ${USERNAME}:${USERNAME} $HOME/.local

echo "Installing Atlassian CLI (acli)..."
curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli"
chmod +x acli

echo "Cloning coder repository and installing VS Code extensions..."
code-server --install-extension "$CODER_TARGET_DIR/vsix/ms-python.python-2024.8.1.vsix"
code-server --install-extension "$CODER_TARGET_DIR/vsix/ms-vscode.cpptools-1.7.1.vsix"
code-server --install-extension "$CODER_TARGET_DIR/vsix/ms-vscode.cpptools-extension-pack-1.3.1.vsix"
chown -R ${USERNAME}:${USERNAME} "$CODER_TARGET_DIR"

echo "Cloning vscode-copilot-chat repository..."
git clone "$REPO_URL" "$TARGET_DIR"

echo "Changing to repository directory..."
cd "$TARGET_DIR"

echo "Setting up NVM environment and installing npm dependencies..."
bash -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm install'

echo "Compiling the project..."
bash -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm run compile'

echo "Packaging VSIX with sendgrid secrets..."
bash -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm run package -- --allow-package-secrets sendgrid'

echo "Installing the built vscode-copilot-chat extension..."
# Find the generated VSIX file and install it
VSIX_FILE=$(find "$TARGET_DIR" -name "*.vsix" -type f | head -1)
if [ -n "$VSIX_FILE" ]; then
    echo "Found VSIX file: $VSIX_FILE"
    code-server --install-extension "$VSIX_FILE"
    echo "Successfully installed vscode-copilot-chat extension"
else
    echo "Warning: No VSIX file found in $TARGET_DIR"
    ls -la "$TARGET_DIR"/*.vsix 2>/dev/null || echo "No .vsix files found"
fi

echo "Script completed successfully!"
