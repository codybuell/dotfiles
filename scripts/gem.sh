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
# Requisite: 
#
# Resources: 
#
# Task List: 
#
# Usage: 

PACKAGES=( \
    'slackcat' \                    # cat files and streams to slack
    'ghi' \                         # github issues command line
    'bundler' \                     # needed for mutt sending markdown emails
)

# install gem packages
for i in ${PACKAGES[@]}; do
  gem install $i
done

# clean up / initializing tasks

# installs mime types needed for bundler
cd ~/.mutt/scripts/
bundle install
