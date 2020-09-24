#!/bin/bash
#
# MAS
#
# Install Apple App Store software packages.
#
# Author(s): Cody Buell
#
# Requisite: - mas (installed via brew, accommodated here)
#            - logged into apple store
#
# Manual: Not all software is available via brew or mas. Here are some packages
#         I use that have to be manually installed.
#
#         - microsoft office          --> office 365 website
#         - on1                       --> vendor website
#
# Tasks:
#
# Usage: make mas
#        ./mas.sh
#        sh -c “$(curl -fsSL https://raw.githubusercontent.com/codybuell/dotfiles/master/scripts/mas.sh)”

################################################################################
################################################################################
##                                                                            ##
##  Configuration                                                             ##
##                                                                            ##
##  Define applications to be installed. Note that items flagged with a *     ##
##  are purchased apps. First runs for purchases can be run with the command  ##
##  `mas purchase [app]`. Adjust the APPLICATIONS list accordingly.           ##
##                                                                            ##
################################################################################
################################################################################

APPLICATIONS=( \
    '494803304' \                   # * WiFi Explorer (2.6.2)
    '1107828211' \                  # * ScreenFlow (6.2.2)
    '405399194' \                   # Kindle (1.29.0)
    '409183694' \                   # Keynote (10.1)
    '1295203466' \                  # Microsoft Remote Desktop (10.4.0)
    '928871589' \                   # * Noizio (2.0.7)
    '890031187' \                   # * Marked 2 (2.6.1)
    '409201541' \                   # Pages (10.1)
    '430798174' \                   # * HazeOver (1.8.6)
    '439697913' \                   # * Icon Slate (4.6.0)
    '682658836' \                   # GarageBand (10.3.5)
    '409203825' \                   # Numbers (10.1)
    '926036361' \                   # LastPass (4.4.0)
    '497799835' \                   # Xcode (12.0)
    '1444383602' \                  # * GoodNotes (5.5.8)
    '965442961' \                   # Screenie (2.2.2)
)

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

# install mas if necessary
which mas > /dev/null
[[ $? -gt 0 ]] && {
  brew install mas
}

#############
# CONFIGURE #
#############

# todo: sign in if needed
#prompt for $USEREMAIL
#mas signin --dialog $USEREMAIL

#####################
# RUN INSTALLATIONS #
#####################

# install apps
for i in ${APPLICATIONS[@]}; do
  mas install $i
done

# assuming we installed xcode, accept the license
sudo xcodebuild -license accept
