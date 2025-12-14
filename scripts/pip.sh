#!/bin/bash
#
# Pip
#
# Install pip packages to support dotfiles and base level system configs.
# Assumes Python 3 only but keeps Python 2 code around and commented out in
# case it is needed for some odd reason.
#
# Author(s): Cody Buell
#
# Requisite: Python3
#
# Tasks:
#
# Usage: make pip
#        ./pip.sh

# shellcheck source=./library.sh
source "${BASH_SOURCE%/*}/library.sh"

###################
#                 #
#  package lists  #
#                 #
###################

# standard Python 3 packages
PYTHON3=( \
    'browsercookie' \                  # for getting browser cookies with cookiemonster via cli
    'click' \                          # required for mattermost auth cookie gathering script
    'feedparser' \                     # rss support for weechat plugin
    'jmespath-terminal' \              # json manipulation and parsing tool (run as `jpterm`)
    'neovim' \                         # neovim client, required to use python with neovim
    'pync' \                           # wequired for weechat plugins
    'pynvim' \                         # neovim client, required to use python with neovim
    'selenium' \                       # same as click
    'websocket-client' \               # required for wee-slack weechat plugin
    'python-lsp-server[all]' \         # a better python language server than pyls??
    'c7n c7n-azure c7n-gcp c7n-org' \  # cloud custodian bits
)

# osx specific python 3 packages
OSXPYTHON3=( \
    'pync' \                           # required for notification-center.py weechat plugin
)

# new package manager that will expose executables
UV=( \
  'rshell' \                           # shell for remote devices over serial
  'ansible-core' \                     # cm utility
  'vectorcode<1.0.0' \                 # vectorcode https://github.com/Davidyz/VectorCode/
)

#######################
#                     #
#  run installations  #
#                     #
#######################

# handle m1 mac architecture: https://stackoverflow.com/questions/66640705/how-can-i-install-grpcio-on-an-apple-m1-silicon-laptop
if [ "$(/usr/bin/uname -m)" == "arm64" ] || [ "$(/usr/bin/uname -m)" = "x86_64" -a "$(/usr/sbin/sysctl -in sysctl.proc_translated)" = "1" ]; then
  export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
  export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1
fi

# install python3 packages
# shellcheck disable=SC2068
for i in ${PYTHON3[@]}; do
  pip3 install "$i"
done

# osx specific installs
if [ "$(uname -s)" = 'Darwin' ]; then
  # shellcheck disable=SC2068
  for i in ${OSXPYTHON3[@]}; do
    pip3 install "$i"
  done
fi

# uv package installs
# shellcheck disable=SC2068
for i in ${UV[@]}; do
  uv tool install "$i"
done

exit 0
