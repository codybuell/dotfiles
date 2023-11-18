#!/bin/bash
#
# Paths
#
# Setup all paths and symlinks from the repository configuration file.
#
# Author(s): Cody Buell
#
# Requisite:
#
# Tasks:
#
# Usage: make paths
#        scripts/paths.sh

# shellcheck source=./library.sh
source "${BASH_SOURCE%/*}/library.sh"

######################
#                    #
#  Define Functions  #
#                    #
######################

# Run Links
#
# Create symlinks as defined by every $SYMLINK.* variable in $CONFIGDIR/.config.

runlinks() {
  printf "\033[0;34msetting up symlinks...\033[0m\n"
  LINKMSG="32mcreating symlink"
  for c in ${CONFIGVARS[@]}; do
    VAR=$c
    eval VAL=\$$c
    [[ $VAR =~ SYMLINK.* ]] && {
      DST=$(echo $VAL | awk -F: '{print $2}')
      SRC=$(echo $VAL | awk -F: '{print $1}')

      # replace any config vars within DST / SRC
      for c in ${CONFIGVARS[@]}; do
        VAR=${c}
        eval VAL="\$$c"
        # escape any @'s in the value so perl dosen't hose it
        VAL=$(echo $VAL | sed 's/\@/\\\@/g')
        DST=$(echo $DST | perl -p -e "s|{{[[:space:]]*${VAR}[[:space:]]*}}|${VAL}|g")
        SRC=$(echo $SRC | perl -p -e "s|{{[[:space:]]*${VAR}[[:space:]]*}}|${VAL}|g")
      done

      [[ -d $DST || -L $DST ]] && {
        [[ -L $DST ]] && {
          unlink "$DST"
          LINKMSG="33mre-linking symlink"
        } || {
          prettyprint "  ${DST}:\033[0;33malready exists as a dir\033[0m\n"
          continue
        }
      }
      prettyprint "  ${DST}:\033[0;$LINKMSG\033[0m\n"
      ln -s "$SRC" "$DST"
    }
  done
}

############
#          #
#  Run It  #
#          #
############

cd
read_config
runlinks
exit 0
