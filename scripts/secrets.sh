#!/bin/bash
#
# Copy API tokens from 1Password into the OSX keychain
#
# The shell reads these from the keychain rather than 1Password because the
# 1Password CLI's desktop app integration authorizes per shell session: every
# new terminal pops an approval window, which is unusable for values needed at
# shell startup. The keychain prompts once (choose "Always Allow") and is
# silent thereafter.
#
# 1Password stays the system of record. Re-run this after rotating a key.
#
# Usage: make secrets
#        scripts/secrets.sh

source "${BASH_SOURCE%/*}/library.sh"
read_config

# env var name -> `<op item uuid>:<field>:<keychain service>` from .config
SECRETS=(
  GitHubHomebrewAPIToken
  OpenAIAPIKey
  AnthropicAPIKey
)

if ! command -v op > /dev/null 2>&1; then
  log red "1password cli (op) not found" "install it with: brew install --cask 1password-cli"
  exit 1
fi

if [[ -z "$SecretsVault" ]]; then
  log red "SecretsVault not set in .config" "cannot look up items"
  exit 1
fi

log blue "seeding keychain from 1password (vault: ${SecretsVault})..."
echo

for var in "${SECRETS[@]}"; do
  spec="${!var}"

  if [[ -z "$spec" ]]; then
    log yellow "  ${var}" "not configured in .config, skipping"
    continue
  fi

  # split on ':' -- the field name may contain spaces ("api key") but not colons
  IFS=':' read -r item field service <<< "$spec"
  if [[ -z "$item" || -z "$field" || -z "$service" ]]; then
    log red "  ${var}" "malformed spec '${spec}', want <uuid>:<field>:<service>"
    continue
  fi

  if ! value="$(op read "op://${SecretsVault}/${item}/${field}" 2> /dev/null)"; then
    log red "  ${var}" "op read failed for ${item}/${field}"
    continue
  fi

  if [[ -z "$value" ]]; then
    log red "  ${var}" "1password returned an empty value"
    continue
  fi

  # -U updates in place when the entry already exists
  if security add-generic-password -a "$USER" -s "$service" -w "$value" \
       -l "API Token: ${service}" -U > /dev/null 2>&1; then
    log green "  ${var}" "stored as '${service}'"
  else
    log red "  ${var}" "failed to write keychain entry '${service}'"
  fi
done

echo
log blue "done." "the first read from each entry prompts once; choose 'Always Allow'"
