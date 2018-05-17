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
#            2018.04.09 Rough out support for centos, add builds for zsh,
#                       weechat, and vim, additional helper functions
#
# Notes:     Remi, the php repo supports single and multiple version installs.
#            See https://rpms.remirepo.net/wizard/, the gist of it is:
#              If you need a single version, using remi-php72 repository,
#              and the php-* packages, the command will be php.
#
#                yum-config-manager --enable remi-php72
#                yum update
#                yum install php-cli
#                php -v
#
#              If you need multiples versions, the php72-php-* packages are 
#              available, and the command is php72 or
#
#                yum install php72-php-cli
#                php72 -v
#                scl enable php72 bash
#                php -v
#
# To Do:     Settings that may not be getting set:
#              - global dark theme
#              - desktop, uncheck keep icons aligned
#              - set inkscape as default for svg file types
#            Make configurations idempotent
#
#   ADTOOL:
#     cp dotfiles/miscellaneous/adtool-1.3.3.tar.gz -> somewhere, untar
#     cd into dir
#     ./configure && make
#     sudo make install
#
#   Valet linux:
#

################
#              #
#   Get Sudo   #
#              #
################

# get and keep sudo privs for duration of the script
/usr/bin/sudo -v; while true; do /usr/bin/sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

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

# commonly named packages
INSTALL='
  bash
  bash-completion
  cmake
  composer
  coreutils
  curl
  gcc
  git
  inkscape
  jq
  openssl
  ruby
  tree
'
REMOVE='
  mutt
  php*
  tmux
  vim
  zsh
'

# detect distro, bulid lists
if [ -f /etc/redhat-release ]; then
  FAMILY='el'
  RELEASE=`cat /etc/redhat-release | sed -e 's/[^0-9.]//g;s/.[0-9].*//g'`
  REMOVE+=''
  INSTALL+='
    ack
    automake
    cairo-devel
    chromedriver
    chromium
    ctags
    elinks
    freerdp
    freetype-devel
    fwknop
    glibc-static
    gnupg1
    gnupg2
    gnupg2-smime
    gnutls-devel
    golang
    google-chrome-stable
    imapfilter
    imlib2-devel
    iperf
    isync
    lastpass-cli
    libcurl
    libcurl-devel
    libevent-devel
    libgcrypt
    libgcrypt-devel
    libncurses5-dev
    libncursesw5-dev
    librsvg2-devel
    libX11-devel
    libXdamage-devel
    libXext-devel
    libXft-devel
    libXinerama-devel
    lua-devel
    mariadb
    mariadb-server
    msmtp
    ncurses
    ncurses-base
    ncurses-devel
    ncurses-libs
    neomutt
    npm
    openbox
    openldap-devel
    opensc
    pandoc
    pass
    pcsc-lite
    pcsc-tools
    perl-devel
    perl-ExtUtils-Embed
    python2-pip
    python34-pip
    python-devel
    ruby-devel
    rxvt-unicode-256color
    telnet
    tolua++-devel
    urlview
    virt-manager
    w3m
    wmctrl
    xdotool
    xsel
    ykclient
    ykpers
    yum-utils
    zlib
    zlib-devel
  '
elif [ -f /etc/debian_version ]; then
  FAMILY='debian'
  REMOVE+=''
  RELEASE=`lsb_release -s -r`
  INSTALL+='
    ack-grep
    ag
    ansible
    automake
    awscli
    dos2unix
    exuberant-ctags
    fwknop-client
    libevent-2.0-5
    libevent-core-2.0-5
    libevent-dev
    libncurses5-dev
    libncursesw5-dev
    minicom
    nfs-common
    nmap
    nodejs
    picocom
    pinentry
    ruby-dev
  '
fi

GCONFMANBOL="gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --type bool --set"
GCONFMANSTR="gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --type string --set"
GCONFMANINT="gconftool-2 --direct --config-source xml:readwrite:/etc/gconf/gconf.xml.mandatory --type int --set"

########################
#                      #
#   Helper Functions   #
#                      #
########################


