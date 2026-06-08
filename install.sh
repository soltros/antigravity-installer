#!/usr/bin/env bash

# Installation and update script for Antigravity on Linux
# Run this script with root privileges (e.g., sudo) to install or update the IDE system-wide.

set -e

if [ -z "$1" ]; then
    echo "Usage: sudo $0 /path/to/Antigravity.tar.gz"
    exit 1
fi

TAR_FILE="$1"

if [ ! -f "$TAR_FILE" ]; then
    echo "Error: File '$TAR_FILE' not found."
    exit 1
fi

# Ensure the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root (e.g. sudo ./install.sh \"$TAR_FILE\")."
  exit 1
fi

APP_NAME="Antigravity"
APP_EXEC="antigravity"
INSTALL_DIR="/opt/antigravity"
BIN_LINK="/usr/local/bin/antigravity"
DESKTOP_FILE="/usr/share/applications/antigravity.desktop"

echo "Extracting '$TAR_FILE'..."
TEMP_DIR=$(mktemp -d)

# Ensure the temporary directory is cleaned up on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

tar -xzf "$TAR_FILE" -C "$TEMP_DIR"

# Find the chrome-sandbox file to reliably locate the root of the extracted files.
# The tarball contains thousands of files; 'chrome-sandbox' is a unique file
# at the root of the application directory.
CHROME_SANDBOX=$(find "$TEMP_DIR" -type f -name "chrome-sandbox" | head -n 1)

if [ -z "$CHROME_SANDBOX" ]; then
    echo "Error: Could not find 'chrome-sandbox' inside the archive. Is this a valid IDE package?"
    exit 1
fi

# The directory containing chrome-sandbox is the root of the application
EXTRACTED_DIR=$(dirname "$CHROME_SANDBOX")

echo "Installing $APP_NAME to $INSTALL_DIR..."

# Clear the old installation if it exists to cleanly apply updates
if [ -d "$INSTALL_DIR" ]; then
    echo "Removing previous installation..."
    rm -rf "$INSTALL_DIR"
fi

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Copy all extracted files to the installation directory
cp -a "$EXTRACTED_DIR/"* "$INSTALL_DIR/"

# Ensure the main executable has execute permissions
if [ -f "$INSTALL_DIR/$APP_EXEC" ]; then
    chmod +x "$INSTALL_DIR/$APP_EXEC"
fi

# Chrome sandbox needs to be owned by root and have the SUID bit set
if [ -f "$INSTALL_DIR/chrome-sandbox" ]; then
    chown root:root "$INSTALL_DIR/chrome-sandbox"
    chmod 4755 "$INSTALL_DIR/chrome-sandbox"
fi

echo "Creating symlink in $BIN_LINK..."
# Link to the bin/ wrapper if it exists, otherwise the main binary
if [ -f "$INSTALL_DIR/bin/$APP_EXEC" ]; then
    chmod +x "$INSTALL_DIR/bin/$APP_EXEC"
    ln -sf "$INSTALL_DIR/bin/$APP_EXEC" "$BIN_LINK"
else
    ln -sf "$INSTALL_DIR/$APP_EXEC" "$BIN_LINK"
fi

echo "Creating desktop shortcut..."
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=$APP_NAME
Comment=Antigravity IDE
Exec=$INSTALL_DIR/$APP_EXEC %U
Icon=antigravity
Type=Application
Categories=Development;IDE;
Terminal=false
StartupWMClass=Antigravity
EOF

# Ensure the desktop file has proper permissions
chmod 644 "$DESKTOP_FILE"

# Update desktop database if the command exists (standard across most Linux desktop environments)
if command -v update-desktop-database &> /dev/null; then
    echo "Updating desktop database..."
    update-desktop-database /usr/share/applications/
fi

echo "$APP_NAME has been successfully installed!"
echo "All files have been successfully copied to $INSTALL_DIR."
echo "You can now launch it from your application menu or by running '$APP_EXEC' in the terminal."
