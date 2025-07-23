#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2025
# Author: Raven-98

## Використання: bash -c "$(curl -fsSL https://raw.githubusercontent.com/Raven-98/helper-scripts/refs/heads/main/create-salt-minion.sh)"

APP="Salt Minion"
var_tags="${var_tags:-os}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-ubuntu}"
var_version="${var_version:-24.04}"
var_unprivileged="${var_unprivileged:-1}"
var_install="ubuntu-install"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /var ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi
  msg_info "Updating ${APP} LXC"
  $STD apt-get update
  $STD apt-get -y upgrade
  msg_ok "Updated ${APP} LXC"
  exit
}

function post_create() {
  msg_info "Installing Salt Minion inside container..."
  $LXC exec bash -c "
    apt-get update &&
    apt-get install -y curl gnupg &&
    mkdir -p /etc/apt/keyrings &&
    curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | tee /etc/apt/keyrings/salt-archive-keyring.pgp &&
    curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | tee /etc/apt/sources.list.d/salt.sources &&
    apt-get update &&
    apt-get install -y salt-minion &&
    systemctl enable salt-minion &&
    systemctl start salt-minion
  "
  msg_ok "Salt Minion installed and started."
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
