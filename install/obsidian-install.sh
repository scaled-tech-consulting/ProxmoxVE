#!/usr/bin/env bash

# Proxmox Obsidian Headless Installer (GitHub Clone Fix)
source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies (Node.js, git)"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
$STD apt-get install -y nodejs git wget curl
msg_ok "Installed Dependencies"

msg_info "Downloading Obsidian AppImage"
mkdir -p /opt/obsidian
wget -qO /opt/obsidian/Obsidian.AppImage \
  "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.12/Obsidian-1.5.12.AppImage"
chmod +x /opt/obsidian/Obsidian.AppImage
msg_ok "Downloaded Obsidian AppImage"

msg_info "Installing Obsidian-Remote (GitHub clone)"
git clone https://github.com/sytone/obsidian-remote.git /opt/obsidian-remote
if [[ -d "/opt/obsidian-remote/remote" ]]; then
  cd /opt/obsidian-remote/remote || exit
else
  cd /opt/obsidian-remote || exit
fi
npm install
msg_ok "Installed Obsidian-Remote"

msg_info "Creating Systemd Service for Obsidian Headless"
cat <<EOF >/etc/systemd/system/obsidian.service
[Unit]
Description=Obsidian Remote Headless Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/node /opt/obsidian-remote/remote/index.js --appimage /opt/obsidian/Obsidian.AppImage --port 8080 --host 0.0.0.0
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

$STD systemctl daemon-reload
$STD systemctl enable obsidian
$STD systemctl start obsidian
msg_ok "Started Obsidian Headless Server"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
