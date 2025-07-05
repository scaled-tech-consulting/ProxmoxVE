#!/usr/bin/env bash

# Copyright (c) 2021-2025 scaled-tech-consulting ORG
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

msg_info "Installing Dependencies"
$STD apt-get install -y \
  apt-transport-https \
  ca-certificates \
  wget \
  gpg
msg_ok "Installed Dependencies"

msg_info "Setting up Obsidian Repository"
wget -qO - https://repo.obsidian.md/obsidian.asc | gpg --dearmor >/etc/apt/trusted.gpg.d/obsidian.gpg
echo "deb [arch=amd64] https://repo.obsidian.md stable main" >/etc/apt/sources.list.d/obsidian.list
msg_ok "Setup Obsidian Repository"

msg_info "Installing Obsidian"
$STD apt-get update
$STD apt-get install -y obsidian
msg_ok "Installed Obsidian"

msg_info "Configuring Obsidian Service"
cat <<EOF >/etc/systemd/system/obsidian.service
[Unit]
Description=Obsidian Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/obsidian --server --port=8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

$STD systemctl daemon-reload
$STD systemctl enable obsidian
$STD systemctl start obsidian
msg_ok "Configured and Started Obsidian Service"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
