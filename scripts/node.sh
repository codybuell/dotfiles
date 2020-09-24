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
)

#################
#               #
#  install nvm  #
#               #
#################

# install nvm if necessary
which nvm > /dev/null
[[ $? -gt 0 ]] && {
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
}

# this should be setup in your shells rc file, running here manually to at least install
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# install latest lts version of node
nvm install --lts

# set to use latest lts version of node
nvm use --lts

#######################
#                     #
#  run installations  #
#                     #
#######################

# install node packages
for i in ${PACKAGES[@]}; do
  sudo npm -g install $i
done

exit 0
