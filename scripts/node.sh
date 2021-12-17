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
#        sh -c "$(curl -fsSL https://raw.githubusercontent.com/codybuell/dotfiles/master/scripts/node.sh)"

PRIMARY_USER=$(whoami)
PRIMARY_USER_HOME=$HOME

###################
#                 #
#  package lists  #
#                 #
###################

PACKAGES=( \
  'asciicast2gif' \                         # convert asciinema json files to gifs
  'bower' \                                 # web development 3rd party dependency / asset manager
  'cfn-lint' \                              # aws cloudformation template linting
  'gistup' \                                # a tool for creating gists from the terminal
  'gitlab-ci-lint' \                        # linting of gitlab ci files
  'gulp' \                                  # asset compiler for web development
  'http-server' \                           # a light-weight web server for development and testing
  'neovim' \                                # node provider for neovim
  'topojson' \                              # tool for converting shape files into json for d3
  '@mapbox/togeojson' \                     # tool for converting gpx / kml to geojson
  'jsonlint' \                              # json syntax checking utility
  'svgo' \                                  # svg optimization utility
  'typescript' \                            # typescript, a dep for typescript-language-server
  'wscat' \                                 # websocket command line client
  'yarn' \                                  # package manager with version locking and caching
  'bash-language-server' \                  # bash language server
  'vscode-json-languageserver' \            # json language server
  'dockerfile-language-server-nodejs' \     # dockerfile language server
  'yaml-language-server' \                  # yaml language server
  'vscode-html-languageserver-bin' \        # html language server
  'vim-language-server' \                   # vim language server
  'intelephense' \                          # php language server
  'typescript-language-server' \            # javascript / typescript language server
  'vscode-css-languageserver-bin' \         # css/less/sass language server
  'vscode-langservers-extracted' \          # a mix of language servers with bins copat with nvim-lspconfig
  'vls' \                                   # vue language server
)

#################
#               #
#  install nvm  #
#               #
#################

# install nvm if necessary
which nvm > /dev/null
[[ $? -gt 0 ]] && {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
}

# this should be setup in your shells rc file, running here manually to at least install
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# install v15 or latest lts depending on architecture
if [ `/usr/bin/uname -m` == 'arm64' ] || [ "$(/usr/bin/uname -m)" = "x86_64" -a "$(/usr/sbin/sysctl -in sysctl.proc_translated)" = "1" ]; then
  nvm install v15
  nvm use v15
else
  nvm install --lts
  nvm use --lts
fi

#######################
#                     #
#  run installations  #
#                     #
#######################

# install node packages
for i in ${PACKAGES[@]}; do
  echo
  echo "-- installing $i --"
  echo
  npm -g install $i
done

# ensure ~/.config is not owned by root
sudo chown -R ${PRIMARY_USER}: ${PRIMARY_USER_HOME}/.config

exit 0
