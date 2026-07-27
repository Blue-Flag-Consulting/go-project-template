#!/bin/bash
set -euo pipefail

SERVICE_NAME="photobooth.service"
MOUNT="media-usb.mount"
AUTOMOUNT="media-usb.automount"
USER="aperture"
GROUP="aperture"
HOME_DIR="/var/lib/aperture"
CONFIG_FILE="/etc/aperture/config.yaml"
GPIO_GROUP="gpio"
USB_GROUP="plugdev"
INPUT_GROUP="input"

# This name is tightly coupled with the .goreleaser build config
LOGIN_USER="photoboothview"

CAPTURE_DIR="$HOME_DIR/captures"
LAYOUTS_DIR="$HOME_DIR/layouts"
COMPLETES_DIR="$HOME_DIR/completed"

USB_WRITABLE="/media/usb"
USB_APP_STORAGE="$USB_WRITABLE/appConfig"
USB_CERTIFICATES="$USB_WRITABLE/certmagic"
USB_LAYOUTS="$USB_WRITABLE/layouts"
USB_COMPLETED="$USB_WRITABLE/completed"

echo "Post-installation script started."

####################################################
#### Users and Groups
####################################################
echo "Setting up user and group..."

# Create system group if it doesn't exist
if ! getent group "$GROUP" >/dev/null; then
  echo "Creating system group: $GROUP"
  addgroup --system "$GROUP"
fi

# Create system user if it doesn't exist
if ! id -u "$USER" >/dev/null 2>&1; then
  echo "Creating system user: $USER"
  adduser --system --ingroup "$GROUP" --home "$HOME_DIR" --no-create-home "$USER"
fi

# Ensure supplemental groups exist and add the user if needed
for G in "$GPIO_GROUP" "$USB_GROUP" "$INPUT_GROUP"; do
  if ! getent group "$G" >/dev/null; then
    echo "Creating system group: $G"
    addgroup --system "$G"
  fi
  if ! id -nG "$USER" | grep -qw "$G"; then
    echo "Adding $USER to $G group..."
    usermod -aG "$G" "$USER"
  else
    echo "$USER is already in the $G group."
  fi
done

echo "Creating application directories..."
mkdir -p "$HOME_DIR"
mkdir -p "$CAPTURE_DIR" "$LAYOUTS_DIR" "$COMPLETES_DIR"

####################################################
#### USB Mount Service
####################################################
echo "Configuring automount for $AUTOMOUNT ($USB_WRITABLE)..."

# Always reload once before checking for units
systemctl daemon-reload

# If a .mount unit exists, ensure it is NOT enabled (automount will trigger it on demand)
if systemctl list-unit-files --type=mount --no-legend --no-pager | awk '{print $1}' | grep -qx "$MOUNT"; then
  if systemctl is-enabled --quiet "$MOUNT"; then
    echo "Disabling $MOUNT so automount can control the mount..."
    systemctl disable "$MOUNT" || true
  fi
fi

# Enable the automount for future boots
if systemctl list-unit-files --type=automount --no-legend --no-pager | awk '{print $1}' | grep -qx "$AUTOMOUNT"; then
  if ! systemctl is-enabled --quiet "$AUTOMOUNT"; then
    echo "Enabling $AUTOMOUNT..."
    systemctl enable "$AUTOMOUNT"
  else
    echo "$AUTOMOUNT is already enabled."
  fi

  # Start the automount now only if the path is NOT already mounted
  if mountpoint -q "$USB_WRITABLE"; then
    echo "$USB_WRITABLE is already mounted; skipping 'start' of $AUTOMOUNT (will take effect after next unmount/reboot)."
  else
    echo "Starting $AUTOMOUNT..."
    systemctl start "$AUTOMOUNT"

    # Trigger the automount by touching the path
    ls -1 "$USB_WRITABLE" >/dev/null 2>&1 || true

    # Wait up to ~30s for the mount to appear
    for i in {1..120}; do   # 120 * 0.25s = 30s
      mountpoint -q "$USB_WRITABLE" && break
      sleep 0.25
    done
  fi
else
  echo "Automount unit $AUTOMOUNT not found. Ensure it's installed to /etc/systemd/system/ and has an [Install] WantedBy=multi-user.target."
fi

# If mounted now, create the USB subdirs
if mountpoint -q "$USB_WRITABLE"; then
  echo "$USB_WRITABLE is mounted; creating app directories on the USB..."
  mkdir -p "$USB_APP_STORAGE" "$USB_CERTIFICATES" "$USB_LAYOUTS" "$USB_COMPLETED"
else
  echo "WARNING: $USB_WRITABLE is not mounted; skipping USB dir creation (will happen on first access at runtime)."
fi

####################################################
#### Permissions
####################################################
echo "Setting permissions..."

# Ensure working directory and config file have correct ownership
chown -R "$USER:$GROUP" "$HOME_DIR"
chown "$USER:$GROUP" "$CONFIG_FILE"

# Optionally tighten up permissions
chmod 750 "$HOME_DIR"
chmod 640 "$CONFIG_FILE"

####################################################
#### Setup PhotoBooth Service
####################################################
# Reload systemd and enable/start the service
echo "Checking for service $SERVICE_NAME..."

if systemctl list-unit-files --type=service | grep -q "^${SERVICE_NAME}"; then
    echo "Service ${SERVICE_NAME} exists."

    echo "Reloading systemd daemon..."
    systemctl daemon-reload

    if ! systemctl is-enabled --quiet ${SERVICE_NAME}; then
        echo "Enabling ${SERVICE_NAME}..."
        systemctl enable ${SERVICE_NAME}
    else
        echo "Service ${SERVICE_NAME} is already enabled."
    fi

    if ! systemctl is-active --quiet ${SERVICE_NAME}; then
        echo "Starting ${SERVICE_NAME}..."
        systemctl start ${SERVICE_NAME}
    else
        echo "Service ${SERVICE_NAME} is already running."
    fi
else
    echo "Service ${SERVICE_NAME} does not exist. Exiting."
fi

####################################################
#### App Permissions
####################################################
setcap cap_net_bind_service=+ep /usr/bin/photobooth

echo "Enabling NetworkManager-wait-online.service..."
systemctl enable NetworkManager-wait-online.service

echo "Setting up bash completion for PhotoBooth"
/usr/bin/photobooth completion bash > /usr/share/bash-completion/completions/photobooth

# restart cups incase the cupsd.conf was modified during the installation
systemctl disable cups-browsed
systemctl stop cups-browsed
systemctl restart cups


####################################################
#### Typst Permissions
####################################################
chmod a+x /usr/bin/typst

####################################################
#### Auto Login Setup
####################################################
if ! id -u "$LOGIN_USER" >/dev/null 2>&1; then
  echo "Creating system user: $LOGIN_USER"
  adduser --gecos "" --disabled-password $LOGIN_USER
  usermod -aG systemd-journal $LOGIN_USER
fi

systemctl daemon-reload

####################################################
#### Link Priority
####################################################
if nmcli -t -f NAME connection show | grep -q "^preconfigured$"; then
    nmcli connection modify "preconfigured" ipv4.route-metric 100
else
    echo "Wi-Fi connection 'preconfigured' not found, skipping"
fi

if nmcli -t -f NAME connection show | grep -q "^Wired connection 1$"; then
    nmcli connection modify "Wired connection 1" ipv4.route-metric 200
else
    echo "Ethernet connection 'Wired connection 1' not found, skipping"
fi

