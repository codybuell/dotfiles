#!/bin/bash
#
# Node
#
# Install node packages to support dotfiles and base level system configs.
#
# Author(s): Cody Buell
#
# Revisions: 2018.01.17 Initial framework.
#
# Requisite: 
#
# Resources: 
#
# Task List: 
#
# Usage: 

PACKAGES=( \
    'asciicast2gif' \               # convert asciinema json files to gifs
    'bower' \                       # web development 3rd party dependency / asset manager
    'gistup' \                      # a tool for creating gists from the terminal
    'gulp' \                        # asset compiler for web development
    'http-server' \                 # a light-weight web server for development and testing
    'topojson' \                    # tool for converting shape files into json for d3
    'jsonlint' \                    # json syntax checking utility
    'svgo' \                        # svg optimization utility
    'wscat' \                       # websocket command line client
)

# install gem packages
for i in ${PACKAGES[@]}; do
  npm -g install $i
done
