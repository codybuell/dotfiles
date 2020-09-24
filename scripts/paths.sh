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
# Task List: 
#
# Usage: make paths
#        scripts/paths.sh

source scripts/library.sh

######################
#                    #
#  Define Functions  #
#                    #
######################

# Run Paths
#
# Create paths as defined by every $PATH.* variable in $CONFGDIR/.config.

runpaths() {
  printf "\033[0;34msetting up paths...\033[0m\n"
  for p in ${CONFIGVARS[@]}; do
    VAR=$p
    eval VAL=\$$p
    [[ $VAR =~ PATH.* ]] && {
      [[ ! -d $VAL ]] && {
        prettyprint "  ${VAL}:\033[0;32mcreating path\033[0m\n"
        mkdir -p $VAL
      } || {
        prettyprint "  ${VAL}:\033[0;32malready exists\033[0m\n"
      }
    }
  done
}

# Run Links
#
# Create symlinks as defined by every $SYMLINK.* variable in $CONFGDIR/.config.

runlinks() {
  printf "\033[0;34msetting up symlinks...\033[0m\n"
  LINKMSG="32mcreating symlink"
  for c in ${CONFIGVARS[@]}; do
    VAR=$c
    eval VAL=\$$c
    [[ $VAR =~ SYMLINK.* ]] && {
      DST=`echo $VAL | awk -F: '{print $2}'`
      SRC=`echo $VAL | awk -F: '{print $1}'`
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
readconfig
runpaths
runlinks
exit 0