package_install () {
  PKGS_TO_INSTALL=$@
  if [ $FAMILY == "el" ]; then
    rm -rf /var/cache/yum
    /usr/bin/sudo yum clean all
    /usr/bin/sudo yum check-update
    /usr/bin/sudo yum -y install $PKGS_TO_INSTALL
  elif [ $FAMILY == "debian" ]; then
    /usr/bin/sudo DEBIAN_FRONTEND=noninteractive apt-get -y install $PKGS_TO_INSTALL
  fi
}

package_remove () {
  if [ $FAMILY == "el" ]; then
    /usr/bin/sudo yum -y remove $@
  elif [ $FAMILY == "debian" ]; then
    /usr/bin/sudo apt-get -y purge $@
    /usr/bin/sudo apt -y autoremove
  fi
}

package_check() {
  PKGS_TO_CHECK=$@
  MISSING_PKGS=''
  if [ $FAMILY == "el" ]; then
    for i in $PKGS_TO_CHECK; do
      if [ "`rpm -qi zlib | grep Name | awk '{print $3}'`" != "$i" ]; then
        MISSING_PKGS+=" $i"
      fi
    done
  elif [ $FAMILY == "debian" ]; then
    for i in $PKGS_TO_CHECK; do
      echo
    done
  fi

  if [ "$MISSING_PKGS" != "" ]; then
    echo 'The following packages failed to install on your system:'
    for i in $MISSING_PKGS; do
      echo " - $i"
    done
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

addcustomrepos() {
  printf "\033[0;31madding custom package repositories:\033[0m\n"

  case $FAMILY in
    el )
      # google repo
      /usr/bin/cat <<- EOF > google-chrome.repo
				[google-chrome]
				name=google-chrome
				baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
				enabled=1
				gpgcheck=1
				gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
			EOF
      /usr/bin/sudo mv google-chrome.repo /etc/yum.repos.d/google-chrome.repo

      # neomutt
      curl -o flatcap-neomutt-epel-7.repo https://copr.fedorainfracloud.org/coprs/flatcap/neomutt/repo/epel-7/flatcap-neomutt-epel-7.repo
      /usr/bin/sudo mv flatcap-neomutt-epel-7.repo /etc/yum.repos.d/flatcap-neomutt-epel-7.repo

      # clean up selinux perms
      /usr/bin/sudo restorecon -R /etc/yum.repos.d

      # epel repository
      /usr/bin/sudo yum -y install epel-release

      # remi for php packages
      /usr/bin/sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
      /usr/bin/sudo /usr/bin/sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/remi-php72.repo

      # update
      printf "\033[0;31mrunning system updates:\033[0m\n"
      /usr/bin/sudo yum -y update
      ;;
    debian )
      echo
      ;;
  esac
}

buildconky() {
  # deb deps: libtolua-dev libtolua++5.1-dev libx11-dev libxft-dev libxdamage-dev libncurses5-dev libxinerama-dev
  # el deps: libX11-devel libXdamage-devel libXext-devel freetype-devel libXft-devel lua-devel imlib2-devel libXinerama-devel cairo-devel tolua++-devel librsvg2-devel

  # set the full path to repos, no ~/'s
  TPATH="`echo $1 | sed "s@~@$HOME@"`/conky"
  # if already there get the latest
  if [ -d $TPATH ]; then
    cd $TPATH
    git pull origin master
  # else clone it from scratch
  else
    git clone https://github.com/brndnmtthws/conky.git $TPATH
    cd $TPATH
  fi

  # config and build
  mkdir build
  cd build
  cmake -D BUILD_LUA_RSVG=ON -D BUILD_LUA_CAIRO=ON -D BUILD_LUA_IMLIB2=ON ..
  # this will launch a curses-based UI where you can configure
  # everything, when you are ready you can build as usual:
  make               # this will compile conky in the `src` subdirectory
  sudo make install

}

