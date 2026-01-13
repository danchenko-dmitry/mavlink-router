#!/bin/bash
# Install mavlink-router as a systemd service on Raspberry Pi

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_FILE="mavlink-router.service"
SERVICE_NAME="mavlink-router"
CONFIG_DIR="/etc/mavlink-router"
CONFIG_FILE="$CONFIG_DIR/main.conf"
BUILD_BINARY="build/src/mavlink-routerd"
INSTALL_BINARY="/usr/bin/mavlink-routerd"
SYSTEMD_DIR="/etc/systemd/system"

echo "=== MAVLink Router Service Installer ==="
echo ""

# Check if running as root for systemd operations
if [ "$EUID" -ne 0 ]; then 
    echo "This script needs sudo privileges to install the service."
    echo "Please run: sudo $0"
    exit 1
fi

# Get the actual user (not root) to find the source directory
ACTUAL_USER=$(logname 2>/dev/null || echo "${SUDO_USER:-$USER}")
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

# Try to find the build directory
# Check common locations
BUILD_DIR=""
for dir in "$ACTUAL_HOME/mavlink-router" "$ACTUAL_HOME/workspace/src/mavlink-router" "/home/$ACTUAL_USER/mavlink-router"; do
    if [ -f "$dir/$BUILD_BINARY" ]; then
        BUILD_DIR="$dir"
        BUILD_BINARY_PATH="$dir/$BUILD_BINARY"
        break
    fi
done

# If not found, try to find it in current directory
if [ -z "$BUILD_DIR" ] && [ -f "$BUILD_BINARY" ]; then
    BUILD_DIR="$(pwd)"
    BUILD_BINARY_PATH="$BUILD_DIR/$BUILD_BINARY"
fi

# Check if binary exists
if [ -z "$BUILD_DIR" ] || [ ! -f "$BUILD_BINARY_PATH" ]; then
    echo "ERROR: Binary not found at $BUILD_BINARY_PATH"
    echo "Please build mavlink-router first:"
    echo "  cd ~/mavlink-router && ./build-rpi.sh"
    echo ""
    echo "Searched in:"
    echo "  $ACTUAL_HOME/mavlink-router/$BUILD_BINARY"
    echo "  $ACTUAL_HOME/workspace/src/mavlink-router/$BUILD_BINARY"
    echo "  $(pwd)/$BUILD_BINARY"
    exit 1
fi

echo "✓ Found binary at: $BUILD_BINARY_PATH"

# Install binary to /usr/bin
echo "Installing binary to $INSTALL_BINARY..."
cp "$BUILD_BINARY_PATH" "$INSTALL_BINARY"
chmod +x "$INSTALL_BINARY"
echo "✓ Binary installed to $INSTALL_BINARY"

# Create config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
    echo "✓ Created config directory: $CONFIG_DIR"
fi

# Copy config file if it doesn't exist
cp "$SCRIPT_DIR/mavlink-router-rpi.conf" "$CONFIG_FILE"
echo "✓ Installed config file: $CONFIG_FILE"

# Get the actual user (not root)
ACTUAL_USER=$(logname 2>/dev/null || echo "${SUDO_USER:-$USER}")

# Copy service file and replace user placeholder
sed -e "s|User=PLACEHOLDER_USER|User=$ACTUAL_USER|" \
    "$SCRIPT_DIR/$SERVICE_FILE" > "$SYSTEMD_DIR/$SERVICE_NAME.service"

echo "✓ Installed service file: $SYSTEMD_DIR/$SERVICE_NAME.service"

# Ensure user is in dialout group
if ! groups "$ACTUAL_USER" | grep -q dialout; then
    usermod -a -G dialout "$ACTUAL_USER"
    echo "✓ Added user $ACTUAL_USER to dialout group"
    echo "  NOTE: User may need to log out and back in for group changes to take effect"
else
    echo "✓ User $ACTUAL_USER is already in dialout group"
fi

# Reload systemd
systemctl daemon-reload
echo "✓ Reloaded systemd daemon"

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Service installed successfully!"
echo ""
echo "To start the service:"
echo "  sudo systemctl start $SERVICE_NAME"
echo ""
echo "To enable auto-start on boot:"
echo "  sudo systemctl enable $SERVICE_NAME"
echo ""
echo "To check status:"
echo "  sudo systemctl status $SERVICE_NAME"
echo ""
echo "To view logs:"
echo "  sudo journalctl -u $SERVICE_NAME -f"
echo ""

