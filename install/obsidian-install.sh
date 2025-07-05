#!/usr/bin/env bash

# Proxmox Obsidian Headless Installer
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

msg_info "Installing Dependencies (Node.js, Obsidian-Remote)"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
$STD apt-get install -y nodejs wget curl git
msg_ok "Installed Dependencies"

msg_info "Downloading Obsidian AppImage"
mkdir -p /opt/obsidian
wget -qO /opt/obsidian/Obsidian.AppImage \
  "https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.12/Obsidian-1.5.12.AppImage"
chmod +x /opt/obsidian/Obsidian.AppImage
msg_ok "Downloaded Obsidian AppImage"

msg_info "Installing Obsidian-Remote"
git clone https://github.com/getobin/obsidian-remote.git /opt/obsidian-remote
cd /opt/obsidian-remote || exit
npm install
msg_ok "Installed Obsidian-Remote"

msg_info "Creating Systemd Service for Headless Obsidian"
cat <<EOF >/etc/systemd/system/obsidian.service
[Unit]
Description=Obsidian Remote Headless Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/node /opt/obsidian-remote/index.js --appimage /opt/obsidian/Obsidian.AppImage --port 8080 --host 0.0.0.0
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
msg_ok "Obsidian Headless Installation Completed Successfully!"
echo -e "${CREATING}${GN}Obsidian Headless setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using VNC at:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"
echo -e "${INFO}${YW} Use the Obsidian Remote app to connect to your Obsidian instance.${CL}"
echo -e "${INFO}${YW} For more information, visit:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}https://obsidian.md/help/Obsidian_Remote${CL}"
echo -e "${INFO}${YW} Enjoy your Obsidian experience!${CL}"
exit 0
