#!/bin/bash
#
# Composer
#
# Install composer based tools and utilities. Note that composer is installed
# via brew.sh with `make brew`.
#
# Author(s): Cody Buell
#
# Requisite: Composer
#
# Tasks: 
#
# Usage: make composer
#        scripts/composer.sh

source scripts/library.sh
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

# set .host tld (i.e. $Repos/project/ --> http://project.host
valet domain host

# set base dir for webroots
cd $Repos
valet park

##########################
#                        #
#  install statamic cli  #
#                        #
##########################

composer global require statamic/cli

############################
#                          #
#  install languageserver  #
#                          #
############################

# composer global require felixfbecker/language-server

exit 0
