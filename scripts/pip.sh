#!/bin/bash
#
# Pip
#
# Install pip packages to support dotfiles and base level system configs.
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

PYTHON2=( \
    'jmespath-terminal' \           # json manipulation and parsing tool (run as `jpterm`)
    'pync' \                        # required for notification-center.py weechat plugin
    'websocket-client' \            # required for wee-slack weechat plugin
    'browsercookie' \               # for getting browser cookies with cookiemonster via cli
)

PYTHON3=( \
    'click' \                       # required for mattermost auth cookie gathering script
    'selenium' \                    # same as click
)

# install python2 packages
for i in ${PYTHON2[@]}; do
  pip2 install $i
done

# install python3 packages
for i in ${PYTHON3[@]}; do
  pip3 install $i
done
