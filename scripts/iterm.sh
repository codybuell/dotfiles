#!/bin/bash
#
# iTerm
#
# Script to set iTerm preferences directory and to enable its use.
#
# Author(s): Cody Buell
#
# Requisite: Intended to be used with dotfiles repo Makefile, and iterm config
# file contained in `$CONFGDIR/applications/iterm`.
#
# Task: 
#
# Usage: scripts/iterm.sh
#        make iterm

source scripts/library.sh

######################
#  Define Variables  #
######################

CURRENT=`defaults read com.googlecode.iterm2 PrefsCustomFolder`
EXPECTED="$CONFGDIR/applications/iterm"

##########################
#  Apply Configurations  #
##########################

printf "\033[0;34mconfiguring iterm preferences...\033[0m\n"
if [ "$CURRENT" == "$EXPECTED" ]; then
  prettyprint "  iterm prefs:\033[0;33malready set\033[0m\n"
else
  prettyprint "  iterm prefs:\033[0;32msetting prefs\033[0m\n"
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$EXPECTED"
fi
