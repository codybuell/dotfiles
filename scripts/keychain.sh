#!/bin/bash
#
# Setup Mail Application Passwords in OSX Keychain
#
# Usage: make keychain
#        scripts/keychain.sh

source "${BASH_SOURCE%/*}/library.sh"
read_config

function setup_keychain_entry() {
  local acc_caps="$1"
  local host_var="${acc_caps}EmailHost"
  local keychain_var="${acc_caps}EmailKeychain"
  local user_var="${acc_caps}EmailUsername"

  local host="${!host_var}"
  local keychain="${!keychain_var}"
  local username="${!user_var}"

  if [[ -z "$host" || -z "$keychain" || -z "$username" ]]; then
    log yellow "Skipping ${acc_caps}: missing configuration"
    return
  fi

  echo -n "Enter password for ${acc_caps} (${username}): "
  read -rs password
  echo

  security add-generic-password -a "$keychain" -s "$host" -w "$password" -l "Mail Account: ${acc_caps}" -U
  log green "Keychain entry created for ${acc_caps}"
}

for acc in "Home" "Work" "Proj"; do
  echo -n "Do you want to setup ${acc}? [y/N]: "
  read -r reply
  if [[ "$reply" =~ ^[Yy]$ ]]; then
    setup_keychain_entry "$acc"
  else
    log yellow "Skipping ${acc} setup."
  fi
done
