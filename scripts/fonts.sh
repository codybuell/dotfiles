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

# shellcheck source=./library.sh
source "${BASH_SOURCE%/*}/library.sh"

#################
#  Place Fonts  #
#################

case $(uname -s) in
  Linux )
    echo "to be implemented"
    ;;
  Darwin )
    if ! command -v md5; then
      # MD5='md5sum'
      MD5Q='md5sum'
    else
      # MD5='md5'
      MD5Q='md5 -q'
    fi
    fontloc=/Library/Fonts/
    log blue "setting up fonts..."
    while IFS= read -r font; do
      fontname=$(echo "$font" | awk -F/ '{print $NF}')
      if [ -f "${fontloc}${fontname}" ]; then
        MD5_INSTALLED=$($MD5Q "${fontloc}${fontname}")
        MD5_NEW=$($MD5Q "${font}")
        if [[ "$MD5_INSTALLED" != "$MD5_NEW" ]]; then
          prettyprint "  ${fontname}:${GREEN}installing font${NORM}"
          cp "${font}" /Library/Fonts/
        else
          prettyprint "  ${fontname}:${YELLOW}already installed${NORM}"
        fi
      else
        prettyprint "  ${fontname}:${GREEN}installing font${NORM}"
        cp "${font}" /Library/Fonts/
      fi
    done < <(find "${CONFIGDIR}/assets/fonts" -type f -name "*.[ot]tf")
    ;;
esac
