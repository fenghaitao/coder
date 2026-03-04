#!/bin/bash

# Setup Antigravity URL handler for authentication
# This script creates a desktop entry to handle antigravity:// URLs

APPLICATIONS_DIR="$HOME/.local/share/applications"
DESKTOP_FILE_PATH="$APPLICATIONS_DIR/antigravity.desktop"

# Create applications directory if it doesn't exist
echo "Creating applications directory if it doesn't exist..."
mkdir -p "$APPLICATIONS_DIR"

# Create the desktop entry file
echo "Creating desktop entry file..."
cat > "$DESKTOP_FILE_PATH" << EOF
[Desktop Entry]
Name=Antigravity
Comment=Antigravity application
Exec=/nfs/site/home/${USERNAME}/coder/Antigravity/antigravity --open-url %U
Icon=/nfs/site/home/${USERNAME}/coder/Antigravity/resources/app/resources/linux/antigravity.png
Type=Application
StartupNotify=true
StartupWMClass=antigravity
Categories=Utility;TextEditor;Development;IDE;
MimeType=x-scheme-handler/antigravity;
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

# Set Antigravity as default handler for antigravity:// URLs
echo "Setting Antigravity as default handler for antigravity:// URLs..."
if xdg-mime default antigravity.desktop x-scheme-handler/antigravity 2>/dev/null; then
    echo "  ✓ Set default for x-scheme-handler/antigravity"
else
    echo "  ✗ Failed to set default for x-scheme-handler/antigravity"
fi

echo ""
echo "Antigravity URL handler configuration completed!"
echo "Antigravity will now handle antigravity:// URLs for authentication."
