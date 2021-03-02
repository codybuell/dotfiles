#!/bin/bash
#
# Pip
#
# Install pip packages to support dotfiles and base level system configs.
#
# Author(s): Cody Buell
#
# Requisite: Python3
#
# Tasks: 
#
# Usage: make pip
#        ./pip.sh
#        sh -c "$(curl -fsSL https://raw.githubusercontent.com/codybuell/dotfiles/master/scripts/pip.sh)"

###################
#                 #
#  package lists  #
#                 #
###################

# standard Python 2 pacakges
PYTHON2=( \
    'neovim' \                         # neovim client, required to use python with neovim
    'pynvim' \                         # neovim client, required to use python with neovim
)

# standard Python 3 packages
PYTHON3=( \
    'browsercookie' \                  # for getting browser cookies with cookiemonster via cli
    'click' \                          # required for mattermost auth cookie gathering script
    'commandt.score' \                 # search scoring utility used in custom deoplete filter
    'feedparser' \                     # rss support for weechat plugin
    'jmespath-terminal' \              # json manipulation and parsing tool (run as `jpterm`)
    'neovim' \                         # neovim client, required to use python with neovim
    'pync' \                           # wequired for weechat plugins
    'pynvim' \                         # neovim client, required to use python with neovim
    'selenium' \                       # same as click
    'websocket-client' \               # required for wee-slack weechat plugin
    'python-language-server[all]' \    # a better python language server than pyls??
    'c7n c7n-azure c7n-gcp c7n-org' \  # cloud custodian bits
)

# osx specific python 3 packages
OSXPYTHON3=( \
    'pync' \                        # required for notification-center.py weechat plugin
)

#######################
#                     #
#  run installations  #
#                     #
#######################

# pip for python 2 is no longer available via brew and does not come standard with osx
if ! which pip; then
  sudo easy_install pip
fi

# install python2 packages
for i in ${PYTHON2[@]}; do
  /usr/local/bin/pip install $i
done

# install python3 packages
for i in ${PYTHON3[@]}; do
  /usr/local/bin/pip3 install $i
done

# osx specific installs
if [ `uname -s` = 'Darwin' ]; then
  for i in ${OSXPYTHON3[@]}; do
    /usr/local/bin/pip3 install $i
  done
fi

exit 0