buildrdesktop() {
  # deb deps: 
  # el deps: openssl-devel pcsc-lite-devel
  #          --enablerepo nux-dextop libgssglue-devel

  # set the full path to repos, no ~/'s
  TPATH="`echo $1 | sed "s@~@$HOME@"`/rdesktop"
  # if already there get the latest
  if [ -d $TPATH ]; then
    cd $TPATH
    git pull origin master
  # else clone it from scratch
  else
    git clone https://github.com/rdesktop/rdesktop.git $TPATH
    cd $TPATH
  fi

  # find the latest release and check it oup
  RDESKRELEASE=`git tag | grep -vi test | tail -1`
  git checkout $RDESKRELEASE

  # config and build
  ./bootstrap
  ./configure
  make
  /usr/bin/sudo make install

}

buildlbdb() {
  # deb deps: 
  # el deps:  

  # set the full path to repos, no ~/'s
  TPATH="`echo $1 | sed "s@~@$HOME@"`/lbdb"
  # if already there get the latest
  if [ -d $TPATH ]; then
    cd $TPATH
    git pull origin master
  # else clone it from scratch
  else
    git clone https://github.com/tgray/lbdb.git $TPATH
    cd $TPATH
  fi

  # config and build
  ./configure
  make
  /usr/bin/sudo make install
}

buildtmux() {
  # deb deps: libevent-2.0-5 libevent-core-2.0-5 libevent-dev automake libncurses5-dev libncursesw5-dev
  # el deps:  package_install libevent-dev automake libncurses5-dev libncursesw5-dev libevent-devel ncurses-devel glibc-static

  printf "\033[0;31mbuilding tmux:\033[0m\n"

  # set the full path to repos, no ~/'s
  TPATH="`echo $1 | sed "s@~@$HOME@"`/tmux"
  # if already there get the latest
  if [ -d $TPATH ]; then
    cd $TPATH
    git pull origin master
  # else clone it from scratch
  else
    git clone https://github.com/tmux/tmux.git $TPATH
    cd $TPATH
  fi

  # config and build
  sh autogen.sh
  ./configure && make

  # link it to /usr/local/bin
  if [ ! -h /usr/local/bin/tmux ]; then
    /usr/bin/sudo ln -s $TPATH/tmux /usr/local/bin/tmux
  fi
}

buildvim() {
  # deb deps: 
  # el deps: ruby perl-devel python-devel ruby-devel perl-ExtUtils-Embed ncurses-devel

  printf "\033[0;31mbuilding vim:\033[0m\n"

  # set the full path to repos, no ~/'s
  TPATH="`echo $1 | sed "s@~@$HOME@"`/vim"
  # if already there get the latest
  if [ -d $TPATH ]; then
    cd $TPATH
    git pull origin master
  # else clone it from scratch
  else
    git clone https://github.com/vim/vim.git $TPATH
    cd $TPATH
  fi

  # config and build
  ./configure --prefix=/usr/local --enable-multibyte  --with-tlib=ncurses --enable-pythoninterp --enable-rubyinterp --with-ruby-command=/usr/bin/ruby --with-features=huge
  make
  /usr/bin/sudo make install
}

buildweechat() {
  # deb deps: 
  # el deps: cmake libcurl libcurl-devel zlib zlib-devel libgcrypt libgcrypt-devel ncurses ncurses-libs ncurses-devel ncurses-base gnutls-devel

  printf "\033[0;31mbuilding weechat:\033[0m\n"

  # set the full path to repos, no ~/'s
  TPATH="`echo $1 | sed "s@~@$HOME@"`/weechat"
  # if already there get the latest
  if [ -d $TPATH ]; then
    cd $TPATH
    git pull origin master
  # else clone it from scratch
  else
    git clone https://github.com/weechat/weechat.git $TPATH
    cd $TPATH
  fi

  # config and build
  mkdir build; cd build
  cmake .. -DENABLE_PHP=OFF
  make
  /usr/bin/sudo make install
}

buildzsh() {
  # deb deps: 
  # el deps: 

  printf "\033[0;31mbuilding zsh:\033[0m\n"

  # set the full path to repos, no ~/'s
  TPATH="`echo $1 | sed "s@~@$HOME@"`/zsh"
  # if already there get the latest
  if [ -d $TPATH ]; then
    cd $TPATH
    git pull origin master
  # else clone it from scratch
  else
    git clone https://github.com/zsh-users/zsh.git $TPATH
    cd $TPATH
  fi

  # find the latest release and check it oup
  ZSHRELEASE=`git tag | grep -vi test | tail -1`
  git checkout $ZSHRELEASE

  # config and build
  ./Util/preconfig
  ./configure && make && /usr/bin/sudo make install
}

