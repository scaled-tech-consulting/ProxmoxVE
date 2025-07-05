#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: michelroegl-brunner
# License: MIT
# Source: https://obsidian.md

APP="Obsidian"
var_tags="${var_tags:-knowledge-management,note-taking}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-2048}"
var_disk="${var_disk:-5}"
var_os="${var_os:-debian}"
var_version="${var_version:-12}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -f /opt/obsidian/Obsidian.AppImage ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  msg_info "Updating ${APP}"
  $STD wget -qO /opt/obsidian/Obsidian.AppImage \
    "https://github.com/obsidianmd/obsidian-releases/releases/latest/download/Obsidian.AppImage"
  chmod +x /opt/obsidian/Obsidian.AppImage
  msg_ok "Updated ${APP}"
  exit 0
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using VNC at:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}vnc://${IP}:5901${CL}"
