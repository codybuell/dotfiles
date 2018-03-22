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
# CENTOS TASKS TO AUTOMATE OR ADD DOTFILE CONFIGS:
#   Terminal
#     - turned off bell in profile
#     - set to run command at login /usr/bin/zsh
#     - set font as source code pro
#
#   Tweak Tool
#     - keyboard
#       - ctrl key position -> caps lock as ctrl
#       - caps lok key behavior -> caps lock is also a ctrl
#     - workspaces
#       - dynamic
#     - fonts
#       - hinting -> slight
#       - antialiasing -> rgba
#       - scaling factor -> 1.10
#       - window titles -> source sans pro semi bold 10
#       - interface -> source sans pro regular 10
#       - monospace -> source code pro regular 10
#     - desktop
#       - icons on desktop -> on
#         - deselect everything
#     - appearance
#       - global dark theme
#       - gtk+ -> adwaita dark
#
#   ~/.config/fontconfig/fonts.conf
#       fix syntax select all =
#       add:
#        <fontconfig>
#          <alias>
#            <family>system</family>
#            <prefer><family>Source Sans Pro</family></prefer>
#          </alias>
#        </fontconfig>
#
#     show what system is using for 'system' font
#         fc-match --verbose system
#         update fonts.conf
#         fc-cache -f; sudo fc-cache -f
#
#
#   backgroung / wallpaper
#     - login screen -> color -> deep blue (noise-texture-light.png)
#     - walpaper -> copy files to ~/Pictures and choose
#
#   Other
#     - install source code pro from fonts
#
#   gnome-control-center (settings)
#     - online accounts
#       - add google
#         - contact & files
#     - keyboard
#       - switch to next input source super+`
#     - date and time
#       - time format -> am/pm
#
#   Cerebro
#    get binary, chmod 755, add to path, create launcher
#    vi ~/.config/autostart/cerebro.desktop
#       [Desktop Entry]
#       Type=Application
#       Version=1.0
#       Name=Cerebro
#       Comment=Cerebro startup script.
#       Exec=/home/pbuell/Bin/cerebro-0.3.1-x86_64.AppImage
#       StartupNotify=false
#       Terminal=false
#
#   to do:
#     mail
#     application launcher
#     music
#     home first run fails
#     google drive / notes|journal solution
#     conditional tmux configs
#       if osx use clipper else use ??? for clipboard copy
#     conditional vim configs
#       if osx use clipper else use ??? for clipboard copy
#     `clear` -> tmux-256color unknown terminal type
#     cd into dir -> chpwd_recent_filehandler:39 error when reading /home/pbuell/.chpwd-recent-dirs: unknown error -2
#
#   Vim:
#     yum -y install ruby perl-devel python-devel ruby-devel perl-ExtUtils-Embed ncurses-devel
#     git clone https://github.com/vim/vim.git
#     cd vim
#     ./configure --prefix=/usr/local --enable-multibyte  --with-tlib=ncurses --enable-pythoninterp --enable-rubyinterp --with-ruby-command=/usr/bin/ruby --with-features=huge
#     make
#     sudo make install
#     /usr/local/bin/vim
#
#   ZSH:
#     git clone https://github.com/zsh-users/zsh.git
#     ./Util/preconfig
#     ./configure && make && sudo make install
#     /usr/local/bin/zsh
#
#   php7*
#     yum install epel-release
#     sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
#     yum install yum-utils
#     yum-config-manager --enable remi-php-72
#     yum update
#     yum install php72
#
#
#   WEECHAT:
#     yum install cmake libcurl libcurl-devel zlib zlib-devel libgcrypt libgcrypt-devel ncurses ncurses-libs ncurses-devel ncurses-base gnutls-devel
#     git clone https://github.com/weechat/weechat.git
#     cd weechat
#     mkdir build; cd !$
#     cmake .. -DENABLE_PHP=OFF
#     make
#     sudo make install
#     -----------------
#
#     yum install chromedriver from google repo, if mattermost fails to connect grab the latest from https://chromedriver.storage.googleapis.com/index.html and place in /usr/local/bin, removing the yum installed one
#
#     -----------------

#    remove notification_center.py plugin, don't need pip pync, chmod 755 wee_slack.py
#    add notification.py
#    /set weechat.network.gnutls_ca_file /etc/ssl/certs/ca-bundle.crt
#
#     issues:
#       lots of scripts not found /-a script name...
#       mattermost cert not trusted
#
#   note:
#     ctrl+alt+up|down  switch workspaces
#     super+arrows      resize windows
#     super             app switcher
#     ctrl+alt+enter    toggle xfreerdp fullscreen
#
#
#   npm -g install
#     yarn
#
#   MUTT:
#      [flatcap-neomutt]
#      name=Copr repo for neomutt owned by flatcap
#      baseurl=https://copr-be.cloud.fedoraproject.org/results/flatcap/neomutt/epel-7-$basearch/
#      type=rpm-md
#      skip_if_unavailable=True
#      gpgcheck=1
#      gpgkey=https://copr-be.cloud.fedoraproject.org/results/flatcap/neomutt/pubkey.gpg
#      repo_gpgcheck=0
#      enabled=1
#      enabled_metadata=1
#
#      yum install neomutt
#      setup an alias mutt=> neomutt or symlink

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
  INSTALL=(w3m ack ctags ruby python2-pip python34-pip freerdp mutt npm imapfilter pass gnupg1 gnupg2 gnupg2-smime pcsc-tools lastpass-cli isync)
elif [ -f /etc/debian_version ]; then
  FAMILY='debian'
  REMOVE="ghostscript tmux"
  INSTALL="cmake exuberant-ctags gcc git libevent-dev libncurses5-dev nfs-common ruby ruby-dev vim-nox ack-grep ag ansible awscli bash bash-completion coreutils dos2unix fwknop-client composer jq minicom mutt nmap nodejs openssl picocom tree curl"
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
