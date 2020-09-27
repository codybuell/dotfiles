#!/bin/bash
#
# Brew
#
# Bootstrap homebrew, install packages, install casks, and startup services.
#
# Not all software is available via brew. Here are some packages I use that
# have to be manually installed. Also see `mas.sh` for app store software.
#
#         - microsoft office          --> office 365 website
#         - on1                       --> vendor website

# Author(s): Cody Buell
#
# Requisite: none
#
# Tasks: - [ ] virtualbox installs on the second pass, first fails, not listed,
#              but is acually installed
#
# Usage: make brew
#        ./brew.sh
#        sh -c “$(curl -fsSL https://raw.githubusercontent.com/codybuell/dotfiles/master/scripts/brew.sh)”

################################################################################
################################################################################
##                                                                            ##
##  Configuration                                                             ##
##                                                                            ##
##  Define packages and casks to be installed, services to be started.        ##
##                                                                            ##
################################################################################
################################################################################

PACKAGES=( \
    'ack' \                         # enhanced grep like functionality for development
    'ag' \                          # silver searcher, ack like func
    'asciinema' \                   # terminal screen recordings
    'awscli' \                      # aws api cli client
#   'clipper' \                     # clipboard listener service, dep for vim configs
    'composer' \                    # php package manager
    'coreutils' \                   # gnu replacements for core utilities (gls, gdate, g*, etc)
    'direnv' \                      # dynamically set environment variables per directory
    'dos2unix' \                    # encoding conversion tool
    'elinks' \                      # text based web browser, used with mutt
    'ffmpeg' \                      # video encoding and editing utility
    'fwknop' \                      # port knocking
    'gcc' \                         # gnu c compiler
    'gdal' \                        # geographic tool for map development (org2org)
    'git' \                         # git scm
    'git-lfs' \                     # large file support for git
    'gnu-sed' \                     # needed for lbdbq m_muttalias module to work
    'gnupg' \                       # gpg utilities for openpgp
    'go' \                          # the go programming language
    'httrack' \                     # site mirroring application
    'imagemagick' \                 # command line graphics manipulation tool
    'imapfilter' \                  # tool for organizing mail directly on the server
    'isync' \                       # package containing mbsync, imap sync to local fs
    'jq' \                          # json manipulation and parsing tool
    'lbdb' \                        # used by mutt to build email auto completes
    'lastpass-cli' \                # lastpass command line interface
    'lockrun' \                     # used for process flow control in mutt
    'mailhog' \                     # local mail trap service for testing
    'markdown' \                    # parsing of markdown syntax to html
    'mas' \                         # brew like tool for the apple app store
    'minicom' \                     # modem control and serial terminal emulation
    'msmtp' \                       # smtp client used with mutt config
    'mysql'                         # database server for local dev
    'neomutt' \                     # command line email client
    'nmap' \                        # network utility
    'notmuch' \                     # mail search for mutt
    'openssl' \                     # the one and only...
    'packer' \                      # utility for building machine templates
    'pandoc' \                      # markup converter, used with mutt to send html email
    'php' \                         # latest and greatest php
    'picocom' \                     # used with ino for serial connection to arduino
    'pinentry' \                    # interface used to prompt for gpg pins
    'python' \                      # python language
    'qrencode' \                    # utility to generate qr codes
    'ranger' \                      # cli file browser
    'reattach-to-user-namespace' \  # reattach process to background
    'rg' \                          # ripgrep, faster ack
    'ruby' \                        # use brew ruby over osx provided
    's3cmd' \                       # aws s3 utility
    'sqlite' \                      # file based database
    'terminal-notifier' \           # send osx notifications through terminal
    'tmux' \                        # terminal multiplexer
    'todo-txt' \                    # ginas handy to do list manager
    'toilet' \                      # ascii art
    'tree' \                        # file and directory listing utility
    'urlview' \                     # for viewing urls in mutt
    'vault' \                       # encrypted key value pair storage
    'vim' \                         # improved version of already installed vi
    'w3m' \                         # cli web browser
    'wakeonlan' \                   # wol client
    'watch' \                       # handy utility for monitoring
    'webkit2png' \                  # tool for screenshotting websites via command line
    'weechat' \                     # irc client
    'wget' \                        # curl alternative
    'wireshark' \                   # network traffic analyzer
    'ykman' \                       # yubikey manager (feature enabling / pgp)
    'ykpers' \                      # yubikey personalization tool (otp slots)
    'yubico-piv-tool' \             # yubekey piv manager (piv / cac card)
    'zsh' \                         # z-shell
)

