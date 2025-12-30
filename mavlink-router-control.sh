#!/bin/bash
# Control script for mavlink-router service
# Usage: ./mavlink-router-control.sh {start|stop|restart|status|logs|enable|disable}

SERVICE_NAME="mavlink-router"

case "$1" in
    start)
        echo "Starting $SERVICE_NAME..."
        sudo systemctl start "$SERVICE_NAME"
        sudo systemctl status "$SERVICE_NAME" --no-pager -l
        ;;
    stop)
        echo "Stopping $SERVICE_NAME..."
        sudo systemctl stop "$SERVICE_NAME"
        echo "Service stopped"
        ;;
    restart)
        echo "Restarting $SERVICE_NAME..."
        sudo systemctl restart "$SERVICE_NAME"
        sleep 2
        sudo systemctl status "$SERVICE_NAME" --no-pager -l
        ;;
    status)
        sudo systemctl status "$SERVICE_NAME" --no-pager -l
        ;;
    logs)
        echo "Showing logs (Ctrl+C to exit)..."
        sudo journalctl -u "$SERVICE_NAME" -f
        ;;
    enable)
        echo "Enabling $SERVICE_NAME to start on boot..."
        sudo systemctl enable "$SERVICE_NAME"
        echo "Service enabled"
        ;;
    disable)
        echo "Disabling $SERVICE_NAME from starting on boot..."
        sudo systemctl disable "$SERVICE_NAME"
        echo "Service disabled"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs|enable|disable}"
        echo ""
        echo "Commands:"
        echo "  start    - Start the mavlink-router service"
        echo "  stop     - Stop the mavlink-router service"
        echo "  restart  - Restart the mavlink-router service"
        echo "  status   - Show service status"
        echo "  logs     - Show and follow service logs"
        echo "  enable   - Enable service to start on boot"
        echo "  disable  - Disable service from starting on boot"
        exit 1
        ;;
esac

exit 0

