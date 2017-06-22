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
  REMOVE=()
  INSTALL=()
elif [ -f /etc/debian_version ]; then
  FAMILY='debian'
  REMOVE="ghostscript tmux"
  INSTALL="cmake exuberant-ctags gcc git libevent-dev libncurses5-dev nfs-common ruby ruby-dev vim-nox"
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
  package_install libevent-dev automake libncurses5-dev libncursesw5-dev
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
