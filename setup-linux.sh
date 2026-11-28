#!/bin/sh
set -eu

# ------------------------------------------------------------------------------
# Configuration variables
# ------------------------------------------------------------------------------
REPO_RAW_BASE="https://raw.githubusercontent.com/OpaliteArchitect/kanata-colemak-dh/main"
KANATA_RELEASE_ZIP="https://github.com/jtroo/kanata/releases/latest/download/linux-binaries-x64.zip"

CONFIG_DIR="$HOME/.config/kanata"
BIN_DIR="$HOME/.local/bin"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SYSTEMD_USER_DIR/kanata.service"

TMP_DIR="/tmp/kanata-setup.$$"

# ------------------------------------------------------------------------------
# Cleanup & sudo session setup (supports curl ... | sh via /dev/tty)
# ------------------------------------------------------------------------------
SUDO_KEEPALIVE_PID=""

cleanup() {
  if [ -n "$SUDO_KEEPALIVE_PID" ]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

if ! sudo -n true 2>/dev/null; then
  echo "Enter your password for sudo:" > /dev/tty
  sudo -v < /dev/tty
fi

# Refresh sudo timestamp in the background while the script runs
(
  while true; do
    sleep 50
    sudo -n -v 2>/dev/null || exit 0
  done
) &
SUDO_KEEPALIVE_PID=$!

# ------------------------------------------------------------------------------
# Download Kanata binary and linux.kbd to temporary directory
# ------------------------------------------------------------------------------
mkdir -p "$TMP_DIR" "$CONFIG_DIR" "$BIN_DIR" "$SYSTEMD_USER_DIR"

curl -fssL "$KANATA_RELEASE_ZIP" -o "$TMP_DIR/kanata.zip"
unzip -q "$TMP_DIR/kanata.zip" -d "$TMP_DIR/extracted"

curl -fssL "$REPO_RAW_BASE/linux.kbd" -o "$TMP_DIR/linux.kbd"

# ------------------------------------------------------------------------------
# Install binary and keymap into user directories
# ------------------------------------------------------------------------------
chmod +x "$TMP_DIR/extracted/kanata_linux_x64"
mv "$TMP_DIR/extracted/kanata_linux_x64" "$BIN_DIR/kanata"
mv "$TMP_DIR/linux.kbd" "$CONFIG_DIR/linux.kbd"

# ------------------------------------------------------------------------------
# Configure uinput group, permissions, and kernel module
# ------------------------------------------------------------------------------
sudo groupdel uinput 2>/dev/null || true
sudo groupadd --system uinput

sudo usermod -aG input,uinput "$USER"

printf '%s\n' "uinput" | sudo tee /etc/modules-load.d/uinput.conf > /dev/null
sudo modprobe uinput

sudo tee /etc/udev/rules.d/99-input.rules > /dev/null <<'EOF'
KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
EOF

sudo udevadm control --reload-rules && sudo udevadm trigger

# ------------------------------------------------------------------------------
# Create and enable systemd user service
# ------------------------------------------------------------------------------
cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata
After=default.target

[Service]
Environment=PATH=$BIN_DIR:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin
Type=simple
ExecStart=$BIN_DIR/kanata --cfg %h/.config/kanata/linux.kbd
Restart=on-failure
RestartSec=2

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now kanata.service
systemctl --user status kanata.service --no-pager || true
