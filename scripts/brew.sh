#!/bin/bash
#
# Brew
#
# Bootstrap homebrew, install packages, install casks, and startup services.
# Intended to be used in conjunction with Nix, and Mas to provision packages /
# applications used on an OSX install.
#
# Nix  - General package management on osx / linux
# Brew - OSX applications and additional softwares that don't work well w/ Nix
# Mas  - OSX applications from the App Store (purchased or not avail via Brew)
# ??   - Linux native package managers, bits that don't work well with Nix
#
# Author(s): Cody Buell
#
# Requisite: - xcode command line utilities
#            - dotfiles (specifically shell with homebrew injected into $PATH)
#
# Tools:
#
# Usage: make brew
#        ./brew.sh

# shellcheck source=./library.sh
source "${BASH_SOURCE%/*}/library.sh"

################################################################################
#                                                                              #
#  Configuration                                                               #
#                                                                              #
################################################################################

PACKAGES=( \
  'ack' \                             # recursive grep like search
  'asciinema' \                       # terminal session recorder
  'automake' \                        # make toolkit
  'awscli' \                          # aws command line tool
  'azure-cli' \                       # azure api cli client
  'bc' \                              # gnu software calculator
  'coreutils' \                       # gnu utility toolkit
  'danmx/sigil/sigil' \               # aws ssm manager client
  'direnv' \                          # dynamic folder based environments
  'dive' \                            # docker container analyzer
  'dos2unix' \                        # encoding conversion tool
  'elinks' \                          # text based web browser, used with mutt
  'ffmpeg' \                          # audio video swiss army knife
  'fwknop' \                          # port knocking
  'gcc' \                             # gnu c compiler
  'git' \                             # distributed version control
  'git-lfs' \                         # large file support for git
  'gnupg' \                           # gpg utilities for openpgp
  'gnu-sed' \                         # needed for lbdbq m_muttalias module to work
  'go' \                              # the go programming language
  'helm' \                            # kubernetes manifest templating
  'imagemagick' \                     # command line graphics manipulation tool
  'imapfilter' \                      # tool for organizing mail directly on the server
  'isync' \                           # package containing mbsync, imap sync to local fs
  'jq' \                              # query utility for json
  'lbdb' \                            # used by mutt to build email auto completes
  'libpq' \                           # postgres client library, psql, pg_dump, etc
  'lockrun' \                         # used for process flow control in mutt
  'lua' \                             # the lua programming language
  'lua-language-server' \             # the lua language server
  'luarocks' \                        # lua package manager
  'mas' \                             # mac app store package manager
  'minicom' \                         # modem control and serial terminal emulation
  'minikube' \                        # local kubernetes
  'msmtp' \                           # smtp client used with mutt config
  'neomutt' \                         # command line email client
  'neovim' \                          # modern vim derivative
  'nmap' \                            # network utility
  'notmuch' \                         # mail search for mutt
  'openconnect' \                     # robust vpn client for cisco vpns
  'openssl' \                         # the one and only...
  'pandoc' \                          # markup converter, used with mutt to send html email
  'pcalc' \                           # cli programming calculator
  'picocom' \                         # used with ino for serial connection to arduino
  'pinentry' \                        # interface used to prompt for gpg pins
  'pinentry-mac' \                    # gui interface used to prompt for gpg pins
  'python' \                          # python language
  'qemu' \                            # virtualization tool of choice
  'qrencode' \                        # utility to generate qr codes
  'reattach-to-user-namespace' \      # reattach tmux etc to user namespace
  'rg' \                              # ripgrep, dep for command-t
  'rsync' \                           # newer version than out of box, fewer errors
  'rust' \                            # rust programming language, needed for c7n
  's3cmd' \                           # aws s3 utility
  'shellcheck' \                      # linter / checker for shell scripts
  'smimesign' \                       # signing utility for use with git
  'sqlite' \                          # file based database
  'terminal-notifier' \               # send osx notifications via terminal
  'the_silver_searcher'               # ag, ack and ripgrep alternative
  'tmux' \                            # terminal multiplexer
  'tree' \                            # file and directory listing utility
  'urlview' \                         # for viewing urls in mutt
  'uv' \                              # python universal package manager
  'vault' \                           # encrypted key value pair storage
  'w3m' \                             # cli web browser
  'wget' \                            # curl alternative
  'watch' \                           # handy utility for monitoring
  'watchman' \                        # file watcher, dep for command-t
  'weechat' \                         # irc client
  'yamale' \                          # schema and validator for yaml
  'ykman' \                           # yubikey manager (feature enabling / pgp)
  'ykpers' \                          # yubikey personalization tool (otp slots)
  'yq' \                              # jq for yaml
  'yubico-piv-tool' \                 # yubekey piv manager (piv / cac card)
)

CASKS=( \
  'bartender' \                       # tool for simplifying the menubar
  'bitwarden' \                       # password / secret management
  'blender' \                         # 3d cad software
  'cubicsdr' \                        # good sdr dongle front end
  'docker' \                          # the docker engine
  'dropbox' \                         # file collaboration
  'fantastical' \                     # calendar replacement
  'firefox' \                         # alternative web browser
  'gimp' \                            # open source bitmap editor
  'google-chrome' \                   # chrome browser
  'google-drive' \                    # file collaboration
  'hammerspoon' \                     # osx automation tool
  'imageoptim' \                      # image file optimizer
  'inkscape' \                        # vector graphics application, must be last
  'kap' \                             # screen recorder to gif
  'karabiner-elements' \              # keyboard layout customization
  'keycastr' \                        # show keystrokes on screen
  'kitty' \                           # fast terminal that supports arm + x86
  'obs' \                             # open broadcast software
  'opensc' \                          # smartcard utility
  'raycast' \                         # spotlight search replacement
  'slack' \                           # collaboration and chat application
  'tg-pro' \                          # advanced fan control
  'vagrant' \                         # vms as packages management solution
  'via' \                             # config editor for keychron keyboard
  'wireshark' \                       # network traffic analyzer
  'xquartz' \                         # osxs implemenrtation of x11
  'yubico-yubikey-manager' \          # yubikey configuration utility
  'zoom' \                            # zoom video conferencing app
)

