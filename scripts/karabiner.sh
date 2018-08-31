#!/bin/bash
#
# Keyboard Configuration
#
# Deploy Karabiner configurations for Colemak layout.
#
# Author(s): Cody Buell
#
# Revisions: 2016.09.03 Initial framework.
#
# Requisite: Karabiner
#

# define locations
DESTDIR="/Users/`whoami`/Library/Application Support/Karabiner"
KBF_LOC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../assets/keyboard && pwd )"
KBFILES=(`ls $KBF_LOC`)

# create karabiner folder
mkdir -p "$DESTDIR"

# copy files in place
for i in ${KBFILES[@]}; do
  cp $KBF_LOC/$i "$DESTDIR/$i"
done
