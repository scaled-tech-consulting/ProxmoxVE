#!/usr/bin/env bash

# Proxmox Obsidian Installer
# Copyright (c) 2021-2025 community-scripts ORG
# Author: michelroegl-brunner
# License: MIT
# Source: https://obsidian.md

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Removing udisks2 if present (not needed in LXC)"
apt-get purge -y udisks2 || true
msg_ok "Removed udisks2"

msg_info "Preventing udisks2 installation (not needed in LXC)"
apt-mark hold udisks2
msg_ok "Held udisks2 package"

msg_info "Installing Dependencies"
$STD apt-get install -y \
  wget \
  curl \
  xorg \
  xfce4 \
  xfce4-goodies \
  tigervnc-standalone-server \
  dbus-x11
msg_ok "Installed Dependencies"

msg_info "Downloading Obsidian AppImage"
mkdir -p /opt/obsidian
wget -qO /opt/obsidian/Obsidian.AppImage \
  "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.12/Obsidian-1.5.12.AppImage"
chmod +x /opt/obsidian/Obsidian.AppImage
msg_ok "Downloaded Obsidian AppImage"

msg_info "Creating VNC Service"
cat <<EOF >/etc/systemd/system/obsidian-vnc.service
[Unit]
Description=Obsidian VNC Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/vncserver :1 -geometry 1280x800 -depth 24
ExecStop=/usr/bin/vncserver -kill :1

[Install]
WantedBy=multi-user.target
EOF

$STD systemctl daemon-reload
$STD systemctl enable obsidian-vnc
$STD systemctl start obsidian-vnc
msg_ok "Started VNC Server"

msg_info "Creating Startup Script for Obsidian"
mkdir -p /root/.vnc
cat <<EOF >/root/.vnc/xstartup
#!/bin/sh
xrdb \$HOME/.Xresources
startxfce4 &
/opt/obsidian/Obsidian.AppImage &
EOF
chmod +x /root/.vnc/xstartup
msg_ok "Created Startup Script"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
