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
    'websocket-client' \            # required for wee-slack weechat plugin
    'browsercookie' \               # for getting browser cookies with cookiemonster via cli
)

OSXPYTHON2=( \
    'pync' \                        # required for notification-center.py weechat plugin
)

PYTHON3=( \
    'click' \                       # required for mattermost auth cookie gathering script
    'selenium' \                    # same as click
)

OSXPYTHON3=( \
)

# install python2 packages
for i in ${PYTHON2[@]}; do
  /usr/bin/sudo pip2 install $i
done

# install python3 packages
for i in ${PYTHON3[@]}; do
  /usr/bin/sudo pip3 install $i
done

# osx specific installs
if [ `uname -s` = 'Darwin' ]; then
  for i in ${OSXPYTHON2[@]}; do
    /usr/bin/sudo pip2 install $i
  done

  for i in ${OSXPYTHON3[@]}; do
    /usr/bin/sudo pip3 install $i
  done
fi
