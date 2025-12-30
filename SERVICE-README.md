# MAVLink Router Service Setup Guide

## Files Created

1. **mavlink-router.service** - Systemd service file
2. **install-service.sh** - Installation script
3. **mavlink-router-control.sh** - Service control script

## Installation

### Step 1: Copy files to Raspberry Pi

```bash
# From your local machine
scp mavlink-router.service install-service.sh mavlink-router-control.sh mavlink-router-rpi.conf rpi:~/mavlink-router/
```

### Step 2: Install the service

```bash
# On Raspberry Pi
cd ~/mavlink-router
sudo ./install-service.sh
```

The installation script will:
- Check if the binary exists
- Create `/etc/mavlink-router/` directory
- Copy the config file
- Install the systemd service
- Add user to dialout group
- Reload systemd

## Using the Service

### Control Script (Recommended)

```bash
cd ~/mavlink-router

# Start the service
./mavlink-router-control.sh start

# Stop the service
./mavlink-router-control.sh stop

# Restart the service (use this after changing config)
./mavlink-router-control.sh restart

# Check status
./mavlink-router-control.sh status

# View logs (live)
./mavlink-router-control.sh logs

# Enable auto-start on boot
./mavlink-router-control.sh enable

# Disable auto-start on boot
./mavlink-router-control.sh disable
```

### Direct systemctl Commands

```bash
# Start
sudo systemctl start mavlink-router

# Stop
sudo systemctl stop mavlink-router

# Restart
sudo systemctl restart mavlink-router

# Status
sudo systemctl status mavlink-router

# Enable on boot
sudo systemctl enable mavlink-router

# Disable on boot
sudo systemctl disable mavlink-router

# View logs
sudo journalctl -u mavlink-router -f
```

## Changing Configuration

1. Edit the config file:
   ```bash
   sudo nano /etc/mavlink-router/main.conf
   ```

2. Restart the service:
   ```bash
   ./mavlink-router-control.sh restart
   # or
   sudo systemctl restart mavlink-router
   ```

3. Check if it's working:
   ```bash
   ./mavlink-router-control.sh status
   ./mavlink-router-control.sh logs
   ```

## Troubleshooting

### Service won't start
- Check logs: `sudo journalctl -u mavlink-router -n 50`
- Verify binary exists: `ls -lh ~/mavlink-router/build/src/mavlink-routerd`
- Check config: `sudo cat /etc/mavlink-router/main.conf`
- Verify UART permissions: `groups | grep dialout`

### Permission denied on UART
- Make sure user is in dialout group: `groups | grep dialout`
- If not, run: `sudo usermod -a -G dialout $USER`
- Log out and back in, or run: `newgrp dialout`

### Service keeps restarting
- Check logs for errors: `sudo journalctl -u mavlink-router -n 100`
- Verify UART device exists: `ls -la /dev/ttyAMA0`
- Check if another process is using the UART

## Configuration File Location

- Main config: `/etc/mavlink-router/main.conf`
- Edit with: `sudo nano /etc/mavlink-router/main.conf`

## Service Details

- **Service name**: `mavlink-router`
- **User**: Your username (set automatically)
- **Group**: `dialout` (for UART access)
- **Restart**: Always (auto-restarts on failure)
- **Logs**: Systemd journal (`journalctl`)