# TEMPORARY UNTIL LSP READY
#   'neovim' \                      # neovim

# OLD PACKAGES
#   'alpine' \                      # command line email client
#   'ansible' \                     # configuration management utility
#   'bash' \                        # newer version of bash
#   'bash-completion' \             # bash completion, nuff said
#   'bitlbee' \                     # google chat and other client for irssi
#   'cdrtools' \                    # contains mkisofs for building custom linux isos
#   'ctags' \                       # handy development tool, needed for vim ctags
#   'ddclient' \                    # dynamic dns client, configurable for google dns
#   'figlet' \                      # ascii art
#   'gifsicle' \                    # creating gifs from videos
#   'gnu-typist' \                  # typing tutor, supports colemak
#   'irssi' \                       # command line irc client
#   'pidgin' \                      # pidgin and finch xmpp protocol clients
#   'rclone' \                      # cli for cloud storage providers
#   'sshrc' \                       # custom one time configs on remote servers

# MANAGED BY NODE SCRIPT (and nvm):
#   'node@12' \                     # server side js (LTS Version as of 2020.09.17)
#   'yarn' \                        # bower replacement with checksums

CASKS=( \
    'amazon-workspaces' \           # aws vdi client
    'balenaetcher' \                # img to sd card writer
    'bartender' \                   # tool for simplifying the menubar
    'bitwarden' \                   # password / secret management
    'chromedriver' \                # webapp testing server
    'cubicsdr' \                    # good sdr dongle front end
    'docker' \                      # the docker engine
    'dropbox' \                     # file collaboration
    'fantastical' \                 # calendar replacement
    'firefox' \                     # alternative web browser
    'google-chrome' \               # chrome browser
    'google-drive-file-stream' \    # file collaboration
    'hammerspoon' \                 # osx automation tool
    'imageoptim' \                  # image file optimizer
    'iterm2' \                      # improved terminal emulator
    'karabiner-elements' \          # keyboard layout customization
    'keycastr' \                    # show keystrokes on screen
    'libreoffice' \                 # open source office suite
    'licecap' \                     # gifcasting utility
    'meshmixer' \                   # 3d modeling software
    'obs' \                         # open broadcast software
    'qlstephen' \                   # ability to open all plain text files in quick look
    'sketch' \                      # graphics design and layout
    'slack' \                       # collaboration and chat application
    'steam' \                       # steam gaming service
    'tg-pro' \                      # advanced fan control
    'vagrant' \                     # vms as packages management solution
    'virtualbox' \                  # virtualization utility
    'vmware-horizon-client' \       # vdi client
    'xquartz' \                     # osxs implemenrtation of x11
    'inkscape' \                    # vector graphics application, must be last
    'zoomus' \                      # zoom video conferencing app
)

# OLD CASKS
#   'balsamiq-mockups' \            # wireframing tool
#   'bitbar' \                      # shell output in menubar
#   'geektool' \                    # desktop information center
#   'itsycal' \                     # menubar calendar
#   'seil' \                        # utility for remapping caps lock
#   'ubersicht' \                   # alternative to geektool
#   'caskroom/versions/google-chrome-canary'  # bleeding edge chrome

SERVICES=( \
    'clipper' \
)

# INACTIVE SERVICES
#   'isync' \
#   'mailhog' \
#   'mysql' \
#   'php' \
#   'unbound' \
#   'vault' \

# OLD SERVICES
#   'bitlbee' \
#   'ddclient' \

################################################################################
################################################################################
##                                                                            ##
##  Run It                                                                    ##
##                                                                            ##
##  Bootstrap homebrew if needed, install and configure all the bits.         ##
##                                                                            ##
################################################################################
################################################################################

########################
# INSTALL DEPENDENCIES #
########################

# install xcode tools if necessary
[[ `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep -c version` -eq 0 ]] && {
  xcode-select --install
}

# install brew if necessary
which brew > /dev/null
[[ $? -gt 0 ]] && {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
}

#############
# CONFIGURE #
#############

# disable analytics
brew analytics off

####################
# UPDATE & UPGRADE #
####################

# try to update brew
brew update

# try to upgrade brew
brew upgrade

#####################
# RUN INSTALLATIONS #
#####################

# install brew casks
for i in ${CASKS[@]}; do
  # echo "brew cask install $i"
  brew cask install $i
done

# install brew packages
for i in ${PACKAGES[@]}; do
  brew install $i
done

# hack until neovim lsp is ready
brew install neovim --HEAD

##################
# START SERVICES #
##################

# start up services
for i in ${SERVICES[@]}; do
  brew services start $i
done
