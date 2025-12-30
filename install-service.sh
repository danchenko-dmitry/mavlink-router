#!/bin/bash
# Install mavlink-router as a systemd service on Raspberry Pi

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_FILE="mavlink-router.service"
SERVICE_NAME="mavlink-router"
CONFIG_DIR="/etc/mavlink-router"
CONFIG_FILE="$CONFIG_DIR/main.conf"
BINARY_PATH="$HOME/mavlink-router/build/src/mavlink-routerd"
SYSTEMD_DIR="/etc/systemd/system"

echo "=== MAVLink Router Service Installer ==="
echo ""

# Check if running as root for systemd operations
if [ "$EUID" -ne 0 ]; then 
    echo "This script needs sudo privileges to install the service."
    echo "Please run: sudo $0"
    exit 1
fi

# Check if binary exists
if [ ! -f "$BINARY_PATH" ]; then
    echo "ERROR: Binary not found at $BINARY_PATH"
    echo "Please build mavlink-router first:"
    echo "  cd ~/mavlink-router && ninja -C build"
    exit 1
fi

# Make binary executable
chmod +x "$BINARY_PATH"
echo "✓ Binary is executable"

# Create config directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
    echo "✓ Created config directory: $CONFIG_DIR"
fi

# Copy config file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    if [ -f "$SCRIPT_DIR/mavlink-router-rpi.conf" ]; then
        cp "$SCRIPT_DIR/mavlink-router-rpi.conf" "$CONFIG_FILE"
        echo "✓ Installed config file: $CONFIG_FILE"
    else
        echo "WARNING: Config file not found. Please create $CONFIG_FILE manually"
    fi
else
    echo "✓ Config file already exists: $CONFIG_FILE"
fi

# Get the actual user (not root)
ACTUAL_USER=$(logname 2>/dev/null || echo "${SUDO_USER:-$USER}")
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

# Update service file with actual user and paths
sed -e "s|User=.*|User=$ACTUAL_USER|" \
    -e "s|ExecStart=.*|ExecStart=$ACTUAL_HOME/mavlink-router/build/src/mavlink-routerd -c $CONFIG_FILE|" \
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

