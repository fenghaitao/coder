#!/bin/bash

# Script to clone vscode-copilot-chat repository and build VSIX
# Equivalent to Dockerfile lines 133-139

set -e  # Exit on any error

# Define variables
REPO_URL="https://github.com/fenghaitao/vscode-copilot-chat.git"
TARGET_DIR="$HOME/vscode-copilot-chat"
USERNAME="${USERNAME:-ubuntu}"

echo "Setting up Node.js version 20.20.0..."
bash -c 'export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm use v20.20.0'

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

echo "Setting ownership of the cloned repository..."
chown -R ${USERNAME}:${USERNAME} "$TARGET_DIR"

echo "Script completed successfully!"