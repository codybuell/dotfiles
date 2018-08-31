#!/bin/bash
#
# Paths
#
# Setup all paths and symlinks from the repository configuration file.
#
# Author(s): Cody Buell
#
# Revisions: 2018.01.17 Initial framework.
#
# Requisite:
#
# Task List: 
#
# Usage: ./paths.sh

#########################
#                       #
#  Establish Variables  #
#                       #
#########################

CONFGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../ && pwd )"

######################
#                    #
#  Define Functions  #
#                    #
######################

readconfig() {
  CONFIGVARS=()
  shopt -s extglob
  configfile="$CONFGDIR/.config"
  [[ -e $configfile ]] && {
    tr -d '\r' < $configfile > $configfile.tmp
    while IFS='= ' read -r lhs rhs; do
      if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
        rhs="${rhs%%\#*}"    # del in line right comments
        rhs="${rhs%%*( )}"   # del trailing spaces
        rhs="${rhs%\"*}"     # del opening string quotes
        rhs="${rhs#\"*}"     # del closing string quotes
        export $lhs="$rhs"
        CONFIGVARS+="$lhs "
      fi
    done < $configfile.tmp
    export CONFIGVARS
  } || {
    printf "\033[0;31mno configuration file detected\033[0m\n"
    exit 1
  }
  rm $configfile.tmp
}

prettyprint() {

  printf "$1" | awk '{file=$1;$1="";printf "  %-40s %s\n", file, $0}' | sed "s/ /,/g;s/\([^,]\),/\1 /g;s/,\([^,]\)/ \1/g;s/^,/ /;s/,/./g";

}

runpaths() {

  printf "\033[0;34msetting up paths...\033[0m\n"

  for p in ${CONFIGVARS[@]}; do
    VAR=$p
    eval VAL=\$$p
    [[ $VAR =~ PATH.* ]] && {
      [[ ! -d $VAL ]] && {
        prettyprint "  '${VAL}' \033[0;32mcreating path\033[0m\n"
        mkdir -p $VAL
      } || {
        prettyprint "  '${VAL}' \033[0;32malready exists\033[0m\n"
      }
    }
  done

}

runlinks() {

  printf "\033[0;34msetting up symlinks...\033[0m\n"

  LINKMSG="32mcreating symlink"

  [[ -L ~/.todo/tasks ]] && unlink ~/.todo/tasks
  ln -s "$TasksFolder" ~/.todo/tasks

  for c in ${CONFIGVARS[@]}; do
    VAR=$c
    eval VAL=\$$c
    [[ $VAR =~ SYMLINK.* ]] && {
      DST=`echo $VAL | awk '{print $2}'`
      [[ -d $DST || -L $DST ]] && {
        [[ -L $DST ]] && {
          unlink $DST
          LINKMSG="33mre-linking symlink"
        } || {
          prettyprint "  '${DST}' \033[0;33malready exists as a dir\033[0m\n"
          continue
        }
      }
      prettyprint "  '${DST}' \033[0;$LINKMSG\033[0m\n"
      ln -s $VAL
    }
  done

}

############
#          #
#  Run It  #
#          #
############

readconfig
runpaths
runlinks
exit 0
