#!/bin/bash
#
# Commands
#
# Run arbitrary commands defined in the repository configuration file.
#
# Author(s): Cody Buell
#
# Requisite:
#
# Tasks: 
#
# Usage: make commands
#        scripts/commands.sh

# shellcheck source=./library.sh
source "${BASH_SOURCE%/*}/library.sh"

######################
#                    #
#  Define Functions  #
#                    #
######################

# Run Commands
#
# Run all commands as defined by $COMMAND.* variables in $CONFIGDIR/.config.
#
# @param none
# @return none
runcommands() {
  printf "\033[0;34mrunning commands...\033[0m\n"
  LINKMSG="32mrunning command"
  for c in ${CONFIGVARS[@]}; do
    VAR=$c
    eval VAL=\$$c
    [[ $VAR =~ COMMAND.* ]] && {
      printf "\033[0;34mexecuting: $VAL\033[0m\n"
      eval "$VAL"
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
runcommands
exit 0
