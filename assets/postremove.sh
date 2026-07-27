#!/bin/bash
set -e

USER="aperture"
GROUP="aperture"
CONFIG_DIR="/etc/aperture"
DATA_DIR="/var/lib/aperture"

# Only take destructive action on purge
if [ "$1" = "purge" ]; then
    echo "Purging config and data..."

    # Remove config files
    if [ -d "$CONFIG_DIR" ]; then
        echo "Removing $CONFIG_DIR..."
        rm -rf "$CONFIG_DIR"
    fi

    # Remove working data (optional)
    if [ -d "$DATA_DIR" ]; then
        echo "Removing $DATA_DIR..."
        rm -rf "$DATA_DIR"
    fi

    # Delete user and group if they exist
    if id -u $USER >/dev/null 2>&1; then
        echo "Removing user $USER..."
        deluser --system $USER || true
    fi

    if getent group $GROUP >/dev/null; then
        echo "Removing group $GROUP..."
        delgroup --system $GROUP || true
    fi
fi
