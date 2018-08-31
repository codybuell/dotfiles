#!/bin/bash
#
# Go
#
# Go get some stuff to install.  Note that the vim plugin vim-go installs a
# number of binaries.  Rather than duplicate them here, we run GoUpdateBinaries
# as part of our vim installation.
#
# Author(s): Cody Buell
#
# Revisions: 2018.01.17 Initial framework.
#
# Requisite: Go
#
# Task List: 
#
# Usage: ./go.sh

###################
#                 #
#  package lists  #
#                 #
###################

LINUX=( \
)

OSX=( \
  'github.com/wincent/passage' \           # utility for proxying to osx keychain
  'github.com/keybase/go-keychain' \       # golang library for osx keychain
)

ALL=( \
)

###############
#             #
#  functions  #
#             #
###############

configurepassage() {
  # build and configure passage to start on boot
  cd $GOPATH/src/github.com/wincent/passage
  go build
  sudo cp passage /usr/local/bin
  cp contrib/com.wincent.passage.plist ~/Library/LaunchAgents
  # NOTE: This won't work if run inside a tmux session:
  launchctl load -w -S Aqua ~/Library/LaunchAgents/com.wincent.passage.plist
}

readconfig() {

  CONFGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../ && pwd )"
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

createdir() {
  [[ ! -d $1 ]] && {
    prettyprint "  '${1}' \033[0;32mcreating path\033[0m\n"
    mkdir -p $1
  }
}

createsymlink() {
  DST=`echo $1 | awk '{print $2}'`
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
  ln -s $1
}

#####################
#                   #
#  env preparation  #
#                   #
#####################

readconfig

# set gopath if currently null
if [ -z "$GOPATH" ]; then
  export GOPATH=$GoPath
fi

createdir $GoPath
createsymlink "$GoPathBin $GOPATH/bin"
createsymlink "$GoPathSrc $GOPATH/src"
createdir ${GOPATH}/pkg

#######################
#                     #
#  run installations  #
#                     #
#######################

# os specific installations
case `uname -s` in
  Linux )
    for i in ${LINUX[@]}; do
      go get -u $i
    done
    ;;
  Darwin )
    for i in ${OSX[@]}; do
      go get -u $i
    done
    configurepassage
    ;;
esac

# general installations
for i in ${ALL[@]}; do
  go get -u $i
done

exit 0