configurekeyboard() {
  printf "\033[0;31mconfiguring keyboard layout:\033[0m\n"

  if [ $FAMILY == "el" ]; then
    echo
  elif [ $FAMILY == "debian" ]; then
    if [ "$KBLayout" == "colemak" ]; then
      /usr/bin/sudo sed -i 's/^XKBVARIANT=.*$/XKBVARIANT="colemak"/' /etc/default/keyboard
      /usr/bin/sudo sed -i 's/^XKBOPTIONS=.*$/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard
    fi
  fi
}

setregiontous() {
  printf "\033[0;31msetting region to us:\033[0m\n"

}

configurefonts() {
  printf "\033[0;31mloading custom fonts:\033[0m\n"

  cd $CONFGDIR
  mkdir -p $HOME/.local/share/fonts
  find fonts -type f -name \*.otf -exec cp {} $HOME/.local/share/fonts/ \;

  if [ $FAMILY = 'el' ]; then

    # set up nux-dextop repo
    /usr/bin/sudo /usr/bin/yum -y localinstall http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm

    # disable nux-dextop by default and only enable it as needed as part of running yum
    /usr/bin/sudo /usr/bin/sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/nux-dextop.repo

    # install the nux packages
    /usr/bin/sudo /usr/bin/yum -y --enablerepo=nux-dextop install fontconfig-infinality cairo libXft freetype-infinality

    # configure fonts file
    /usr/bin/cat <<- EOF > ~/.fonts.conf
			<?xml version="1.0"?>
			<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
			<fontconfig>
			 <alias>¬
			  <family>system</family>¬
			  <prefer><family>Source Sans Pro</family></prefer>¬
			 </alias>¬
			 <match target="font">
			  <edit mode="assign" name="hinting" >
			   <bool>true</bool>
			  </edit>
			 </match>
			 <match target="font" >
			  <edit mode="assign" name="autohint" >
			   <bool>true</bool>
			  </edit>
			 </match>
			 <match target="font">
			  <edit mode="assign" name="hintstyle" >
			  <const>hintslight</const>
			  </edit>
			 </match>
			 <match target="font">
			  <edit mode="assign" name="rgba" >
			   <const>rgb</const>
			  </edit>
			 </match>
			 <match target="font">
			  <edit mode="assign" name="antialias" >
			   <bool>true</bool>
			  </edit>
			 </match>
			 <match target="font">
			   <edit mode="assign" name="lcdfilter">
			   <const>lcddefault</const>
			   </edit>
			 </match>
			</fontconfig>
		EOF
  fi

  fc-cache -f
  /usr/bin/sudo fc-cache -f

}

