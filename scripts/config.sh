#!/bin/bash
#
# Config
#
# Provide a wizard interface for setting up the repository .config file.
#
# Author(s): Cody Buell
#
# Revisions: 2018.08.10 Initial framework.
#
# Requisite: 
#
# Task List:
#
# Usage: ./config.sh

#################
#               #
#  define vars  #
#               #
#################

CONFGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../ && pwd )"
configfile="$CONFGDIR/.config"
IGNORE=("PATH.*" "SYMLINK.*" "REPO.*" "COMMAND.*")
HOMEDIR=$HOME

###############
#             #
#  functions  #
#             #
###############

readconfig() {

  CONFIGVARS=()
  shopt -s extglob
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

createsymlinks() {
  echo
}

createpaths() {
  echo
}

createrepos() {
  echo
}

createcommands() {
  echo
}

overriveavalue() {
  echo
}

############
#          #
#  run it  #
#          #
############

# if production config file doesn't exist create it
[[ ! -e $configfile ]] && {
  cp $CONFGDIR/.config.example $CONFGDIR/.config
  [[ `uname -a` =~ ^Darwin ]] && {
    sed -i '' "s_/Path/home_${HOME}_g" $CONFGDIR/.config
  } || {
    sed -i "s_/Path/home_${HOME}_g" $CONFGDIR/.config
  }
}

readconfig

for p in ${CONFIGVARS[@]}; do
  VAR=$p
  eval VAL=\$$p
  for i in ${IGNORE[@]}; do
    [[ $VAR =~ $i ]] && {
      continue 2
    }
  done
  read -p "$VAR [$VAL]: " NEWVAL
  [[ "$VAL" != "$NEWVAL" ]] && {
    echo 'changing'
    sed -i '' "s/\(^[[:space:]]*$VAR[[:space:]]*=[[:space:]]*\).*$/\1$NEWVAL/" $CONFGDIR/.config
  }
done

exit 0
