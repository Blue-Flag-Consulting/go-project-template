#!/bin/bash
set -e

SERVICE_NAME="jf-aperture-daemon.service"

# Check if the service exists
if systemctl list-unit-files --type=service | grep -q "^${SERVICE_NAME}"; then
    echo "Service ${SERVICE_NAME} exists."

    # Stop the service if it's running
    if systemctl is-active --quiet ${SERVICE_NAME}; then
        echo "Stopping ${SERVICE_NAME}..."
        systemctl stop ${SERVICE_NAME}
    else
        echo "Service ${SERVICE_NAME} is not running."
    fi

    # Disable the service
    echo "Disabling ${SERVICE_NAME}..."
    systemctl disable ${SERVICE_NAME}

    # Reload systemd daemon
    echo "Reloading systemd daemon..."
    systemctl daemon-reload
else
    echo "Service ${SERVICE_NAME} does not exist."
fi