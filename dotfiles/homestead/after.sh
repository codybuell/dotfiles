#!/bin/sh

# If you would like to do some extra provisioning you may
# add any commands you wish to this file and they will
# be run after the Homestead machine is provisioned.

echo "\
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y install php-ldap ntp ntpdate
service ntp stop
ntpdate 0.ubuntu.pool.ntp.org
service ntp start" \
> /tmp/provision.sh

chmod 755 /tmp/provision.sh
sudo /tmp/provision.sh
