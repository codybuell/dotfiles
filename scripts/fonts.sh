#!/bin/bash
#
# Fonts
#
# Place fonts into the system. Install OTF fonts onto OSX, TTF onto Windows / Linux.
#
# Author(s): Cody Buell
#
# Requisite: Intended to be used with dotfiles repo Makefile, and font assets
# contained in `$CONFIGDIR/assets/fonts`.
#
# Task: 
#
# Usage: scripts/fonts.sh
#        make fonts

source scripts/library.sh

#################
#  Place Fonts  #
#################

case `uname -s` in
  Linux )
    echo "to be implemented"
    ;;
  Darwin )
    which md5 > /dev/null 2>&1
    [[ $? -gt 0 ]] && {
      MD5='md5sum'
      MD5Q='md5sum'
    } || {
      MD5='md5'
      MD5Q='md5 -q'
    }
    fontloc=/Library/Fonts/
    printf "\033[0;34msetting up fonts...\033[0m\n"
    for font in `find ${CONFIGDIR}/assets/fonts -type f -name \*.otf`; do
      fontname=`echo $font | awk -F\/ '{print $NF}'`
      if [ -f "${fontloc}${fontname}" ]; then
        MD5_INSTALLED=$($MD5Q ${fontloc}${fontname})
        MD5_NEW=$($MD5Q ${font})
        if [[ "$MD5_INSTALLED" != "$MD5_NEW" ]]; then
          prettyprint "  ${fontname}:\033[0;32minstalling font\033[0m\n"
          cp ${font} /Library/Fonts/
        else
          prettyprint "  ${fontname}:\033[0;33malready installed\033[0m\n"
        fi
      else
        prettyprint "  ${fontname}:\033[0;32minstalling font\033[0m\n"
        cp ${font} /Library/Fonts/
      fi
    done
    ;;
esac
