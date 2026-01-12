#!/bin/bash
# Build script for mavlink-router on Raspberry Pi
# Usage: ./build-rpi.sh

set -e

cd "$(dirname "$0")"

echo "=== Building mavlink-router on Raspberry Pi ==="
echo ""

# Check if submodules are initialized
if [ ! -d "modules/mavlink_c_library_v2/ardupilotmega" ]; then
    echo "Initializing git submodules..."
    git submodule update --init --recursive
fi

# Clean previous build
echo "Cleaning previous build..."
rm -rf build

# Configure build (using debugoptimized and no systemd if not available)
echo "Configuring build..."
meson setup build . --buildtype=debugoptimized -Dsystemdsystemunitdir=no

if [ $? -ne 0 ]; then
    echo "ERROR: Meson configuration failed"
    exit 1
fi

# Build with single thread to avoid OOM (Raspberry Pi has limited RAM)
echo ""
echo "Building (using -j1 to avoid memory issues)..."
ninja -C build -j1

if [ $? -eq 0 ]; then
    echo ""
    echo "=== Build successful! ==="
    ls -lh build/src/mavlink-routerd
    echo ""
    echo "Binary location: build/src/mavlink-routerd"
    echo ""
    echo "To test it:"
    echo "  ./build/src/mavlink-routerd --help"
else
    echo ""
    echo "ERROR: Build failed"
    exit 1
fi
# some...