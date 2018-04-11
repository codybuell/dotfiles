#!/bin/bash

# define locations
CONFGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../ && pwd )"
DOTS_LOC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../dotfiles && pwd )"
DOTFILES=(`ls $DOTS_LOC`)
UNAME=`uname -s`

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

readconfig

case $UNAME in
  Linux )
    # load selinux module so we can run web applications from home dir
    if [ -f /etc/redhat-release ]; then
      /usr/bin/sudo mkdir /etc/selinux/local
      /usr/bin/sudo cp $CONFGDIR/miscellaneous/laravel-valet.te /etc/selinux/local/
      /usr/bin/sudo checkmodule -M -m -o /etc/selinux/local/laravel-valet.mod /etc/selinux/local/laravel-valet.te
      /usr/bin/sudo semodule_package -o /etc/selinux/local/laravel-valet.pp -m /etc/selinux/local/laravel-valet.mod
      /usr/bin/sudo semodule -i /etc/selinux/local/laravel-valet.pp
    fi

    # (dont install as root)
    composer global require cpriego/valet-linux
    valet install --ignorse-selinux
    ;;
  Darwin )
    composer global require laravel/valet
    valet install
    ;;
esac

# set .host tld (i.e. $ReposPath/project/ --> http://project.host
valet domain host

# set base dir for webroots
cd $ReposPath
valet park
