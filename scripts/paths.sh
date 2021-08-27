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

############
#          #
#  Run It  #
#          #
############

cd
readconfig
runpaths
exit 0
