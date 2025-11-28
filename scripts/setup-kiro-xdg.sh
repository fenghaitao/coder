#!/bin/bash

# Setup Kiro URL handler for authentication
# This script creates a desktop entry to handle kiro:// URLs

APPLICATIONS_DIR="$HOME/.local/share/applications"
DESKTOP_FILE_PATH="$APPLICATIONS_DIR/kiro.desktop"

# Create applications directory if it doesn't exist
echo "Creating applications directory if it doesn't exist..."
mkdir -p "$APPLICATIONS_DIR"

# Create the desktop entry file
echo "Creating desktop entry file..."
cat > "$DESKTOP_FILE_PATH" << EOF
[Desktop Entry]
Name=Kiro
Comment=AI-powered IDE for developers
Exec=/nfs/site/home/${USERNAME}/coder/Kiro/kiro --open-url %U
Icon=/nfs/site/home/${USERNAME}/coder/Kiro/resources/app/resources/linux/kiro.png
Type=Application
StartupNotify=true
StartupWMClass=kiro
Categories=Utility;TextEditor;Development;IDE;
MimeType=x-scheme-handler/kiro;
EOF

# Make the desktop entry executable
echo "Making desktop entry executable..."
chmod +x "$DESKTOP_FILE_PATH"

# Update desktop database
echo "Updating desktop database..."
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$APPLICATIONS_DIR"
    echo "Desktop database updated successfully."
else
    echo "WARNING: update-desktop-database not found. Desktop entry may not be immediately available."
fi

# Set Kiro as default handler for kiro:// URLs
echo "Setting Kiro as default handler for kiro:// URLs..."
if xdg-mime default kiro.desktop x-scheme-handler/kiro 2>/dev/null; then
    echo "  ✓ Set default for x-scheme-handler/kiro"
else
    echo "  ✗ Failed to set default for x-scheme-handler/kiro"
fi

echo ""
echo "Kiro URL handler configuration completed!"
echo "Kiro will now handle kiro:// URLs for authentication."
