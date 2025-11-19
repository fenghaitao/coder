#!/bin/bash

# setup_env_in_container.sh - Setup development environment inside the container
# This script should be run inside the container as the user

set -e  # Exit on any error

echo "Setting up development environment..."

# Install nvm (Node Version Manager)
echo "Installing Node Version Manager (nvm)..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    echo 'export NVM_DIR="$HOME/.nvm"' >> $HOME/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> $HOME/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use' >> $HOME/.profile
fi

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node.js using nvm
echo "Installing Node.js 22.20.0..."
nvm install 22.20.0
nvm use 22.20.0
nvm alias default 22.20.0

# Configure git globally
echo "Configuring git..."
git config --global user.email "haitao.feng@gmail.com"
git config --global user.name "Haitao Feng"

# Clone and build VS Code
echo "Cloning and building VS Code..."
if [ ! -d "$HOME/vscode" ]; then
    git clone https://github.com/fenghaitao/vscode.git -b proxy $HOME/vscode
fi

cd $HOME/vscode
source setup-proxy.sh
npm install -g node-gyp
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm ci
npx playwright install chromium
npm run compile

# Install uv (Python package manager)
echo "Installing uv (Python package manager)..."
if [ ! -d "$HOME/.local/bin" ] || [ ! -f "$HOME/.local/bin/uv" ]; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> $HOME/.profile
fi

# Install Atlassian CLI (acli)
echo "Installing Atlassian CLI..."
cd $HOME
if [ ! -f "$HOME/acli" ]; then
    curl -LO "https://acli.atlassian.com/linux/latest/acli_linux_amd64/acli"
    chmod +x acli
fi

# Clone the coder repository and install extensions
echo "Cloning coder repository and installing extensions..."
if [ ! -d "$HOME/coder" ]; then
    git clone https://github.com/fenghaitao/coder.git $HOME/coder
fi

code-server --install-extension $HOME/coder/vsix/ms-python.python-2024.8.1.vsix
code-server --install-extension $HOME/coder/vsix/ms-vscode.cpptools-1.7.1.vsix
code-server --install-extension $HOME/coder/vsix/ms-vscode.cpptools-extension-pack-1.3.1.vsix

# Clone vscode-copilot-chat repository and build VSIX
echo "Cloning and building vscode-copilot-chat..."
if [ ! -d "$HOME/vscode-copilot-chat" ]; then
    git clone https://github.com/fenghaitao/vscode-copilot-chat.git $HOME/vscode-copilot-chat
fi

cd $HOME/vscode-copilot-chat
source setup-proxy.sh
PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 npm install
npm run compile
npm run package -- --allow-package-secrets sendgrid
npx playwright install chromium

# Create startup script
echo "Creating startup script..."
cat > $HOME/start-vscode-server.sh << 'SCRIPT_EOF'
#!/bin/bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export VSCODE_SERVER_PORT=${PORT:-7860}
cd $HOME/vscode
exec bash scripts/code-server.sh --host 0.0.0.0 --port ${VSCODE_SERVER_PORT} --without-connection-token --accept-server-license-terms "$@"
SCRIPT_EOF

chmod +x $HOME/start-vscode-server.sh

echo "Development environment setup complete!"
echo "Please run 'source ~/.bashrc' or restart your shell to use the new tools."