importdconf() {
  # ubuntu 16.04+ / rh/cent 7+ uses dconf settings
  # to export cofigs:
  #   dconf dump /config/path/ > filename.dconf
  #   - /org/gnome/terminal/legacy/profiles:/          # terminal
  #   - /org/gnome/terminal/legacy/keybindings/          # terminal keyboard shortcuts
  #   - /org/gnome/shell/                              # app favorites, window-switcher
  #   - /org/gnome/settings-daemon/plugins/xsettings/  # antialiasing
  #   - /org/gnome/desktop/interface/                  # system font, theme, clock format...
  #   - /org/gnome/desktop/input-sources/              # kb layouts, caps lock to control
  #   - /org/gnome/desktop/background/                 # desktop image, dt icon settings
  #   - /org/gnome/desktop/wm/                         # window management settings
  #   - /org/gnome/desktop/screensaver/                # lock screen, screensaver
  #   - /org/gnome/desktop/notifications/              # notification center
  #   - /org/gnome/mutter/                             # dynamic workspaces setting
  #   - /org/gnome/nautilus/desktop/                   # desktop icons to show
  #   - /org/gnome/settings-daemon/plugins/media-keys/ # lock screen ctrl+alt+l

  printf "\033[0;31mloading dconf:\033[0m\n"

  # place file dependencies
  cp miscellaneous/wallpaper.jpg ~/Pictures/wallpaper.jpg

  # reset
  dconf reset -f /org/gnome/terminal/legacy/profiles:/
  dconf reset -f /org/gnome/terminal/legacy/keybindings/
  dconf reset -f /org/gnome/shell/
  dconf reset -f /org/gnome/settings-daemon/plugins/xsettings/
  dconf reset -f /org/gnome/desktop/interface/
  dconf reset -f /org/gnome/desktop/input-sources/
  dconf reset -f /org/gnome/desktop/background/
  dconf reset -f /org/gnome/desktop/wm/
  dconf reset -f /org/gnome/desktop/screensaver/
  dconf reset -f /org/gnome/desktop/notifications/
  dconf reset -f /org/gnome/desktop/notifications/
  dconf reset -f /org/gnome/mutter/
  dconf reset -f /org/gnome/nautilus/desktop/
  dconf reset -f /org/gnome/settings-daemon/plugins/media-keys/

  # load
  dconf load /org/gnome/terminal/legacy/profiles:/ < dconf/terminal.dconf
  dconf load /org/gnome/terminal/legacy/keybindings/ < dconf/terminal-keybindings.dconf
  dconf load /org/gnome/shell/ < dconf/shell.dconf
  dconf load /org/gnome/settings-daemon/plugins/xsettings/ < dconf/xsettings.dconf
  dconf load /org/gnome/desktop/interface/ < dconf/desktop-interface.dconf
  dconf load /org/gnome/desktop/input-sources/ < dconf/input-sources.dconf
  dconf load /org/gnome/desktop/background/ < dconf/background.dconf
  dconf load /org/gnome/desktop/wm/ < dconf/windows.dconf
  dconf load /org/gnome/desktop/screensaver/ < dconf/screensaver.dconf
  dconf load /org/gnome/desktop/notifications/ < dconf/notifications.dconf
  dconf load /org/gnome/mutter/ < dconf/mutter.dconf
  dconf load /org/gnome/nautilus/desktop/ < dconf/nautilus-desktop.dconf
  dconf load /org/gnome/settings-daemon/plugins/media-keys/ < dconf/media-keys.dconf
}

setusershell() {
  printf "\033[0;31msetting zsh as default user shell:\033[0m\n"

  # get current users shell
  CURSHELL=`getent passwd $(whoami) | sed 's/.*:\([^:].*$\)/\1/'`

  # if shell isn't set to zsh
  if [ "$CURSHELL" != "/usr/local/bin/zsh" ]; then
    # if user account is local
    if [ `cat /etc/passwd | grep "^$(whoami):" | wc -l` = 1 ]; then
      /usr/bin/sudo sed -i "s/\(^$(whoami):.*:\)\([^:].*$\)/\1\/usr\/local\/bin\/zsh/" /etc/passwd
    # else if user account is controlled by sssd
    elif [ -f /etc/sssd/sssd.conf ]; then
      # if override shell param is already set...
      if [ `sudo cat /etc/sssd/sssd.conf | grep override_shell | wc -l` = '1' ]; then
        /usr/bin/sudo sed -i "s/.*override_shell.*/override_shell = \/usr\/local\/bin\/zsh/" /etc/sssd/sssd.conf
      else
        /usr/bin/sudo echo "override_shell = /usr/local/bin/zsh" >> /etc/sssd/sssd.conf
      fi
      /usr/bin/sudo service sssd restart
    fi
  fi

  # make sure zsh is listed in /etc/shells
  if [[ `cat /etc/shells | grep /usr/local/bin/zsh | wc -l` -eq 0 ]]; then
    cat /etc/shells > tempshells
    echo "/usr/local/bin/zsh" >> tempshells
    /usr/bin/sudo mv tempshells /etc/shells
    restorecon /etc/shells
  fi
}

setrootterminfo() {
  printf "\033[0;31msetting terminfo for root user:\033[0m\n"

  /usr/bin/sudo cp -a $DOTS_LOC/terminfo /root/.terminfo
  /usr/bin/sudo restorecon -R /root/
}

