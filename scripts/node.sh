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
  'asciicast2gif' \               # convert asciinema json files to gifs
  'bower' \                       # web development 3rd party dependency / asset manager
  'gistup' \                      # a tool for creating gists from the terminal
  'gulp' \                        # asset compiler for web development
  'http-server' \                 # a light-weight web server for development and testing
  'neovim' \                      # node provider for neovim
  'topojson' \                    # tool for converting shape files into json for d3
  'jsonlint' \                    # json syntax checking utility
  'svgo' \                        # svg optimization utility
  'wscat' \                       # websocket command line client
  'yarn' \                        # package manager with version locking and caching
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
