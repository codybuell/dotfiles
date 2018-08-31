#!/bin/bash
#
# Composer
#
# Install composer based tools and utilities.
#
# Author(s): Cody Buell
#
# Revisions: 2018.01.17 Initial framework.
#
# Requisite: Composer
#
# Task List: 
#
# Usage: ./composer.sh

######################
#                    #
#  define locations  #
#                    #
######################

CONFGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../ && pwd )"

######################
#                    #
#  define functions  #
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

#########################
#                       #
#  read configurations  #
#                       #
#########################

readconfig

###################
#                 #
#  install valet  #
#                 #
###################

case `uname -s` in
  Linux )
    if [ -f /etc/redhat-release ]; then
      # load selinux module so we can run web applications from home dir
      /usr/bin/sudo mkdir /etc/selinux/local
      /usr/bin/sudo cp $CONFGDIR/assets/laravel-valet.te /etc/selinux/local/
      /usr/bin/sudo checkmodule -M -m -o /etc/selinux/local/laravel-valet.mod /etc/selinux/local/laravel-valet.te
      /usr/bin/sudo semodule_package -o /etc/selinux/local/laravel-valet.pp -m /etc/selinux/local/laravel-valet.mod
      /usr/bin/sudo semodule -i /etc/selinux/local/laravel-valet.pp

      # configure sebool
      setsebool -P httpd_read_user_content true
      setsebool -P httpd_can_network_connect true
      setsebool -P httpd_can_network_connect_db true
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

##########################
#                        #
#  install statamic cli  #
#                        #
##########################

composer global require statamic/cli
exit 0
