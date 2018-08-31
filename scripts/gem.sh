#!/bin/bash
#
# Gem
#
# Install gem packages to support dotfiles and base level system configs.
#
# Author(s): Cody Buell
#
# Revisions: 2018.01.17 Initial framework.
#
# Requisite: Ruby
#
# Task List: 
#
# Usage: ./gem.sh

###################
#                 #
#  package lists  #
#                 #
###################

PACKAGES=( \
  'bundler' \                     # needed for mutt sending markdown emails
  'ghi' \                         # github issues command line
  'neovim' \                      # neovim client, required to use ruby with neovim
  'slackcat' \                    # cat files and streams to slack
)

#######################
#                     #
#  run installations  #
#                     #
#######################

# install gem packages
for i in ${PACKAGES[@]}; do
  sudo gem install $i
done

exit 0
