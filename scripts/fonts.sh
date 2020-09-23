#!/bin/bash
#
# Fonts
#
# Place fonts into the system. Install OTF fonts onto OSX, TTF onto Windows / Linux.
#
# Author(s): Cody Buell
#
# Requisite: Intended to be used with dotfiles repo Makefile, and font assets
# contained in `$CONFGDIR/assets/fonts`.
#
# Task: 
#
# Usage: make fonts

source scripts/library.sh

#################
#  Place Fonts  #
#################

case `uname -s` in
  Linux )
    echo "to be implemented"
    ;;
  Darwin )
    fontloc=/Library/Fonts/
    printf "\033[0;34msetting up fonts...\033[0m\n"
    for font in `find ${CONFGDIR}/assets/fonts -type f -name \*.otf`; do
      fontname=`echo $font | awk -F\/ '{print $NF}'`
      if [ -f "${fontloc}${fontname}" ]; then
        prettyprint "  ${fontname}:\033[0;33malready installed\033[0m\n"
      else
        prettyprint "  ${fontname}:\033[0;32minstalling font\033[0m\n"
        cp ${font} /Library/Fonts/
      fi
    done
    ;;
esac