SERVICES=( \
  'clipper' \                         # clipboard daemon, helper
)

TAPS=( \
  'anchore/grype:grype' \             # container scanning utility
  'alt-romes/pcalc:pcalc' \           # visual binary calculator
)

###############################################################################
##                                                                            #
##  Archive                                                                   #
##                                                                            #
###############################################################################

# PACKAGES NO LONGER USED
#   'aalib' \                           # library for ascii image creation
#   'alpine' \                          # command line email client
#   'ansible' \                         # configuration management utility
#   'bash' \                            # newer version of bash
#   'bash-completion' \                 # bash completion, nuff said
#   'bitlbee' \                         # google chat and other client for irssi
#   'composer' \                        # php package manager
#   'cdrtools' \                        # contains mkisofs for building custom linux isos
#   'ctags' \                           # used by vim sidebar nav plugin
#   'ddclient' \                        # dynamic dns client, configurable for google dns
#   'efm-langserver' \                  # general purpose language server
#   'figlet' \                          # ascii art
#   'gdal' \                            # geographic tool for map development (org2org)
#   'gifsicle' \                        # creating gifs from videos
#   'gnu-typist' \                      # typing tutor, supports colemak
#   'httrack' \                         # site mirroring application
#   'irssi' \                           # command line irc client
#   'lastpass-cli' \                    # lastpass command line interface
#   'llvm' \                            # clangd
#   'mailhog' \                         # local mail trap service for testing
#   'markdown' \                        # parsing of markdown syntax to html
#   'mysql'                             # database server for local dev
#   'ninja' \                           # build system needed for sumneko lua lsp server
#   'php' \                             # latest and greatest php
#   'pidgin' \                          # pidgin and finch xmpp protocol clients
#   'ranger' \                          # cli file browser
#   'rdesktop' \                        # rdp client
#   'rclone' \                          # cli for cloud storage providers
#   'ruby' \                            # use brew ruby over osx provided
#   'sshrc' \                           # custom one time configs on remote servers
#   'todo-txt' \                        # ginas handy to do list manager
#   'toilet' \                          # ascii art
#   'unar' \                            # tool for extracting rar and exe files
#   'vim' \                             # improved version of already installed vi
#   'wakeonlan' \                       # wol client
#   'webkit2png' \                      # tool for screenshotting websites via command line
#   'zsh' \                             # z-shell

# CASKS NO LONGER USED
#   'alacritty' \                       # alacritty gpu accelerated terminal
#   'amazon-workspaces' \               # aws vdi client
#   'balenaetcher' \                    # img to sd card writer
#   'balsamiq-mockups' \                # wireframing tool
#   'bitbar' \                          # shell output in menubar
#   'chromedriver' \                    # webapp testing server
#   'geektool' \                        # desktop information center
#   'google-chrome-canary'              # bleeding edge chrome
#   'iterm2' \                          # improved terminal emulator
#   'itsycal' \                         # menubar calendar
#   'keybase' \                         # encryption and crypto wallet
#   'libreoffice' \                     # open source office suite
#   'licecap' \                         # gifcasting utility
#   'ltspice' \                         # circuit simulation software
#   'meshmixer' \                       # 3d modeling software
#   'qlstephen' \                       # ability to open all plain text files in quick look
#   'session-manager-plugin' \          # aws cli ssm plugin
#   'seil' \                            # utility for remapping caps lock
#   'sketch' \                          # graphics design and layout
#   'steam' \                           # steam gaming service
#   'synology-drive' \                  # synology drive client
#   'ubersicht' \                       # alternative to geektool
#   'virtualbox' \                      # virtualization utility
#   'vmware-horizon-client' \           # vdi client

# services no longer used
#   'mailhog' \                         # run ad-hoc as a container instead
#   'mysql' \                           # run ad-hoc as a container instead
#   'bitlbee' \                         # handled by a dedicated server
#   'ddclient' \                        # handled on a dedicated pi cluster

################################################################################
#                                                                              #
#  Run                                                                         #
#                                                                              #
################################################################################

# get and keep sudo privs for duration of the script
holdsudo

# handle dependencies
dep_xcode_clt
dep_rosetta
dep_homebrew

# disable analytics
brew analytics off

# try to update brew
log green "Updating brew and package definitions..."
brew update

# try to upgrade brew
log green "Upgrading all packages..."
brew upgrade

# install brew casks
log green "Installing casks..."
# shellcheck disable=SC2068
for i in ${CASKS[@]}; do
  brew install --cask --quiet "${i}"
done

# install brew packages
log green "Installing packages..."
# shellcheck disable=SC2068
for i in ${PACKAGES[@]}; do
  brew install --quiet "${i}"
done

# install brew taps
log green "Installing Taps..."
# shellcheck disable=SC2068
for i in ${TAPS[@]}; do
  TAP=$(echo "${i}" | awk -F":" '{print $1}')
  PKG=$(echo "${i}" | awk -F":" '{print $2}')
  brew tap "${TAP}"
  brew install "${PKG}"
done

# start up services
log green "Starting services..."
# shellcheck disable=SC2068
for i in ${SERVICES[@]}; do
  brew install --quiet "${i}"
  brew services start "${i}"
done

# manual links and fixes
brew link --force libpq
