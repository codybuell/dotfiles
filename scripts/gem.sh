#!/bin/bash
#
# Gem
#
# Install gem packages to support dotfiles and base level system configs.
#
# Author(s): Cody Buell
#
# Requisite: Ruby
#
# Tasks:
#
# Usage: make gem
#        ./gem.sh

#################
#               #
#  install rvm  #
#               #
#################

#gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
#\curl -sSL https://get.rvm.io | bash -s stable --ruby

###################
#                 #
#  package lists  #
#                 #
###################

PACKAGES=( \
  'bundler' \               # needed for mutt sending markdown emails
  # 'git-cipher' \            # git add-on for encrypting data in a pub repo NOW VIA NPM
  'neovim' \                # neovim client, required to use ruby with neovim
)

#######################
#                     #
#  run installations  #
#                     #
#######################

# install gem packages
# shellcheck disable=SC2068
for i in ${PACKAGES[@]}; do
  sudo gem install "$i"
done

exit 0
