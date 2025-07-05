#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/scaled-tech-consulting/ProxmoxVE/main/misc/build.func)

APP="Obsidian"
var_tags="${var_tags:-knowledge-management,note-taking,headless}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-10}"
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
  if ! docker ps | grep -q obsidian-remote; then
    msg_error "No ${APP} Docker container found!"
    exit
  fi
  msg_info "Updating ${APP} Docker container"
  docker pull ghcr.io/sytone/obsidian-remote:latest
  docker stop obsidian-remote
  docker rm obsidian-remote
  docker run -d \
    --name obsidian-remote \
    -v /opt/obsidian/vaults:/vaults \
    -v /opt/obsidian/config:/config \
    -p 8080:8080 \
    ghcr.io/sytone/obsidian-remote:latest
  msg_ok "Updated and restarted ${APP} Docker container"
  exit 0
}

start
build_container
description

msg_ok "Obsidian Remote Docker container is running and set to autostart.\n"
echo -e "${INFO}${YW} Access it in your browser at:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:8080${CL}"