secureloginscreen() {
  case $FAMILY in
    el )
      if [[ $RELEASE -ge 7 ]]; then
        # Create gdm profile file
        echo "user-db:user" > gdmtmp
        echo "system-db:gdm" >> gdmtmp
        echo "file-db:/usr/share/gdm/greeter-dconf-defaults" >> gdmtmp
        /usr/bin/sudo mv gdmtmp /etc/dconf/profile/gdm 
        /usr/bin/sudo chown root: /etc/dconf/profile/gdm
        ##############
        #echo "[org/gnome/login-screen]" > bannertmp
        #echo "banner-message-enable=true" >> bannertmp
        #echo "banner-message-text='${NOTICE}'" >> bannertmp
        #/usr/bin/sudo mv bannertmp /etc/dconf/db/gdm.d/01-banner-message
        #/usr/bin/sudo chown bannertmp /etc/dconf/db/gdm.d/02-banner-message
        ##############
        echo "[org/gnome/login-screen]" > logintmp
        echo "disable-user-list=true" >> logintmp
        /usr/bin/sudo mv logintmp /etc/dconf/db/gdm.d/00-login-screen
        /usr/bin/sudo chown root: /etc/dconf/db/gdm.d/00-login-screen
        # run dconf update
        /usr/bin/sudo restorecon -R /etc/dconf
        /usr/bin/sudo dconf update
      else
        # redhat wide start screenlock
        $GCONFMANBOL /apps/screensaver/start_screensaver true
        $GCONFMANBOL /apps/gnome-screensaver/lock_enabled true
        $GCONFMANINT /apps/gnome-screensaver/idle_delay 30
        $GCONFMANBOL /apps/gnome-screensaver/idle_activation_enabled true

        # redhat 6 specific
        if [ $RELEASE = 6 ]; then
          $GCONFMANINT /desktop/gnome/session/idle_delay 30
          # prevent control alt del from shutting down
          $GCONFMANSTR /apps/gnome_settings_daemon/keybindings/power ""
        fi
      fi
      ;;
    debian )
      # ubuntu disallow guest login and hide user list
      /usr/bin/sudo echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf
      /usr/bin/sudo echo "greeter-show-manual-login=true" >> /etc/lightdm/lightdm.conf
      /usr/bin/sudo echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
      /usr/bin/sudo echo "greeter-hide-users=true" >> /etc/lightdm/lightdm.conf
      /usr/bin/sudo service lightdm restart
      ;;
  esac
}

installphp() {
  # installing a non standard version of php and getting it cleanly in your
  # path is a beast in and of itself, hence the standalone function

  if [[ $FAMILY == 'el' ]]; then
    /usr/bin/sudo yum-config-manager --enable remi-php72
    /usr/bin/sudo yum update
    /usr/bin/sudo yum -y install php-cli php72 php72-php-fpm php72-php-gd php72-php-json php72-php-mbstring php72-php-mcrypt php72-php-mysql php72-php-mysqlnd php72-php-opcache php72-php-xml php72-php-xmlrpc php-ldap php72-php-ldap php-mysql php72-php-pecl-mysql
  fi
}

buildsymlinks() {
  printf "\033[0;31mbuilding symlinks:\033[0m\n"

  cd /usr/local/bin/; /usr/bin/sudo ln -s `which neomutt` mutt
  cd /usr/local/bin/; /usr/bin/sudo ln -s `which msmtp` msmtp
}

placeautostarts() {
  printf "\033[0;31mplacing autostart files:\033[0m\n"

  cd $CONFGDIR
  find autostart -type f -name \*.desktop$ -exec cp {} $HOME/.config/autostart/ \;
}

##############
#            #
#   run it   #
#            #
##############

readconfig
addcustomrepos
package_remove $REMOVE
package_install $INSTALL
package_check $INSTALL
installphp
buildconky $ReposPath
buildlbdb $ReposPath
buildtmux $ReposPath
buildvim $ReposPath
buildzsh $ReposPath
buildweechat $ReposPath
#configurekeyboard
#setregiontous
configurefonts
setusershell
importdconf
setrootterminfo
secureloginscreen
buildsymlinks
placeautostarts
