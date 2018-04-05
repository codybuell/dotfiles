#!/bin/bash
#
# Linux Configuration Script
#
# Script to quickly deploy dotfiles into your accounts home directory.
#
# Author(s): Cody Buell
#
# Revisions: 2016.??.?? Initial rough out
#            2017.06.22 Add helpers and organize into logical sections
#
#
#   ADTOOL:
#     cp dotfiles/miscellaneous/adtool-1.3.3.tar.gz -> somewhere, untar
#     cd into dir
#     ./configure && make
#     sudo make install
#
#   Valet linux:
#
#     valet-linux (dont install as root)
#     composer global require cpriego/valet-linux
#     valet install --ignorse-selinux
#     cd ~/Repos
#     valet park
#     valet domain host
#     # config for selinux, php-fpm has issues, try to start it up once, it will fail then
#     # check the output here to make sure the new perms will be ok:
#     # grep php-fpm /var/log/audit/audit.log | audit2allow -m phpfpm > phpfpmlocal.tmp
#     # run `grep php-fpm /var/log/audit/audit.log | audit2allow -M phpfpmlocal` and then `semodule -i phpfpmlocal.pp`
#     # then `ausearch -c 'php-fpm' --raw | audit2allow -M my-phpfpm`   `semodule -i my-phpfpm.pp`
#     repeat ausearch as needed
#     WRITE A SINGLE SELINUX MODULE FOR THIS!!
#

###########################
#                         #
#   Establish Variables   #
#                         #
###########################

# define locations
CONFGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../ && pwd )"
DOTS_LOC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../dotfiles && pwd )"
DOTFILES=(`ls $DOTS_LOC`)
UNAME=`uname -s`

# detect distro, bulid lists
if [ -f /etc/redhat-release ]; then
  FAMILY='el'
  REMOVE=(tmux vim zsh)
  INSTALL=(ack composer ctags elinks freerdp gnupg1 gnupg2 gnupg2-smime imapfilter isync jq lastpass-cli mariadb mariadb-server msmtp ncurses-devel npm openldap-devel opensc pass pcsc-lite pcsc-tools python2-pip python34-pip ruby w3m xdotool xsel ykclient ykpers)
elif [ -f /etc/debian_version ]; then
  FAMILY='debian'
  REMOVE="ghostscript tmux"
  INSTALL="cmake exuberant-ctags gcc git libevent-dev libncurses5-dev nfs-common ruby ruby-dev vim-nox ack-grep ag ansible awscli bash bash-completion coreutils dos2unix fwknop-client composer jq minicom mutt nmap nodejs openssl picocom tree curl pinentry"
fi

########################
#                      #
#   Helper Functions   #
#                      #
########################


package_install () {
  PKGS_TO_INSTALL=$@
  if [ $FAMILY == "el" ]; then
    sudo yum clean all
    sudo yum check-update
    sudo yum -y install $PKGS_TO_INSTALL
  elif [ $FAMILY == "debian" ]; then
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y install $PKGS_TO_INSTALL
  fi
}

package_remove () {
  if [ $FAMILY == "el" ]; then
    sudo yum -y remove $@
  elif [ $FAMILY == "debian" ]; then
    sudo apt-get -y purge $@
    sudo apt -y autoremove
  fi
}

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

###############################
#                             #
#   Configuration Functions   #
#                             #
###############################

buildtmux() {
  #package_install libevent-2.0-5 libevent-core-2.0-5 libevent-dev automake libncurses5-dev libncursesw5-dev
  package_install libevent-dev automake libncurses5-dev libncursesw5-dev libevent-devel ncurses-devel glibc-static
  TPATH="`echo $1 | sed "s@~@$HOME@"`/tmux"
  if [ -d $TPATH ]; then
    cd $TPATH
    git pull origin master
  else
    git clone https://github.com/tmux/tmux.git $TPATH
    cd $TPATH
  fi
  sh autogen.sh
  ./configure && make
  if [ ! -h /usr/local/bin/tmux ]; then
    sudo ln -s $TPATH/tmux /usr/local/bin/tmux
  fi
}

fixvimpath() {
  # shooting for a consistent path for vim between osx and linux
  if [ ! -h /usr/local/bin/vim ]; then
    sudo ln -s /usr/bin/vim /usr/local/bin/vim
  fi
}

configurekeyboard() {
  if [ $FAMILY == "el" ]; then
    echo
  elif [ $FAMILY == "debian" ]; then
    if [ "$KBLayout" == "colemak" ]; then
      sudo sed -i 's/^XKBVARIANT=.*$/XKBVARIANT="colemak"/' /etc/default/keyboard
      sudo sed -i 's/^XKBOPTIONS=.*$/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard
    fi
  fi
}

setregiontous() {
  echo
}

configurefonts() {
  cd $CONFGDIR
  mkdir -p $HOME/.local/share/fonts
  find fonts -type f -name \*.otf -exec cp {} $HOME/.local/share/fonts/ \;
}

importdconf() {
  # 16.04+ suck in dconf settings
  dconf reset -f /org/gnome/terminal/legacy/profiles:/
  dconf load /org/gnome/terminal/legacy/profiles:/ < dconf/terminal.dconf
}

installchrome() {
  echo
# vi /etc/yum.repos.d/google-chrome.repo
#   [google-chrome]
#   name=google-chrome
#   baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
#   enabled=1
#   gpgcheck=1
#   gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub

# yum install google-chrome-stable
}

##############
#            #
#   run it   #
#            #
##############

readconfig
package_remove $REMOVE
package_install $INSTALL
buildtmux $ReposPath
configurekeyboard
setregiontous
configurefonts
importdconf
fixvimpath
