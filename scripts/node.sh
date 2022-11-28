#!/bin/bash
#
# Node
#
# Install Node Verion Manager, the latest LTS version of Node, and a slew of
# global npm packages. For more information on NVM, see:
#
#  - https://github.com/nvm-sh/nvm
#
# To update NVM:
#
#  `nvm install node --reinstall-packages-from=node`
#
# Author(s): Cody Buell
#
# Requisite: - `make dots shell profile bashrc zshrc` (for usage after)
#
# Tasks:
#
# Usage: make node
#        ./node.sh

# shellcheck source=./library.sh
source "${BASH_SOURCE%/*}/library.sh"

PRIMARY_USER=$(whoami)
PRIMARY_USER_HOME=$HOME

################################################################################
#                                                                              #
#  Configuration                                                               #
#                                                                              #
################################################################################

PACKAGES=( \
  'asciicast2gif' \                        # asciinema json files to gifs
  'bower' \                                # web dev vendoring utility
  'cfn-lint' \                             # aws cloudformation linting
  'gistup' \                               # gists creation utility
  'gitlab-ci-lint' \                       # linting of gitlab ci files
  'gulp' \                                 # web dev asset compiler
  'http-server' \                          # light-weight dev web server
  'neovim' \                               # node provider for neovim
  'topojson' \                             # shape files into json for d3
  '@mapbox/togeojson' \                    # gpx / kml to geojson converter
  'jsonlint' \                             # json syntax checking utility
  'svgo' \                                 # svg optimization utility
  'typescript' \                           # dep for typescript-language-server
  'wscat' \                                # websocket command line client
  'yarn' \                                 # better node package manager
  'bash-language-server' \                 # bash language server
  'vscode-json-languageserver' \           # json language server
  'dockerfile-language-server-nodejs' \    # dockerfile language server
  'yaml-language-server' \                 # yaml language server
  'vscode-html-languageserver-bin' \       # html language server
  'vim-language-server' \                  # vim language server
  'intelephense' \                         # php language server
  'typescript-language-server' \           # js / ts language server
  'vscode-css-languageserver-bin' \        # css/less/sass language server
  'vscode-langservers-extracted' \         # a mix of language server bins
  'vls' \                                  # vue language server
  '@angular/language-server' \             # angular language server
)

################################################################################
#                                                                              #
#  Run                                                                         #
#                                                                              #
################################################################################

# install nvm if necessary
if ! command -v nvm &> /dev/null; then
  log yellow "NVM not detected, installing..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
fi

# this should be setup in your shells rc file, running here manually to at least install
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# install and use latest lts
# nvm install --lts
# nvm use --lts

# pin to lts/gallium
nvm install lts/gallium
nvm alias defailt lts/gallium
nvm use lts/gallium

# install node packages
for i in ${PACKAGES[@]}; do
  echo
  echo "-- installing $i --"
  echo
  npm -g install $i
done

# ensure ~/.config is not owned by root
sudo chown -R ${PRIMARY_USER}: ${PRIMARY_USER_HOME}/.config
