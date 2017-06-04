#!/bin/bash
#
# Brew
#
# Brew bootstrapping script.
#
# Author(s): Cody Buell
#
# Revisions: 2016.07.18 Initial framework.

PACKAGES=( \
    'ack' \                          # enhanced grep like functionality for development
    'alpine' \                       # command line email client
    'ansible' \                      # configuration management utility
    'awscli' \                       # aws api cli client
    'bash' \                         # newer version of bash
    'bash-completion' \              # bash completion, nuff said
    'bitlbee' \                      # google chat and other client for irssi
    'cdrtools' \                     # contains mkisofs for building custom linux isos
    'clipper' \                      # clipboard listener service
    'coreutils' \                    # gnu replacements for core utilities (gls, gdate, g*, etc)
    'ctags' \                        # handy development tool, needed for vim ctags
    'ddclient' \                     # dynamic dns client, configurable for google dns
    'dos2unix' \                     # encoding conversion tool
    'ffmpeg' \                       # video encoding and editing utility
    'figlet' \                       # ascii art
    'fwknop' \                       # port knocking
    'gcc' \                          # gnu c compiler
    'gdal' \                         # geographic tool for map development (org2org)
    'gifsicle' \                     # creating gifs from videos
    'git' \                          # git scm
    'git-lfs' \                      # large file support for git
    'gnu-typist' \                   # typing tutor, supports colemak
    'go' \                           # the go programming language
    'homebrew/php/composer' \        # php package manager
    'httrack' \                      # site mirroring application
    'imagemagick' \                  # command line graphics manipulation tool
    'irssi' \                        # command line irc client
    'jq' \                           # json manipulation and parsing tool
    'markdown' \                     # parsing of markdown syntax to html
    'minicom' \                      # modem control and serial terminal emulation
    'nmap' \                         # network utility
    'node' \                         # server side js
    'openssl' \                      # the one and only...
    'packer' \                       # utility for building machine templates
    'php70' \                        # (or higher)
    'php70-mcrypt' \                 # (or higher)  encryption library required for laravel development
    'picocom' \                      # used with ino for serial connection to arduino
    'pidgin' \                       # pidgin and finch xmpp protocol clients
    'python' \                       # python language
    'rclone' \                       # cli for cloud storage providers
    'reattach-to-user-namespace' \   # reattach process to background
    's3cmd' \                        # aws s3 utility
    'sqlite' \                       # file based database
    'tmux' \                         # terminal multiplexer
    'todo-txt' \                     # gina's handy to do list manager
    'toilet' \                       # ascii art
    'tree' \                         # file and directory listing utility
    'vault' \                        # encrypted key value pair storage
    'vim' \                          # improved version of already installed vi
    'wakeonlan' \                    # wol client
    'watch' \                        # handy utility for monitoring
    'weechat' \                      # chat client
    'webkit2png' \                   # tool for screenshotting websites via command line
    'wget' \                         # curl alternative
    'wireshark' \                    # network traffic analyzer
    'zsh' \                          # z-shell
)

CASKS=( \
    'amazon-workspaces' \            # aws vdi client
    'balsamiq-mockups' \             # wireframing tool
    'bartender' \                    # tool for simplifying the menubar
    'bitbar' \                       # shell output in menubar
    'cubicsdr' \                     # good sdr dongle front end
    'dockertoolbox' \                # docker suite for osx
    'etcher' \                       # img to sd card writer
    'firefox' \                      # alternative web browser
    'geektool' \                     # desktop information center
    'google-drive' \                 # file collaboration
    'hammerspoon' \                  # osx automation tool
    'inkscape' \                     # open source vector graphics application
    'imageoptim' \                   # image file optimizer
    'iterm2' \                       # improved terminal emulator
    'itsycal' \                      # menubar calendar
    'karabiner' \                    # keyboard layout customization
    'keycastr' \                     # show keystrokes on screen
    'libreoffice' \                  # open source office suite
    'licecap' \                      # gifcasting utility
    'qlstephen' \                    # ability to open all plain text files in ql
    'seil' \                         # utility for remapping caps lock
    'sketch' \                       # graphics design and layout
    'slack' \                        # collaboration and chat application
    'ubersicht' \                    # alternative to geektool
    'vagrant' \                      # vm's as packages management solution
    'virtualbox' \                   # virtualization utility
    'vmware-horizon-client' \        # vdi client
    'xquartz' \                      # osx's implemenrtation of x11
)

# not available via brew cask
#  - screenie

# install brew if necessary
which brew > /dev/null
[[ $? -gt 0 ]] && {
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

# update brew if necessary
brew update

# upgrade brew if neccessary
brew upgrade

# install brew packages
for i in ${PACKAGES[@]}; do
  # echo "brew install $i"
  brew install $i
done

# install brew casks
for i in ${CASKS[@]}; do
  # echo "brew cask install $i"
  brew cask install $i
done
