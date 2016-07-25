#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

sudo apt-get update
sudo apt-get -y install php-ldap ntp
sudo service ntp stop
sudo ntpdate 0.ubuntu.pool.ntp.org
sudo service ntp start
