#!/bin/bash
#
# Node
#
# Installation of node packages.
#
# Author(s): Cody Buell
#
# Revisions: 2018.01.17 Initial framework.
#
# Requisite: NPM
#
# Task List: 
#
# Usage: ./node.sh

###################
#                 #
#  package lists  #
#                 #
###################

PACKAGES=( \
  'asciicast2gif' \                         # convert asciinema json files to gifs
  'bower' \                                 # web development 3rd party dependency / asset manager
  'gistup' \                                # a tool for creating gists from the terminal
  'gulp' \                                  # asset compiler for web development
  'http-server' \                           # a light-weight web server for development and testing
  'neovim' \                                # node provider for neovim
  'topojson' \                              # tool for converting shape files into json for d3
  'jsonlint' \                              # json syntax checking utility
  'svgo' \                                  # svg optimization utility
  'wscat' \                                 # websocket command line client
  'yarn' \                                  # package manager with version locking and caching
  'bash-language-server' \                  # bash language server
  'javascript-typescript-langserver' \      # javascript / typescript language server
  'vscode-json-languageserver' \            # json language server
  'dockerfile-language-server-nodejs' \     # dockerfile language server
  'yaml-language-server' \                  # yaml language server
  'vscode-html-languageserver-bin' \        # html language server
  'markdown-language-server' \              # markdown language server
  'vim-language-server' \                   # vim language server
  'intelephense' \                          # php language server
  'vscode-css-languageserver-bin' \         # css/less/sass language server
)

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
