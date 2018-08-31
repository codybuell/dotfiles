#!/bin/bash
#
# Repos
#
# Clone git repositories listed in the repository configuration file.
#
# Author(s): Cody Buell
#
# Revisions: 2018.08.13 Initial framework.
#
# Requisite:
#
# Task List: 
#
# Usage: ./repos.sh

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

clonerepos() {

  printf "\033[0;34msetting up repositories...\033[0m\n"

  for r in ${CONFIGVARS[@]}; do
    VAR=$r
    eval VAL=\$$r
    [[ $VAR =~ REPO.* ]] && {
      MAKEMODEL=`echo $VAL | sed 's/\// /g;s/\.git//;s/:/ /g' | awk '{print $(NF-1)"/"$NF}'`
      TARGETPATH=${ReposPath}/`echo $VAL | sed 's/\// /g;s/\.git//' | awk 'END {print $NF}'`
      [[ ! -d $TARGETPATH ]] && {
        prettyprint "  '${MAKEMODEL}' \033[0;32mcloning\033[0m\n"
        git clone $VAL $TARGETPATH > /dev/null 2>&1
      } || {
        prettyprint "  '${MAKEMODEL}' \033[0;32malready cloned\033[0m\n"
      }
    }
  done

}

############
#          #
#  Run It  #
#          #
############

readconfig
clonerepos
exit 0
