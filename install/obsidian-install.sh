#!/usr/bin/env bash

# Proxmox Obsidian Headless Installer (Docker Version)
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Docker"
$STD apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | $STD gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" >/etc/apt/sources.list.d/docker.list
$STD apt-get update
$STD apt-get install -y docker-ce docker-ce-cli containerd.io
msg_ok "Installed Docker"

msg_info "Setting up Obsidian Remote directories"
mkdir -p /opt/obsidian/vaults /opt/obsidian/config
msg_ok "Created directories for vaults and config"

msg_info "Running Obsidian Remote Docker container"
docker run -d \
  --name obsidian-remote \
  -v /opt/obsidian/vaults:/vaults \
  -v /opt/obsidian/config:/config \
  -p 8080:8080 \
  ghcr.io/sytone/obsidian-remote:latest
msg_ok "Started Obsidian Remote Docker container"

msg_info "Creating Systemd Service for Obsidian Remote"
cat <<EOF >/etc/systemd/system/obsidian-remote.service
[Unit]
Description=Obsidian Remote Headless (Docker)
After=docker.service
Requires=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a obsidian-remote
ExecStop=/usr/bin/docker stop -t 2 obsidian-remote

[Install]
WantedBy=multi-user.target
EOF

$STD systemctl daemon-reload
$STD systemctl enable obsidian-remote
$STD systemctl start obsidian-remote
msg_ok "Created and started systemd service for Obsidian Remote"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
