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
# Requisite: Python2 & Python3
#
# Task List: 
#
# Usage: ./pip.sh

###################
#                 #
#  package lists  #
#                 #
###################

# standard python 2 packages
PYTHON2=( \
    'browsercookie' \               # for getting browser cookies with cookiemonster via cli
    'feedparser' \                  # rss support for weechat plugin
    'jmespath-terminal' \           # json manipulation and parsing tool (run as `jpterm`)
    'neovim' \                      # neovim client, required to use python with neovim
    'pynvim' \                      # neovim client, required to use python with neovim
    'websocket-client' \            # required for wee-slack weechat plugin
    'python-language-server' \      # a better python language server than pyls??
)
#   'pyls' \                        # python languageserver

# osx specific python 2 packages
OSXPYTHON2=( \
    'pync' \                        # required for notification-center.py weechat plugin
)

# standard Python 3 packages
PYTHON3=( \
    'click' \                       # required for mattermost auth cookie gathering script
    'commandt.score' \              # search scoring utility used in custom deoplete filter
    'feedparser' \                  # rss support for weechat plugin
    'neovim' \                      # neovim client, required to use python with neovim
    'pynvim' \                      # neovim client, required to use python with neovim
    'selenium' \                    # same as click
    'python-language-server' \      # a better python language server than pyls??
)
#   'pynvim' \                      # if your compiled version of neovim does not have python3 support...
#   'pyls' \                        # python languageserver

# osx specific python 3 packages
OSXPYTHON3=( \
)

#######################
#                     #
#  run installations  #
#                     #
#######################

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

exit 0
