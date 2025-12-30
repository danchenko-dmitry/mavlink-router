#!/bin/bash
# Script to push mavlink-router service files to Raspberry Pi

RPI_HOST="${1:-rpi}"  # Use first argument or default to "rpi"
RPI_PATH="~/mavlink-router"

echo "=== Pushing MAVLink Router Service Files to Raspberry Pi ==="
echo "Target: $RPI_HOST:$RPI_PATH"
echo ""

# Files to push
FILES=(
    "mavlink-router.service"
    "install-service.sh"
    "mavlink-router-control.sh"
    "mavlink-router-rpi.conf"
    "SERVICE-README.md"
)

# Check if files exist
MISSING_FILES=()
for file in "${FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -ne 0 ]; then
    echo "ERROR: Missing files:"
    for file in "${MISSING_FILES[@]}"; do
        echo "  - $file"
    done
    exit 1
fi

# Push files
echo "Pushing files..."
scp "${FILES[@]}" "${RPI_HOST}:${RPI_PATH}/"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Files pushed successfully!"
    echo ""
    echo "Next steps on Raspberry Pi:"
    echo "  1. ssh $RPI_HOST"
    echo "  2. cd ~/mavlink-router"
    echo "  3. sudo ./install-service.sh"
    echo "  4. ./mavlink-router-control.sh start"
    echo ""
    echo "Or run the install script remotely:"
    echo "  ssh $RPI_HOST 'cd ~/mavlink-router && sudo ./install-service.sh'"
else
    echo ""
    echo "ERROR: Failed to push files"
    exit 1
fi

