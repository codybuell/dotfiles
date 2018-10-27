#!/bin/bash
#
# Brew
#
# Install brew and brew packages.
#
# Author(s): Cody Buell
#
# Revisions: 2016.07.18 Initial framework.
#
# Requisite: 
#
# Task List:
#
# Usage: ./brew.sh

PACKAGES=( \
    'ack' \                         # enhanced grep like functionality for development
    'ag' \                          # silver searcher, ack like func
    'alpine' \                      # command line email client
    'ansible' \                     # configuration management utility
    'asciinema' \                   # terminal screen recordings
    'awscli' \                      # aws api cli client
    'bash' \                        # newer version of bash
    'bash-completion' \             # bash completion, nuff said
    'bitlbee' \                     # google chat and other client for irssi
    'cdrtools' \                    # contains mkisofs for building custom linux isos
    'chromedriver' \                # webapp testing server
    'clipper' \                     # clipboard listener service
    'composer' \                    # php package manager
    'coreutils' \                   # gnu replacements for core utilities (gls, gdate, g*, etc)
    'ctags' \                       # handy development tool, needed for vim ctags
    'ddclient' \                    # dynamic dns client, configurable for google dns
    'docker' \                      # the docker engine
    'docker-completion' \           # autocompletion for docker
    'docker-compose' \              # for building machines from yaml definitions
    'docker-compose-completion' \   # autocompletion for docker-compose
    'docker-machine' \              # manages machines as you can’t use docker directly on osx
    'docker-machine-completion' \   # autocompletion for docker-machine
    'dos2unix' \                    # encoding conversion tool
    'elinks' \                      # text based web browser, used with mutt
    'ffmpeg' \                      # video encoding and editing utility
    'figlet' \                      # ascii art
    'fwknop' \                      # port knocking
    'gcc' \                         # gnu c compiler
    'gdal' \                        # geographic tool for map development (org2org)
    'gifsicle' \                    # creating gifs from videos
    'git' \                         # git scm
    'git-lfs' \                     # large file support for git
    'gnu-typist' \                  # typing tutor, supports colemak
    'gnupg2' \                      # gpg utilities for openpgp
    'go' \                          # the go programming language
    'httrack' \                     # site mirroring application
    'imagemagick' \                 # command line graphics manipulation tool
    'imapfilter' \                  # tool for organizing mail directly on the server
    'irssi' \                       # command line irc client
    'isync' \                       # package containing mbsync, imap sync to local fs
    'jq' \                          # json manipulation and parsing tool
    'lbdb' \                        # used by mutt to build email auto completes
    'lockrun' \                     # used for process flow control in mutt
    'mailhog' \                     # local mail trap service for testing
    'markdown' \                    # parsing of markdown syntax to html
    'minicom' \                     # modem control and serial terminal emulation
    'msmtp' \                       # smtp client used with mutt config
    'mysql'                         # database server for local dev
    'neomutt' \                     # command line email client
    'nmap' \                        # network utility
    'node' \                        # server side js
    'notmuch' \                     # mail search for mutt
    'openssl' \                     # the one and only...
    'packer' \                      # utility for building machine templates
    'pandoc' \                      # markup converter, used with mutt to send html email
    'php' \                         # latest and greatest php
    'picocom' \                     # used with ino for serial connection to arduino
    'pidgin' \                      # pidgin and finch xmpp protocol clients
    'python' \                      # python language
    'python3' \                     # python 3 language
    'ranger' \                      # cli file browser
    'rclone' \                      # cli for cloud storage providers
    'reattach-to-user-namespace' \  # reattach process to background
    'rg' \                          # ripgrep, faster ack
    'ruby' \                        # use brew ruby over osx provided
    's3cmd' \                       # aws s3 utility
    'sqlite' \                      # file based database
    'sshrc' \                       # custom one time configs on remote servers
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
    'wget' \                        # curl alternative
    'wireshark' \                   # network traffic analyzer
    'yarn' \                        # bower replacement with checksums
    'ykman' \                       # yubikey manager (feature enabling / pgp)
    'ykpers' \                      # yubikey personalization tool (otp slots)
    'yubico-piv-tool' \             # yubekey piv manager (piv / cac card)
    'zsh' \                         # z-shell
)

CASKS=( \
    'amazon-workspaces' \           # aws vdi client
    'balsamiq-mockups' \            # wireframing tool
    'bartender' \                   # tool for simplifying the menubar
    'bitbar' \                      # shell output in menubar
    'cubicsdr' \                    # good sdr dongle front end
    'etcher' \                      # img to sd card writer
    'firefox' \                     # alternative web browser
    'geektool' \                    # desktop information center
    'google-chrome' \               # chrome browser
    'google-drive-file-stream' \    # file collaboration
    'hammerspoon' \                 # osx automation tool
    'imageoptim' \                  # image file optimizer
    'iterm2' \                      # improved terminal emulator
    'itsycal' \                     # menubar calendar
    'karabiner-elements' \          # keyboard layout customization
    'keycastr' \                    # show keystrokes on screen
    'libreoffice' \                 # open source office suite
    'licecap' \                     # gifcasting utility
    'qlstephen' \                   # ability to open all plain text files in ql
    'seil' \                        # utility for remapping caps lock
    'sketch' \                      # graphics design and layout
    'slack' \                       # collaboration and chat application
    'ubersicht' \                   # alternative to geektool
    'vagrant' \                     # vms as packages management solution
    'virtualbox' \                  # virtualization utility
    'vmware-horizon-client' \       # vdi client
    'xquartz' \                     # osxs implemenrtation of x11
    'inkscape' \                    # vector graphics application, must be last
)

# other casks of interest
#   'caskroom/versions/google-chrome-canary'  # bleeding edge chrome

# not available via brew cask
#  - screenie                       --> download from vendor
#  - meshmixer                      --> download from vendor
#  - hazeover                       --> app store
#  - noizio                         --> app store
#  - screenflow6                    --> app store
#  - microsoft remote desktop       --> app store
#  - wifi explorer                  --> app store
#  - aperture                       --> app store
#  - xcode                          --> app store
#  - icon slate                     --> app store
#  - yubikey personalization tool   --> app store

# install xcode tools if necessary
[[ `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep -c version` -eq 0 ]] && {
  xcode-select --install
}

# install brew if necessary
which brew > /dev/null
[[ $? -gt 0 ]] && {
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

# try to update brew
brew update

# try to upgrade brew
brew upgrade

# install brew packages
for i in ${PACKAGES[@]}; do
  brew install $i
done

# install packages that need flags
brew install weechat --with-aspell --with-lua --with-perl --with-python@2 --with-ruby     # chat client

# install brew casks
for i in ${CASKS[@]}; do
  # echo "brew cask install $i"
  brew cask install $i
done

# start up services
#brew services start --all
brew services start bitlbee
brew services start clipper
brew services start mysql
#brew services start ddclient

# any necessary re-linking
brew unlink gnupg
brew link gnupg2

exit 0
