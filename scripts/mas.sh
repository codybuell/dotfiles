#!/bin/bash
#
# MAS
#
# Install Apple App Store software packages.
#
# Nix  - General package management on osx / linux
# Brew - OSX applications and additional softwares that don't work well w/ Nix
# Mas  - OSX applications from the App Store (purchased or not avail via Brew)
# ??   - Linux native package managers, bits that don't work well with Nix
#
# Author(s): Cody Buell
#
# Requisite: - mas (installed via nix-env or brew)
#            - logged into apple store
#
# Tools:
#
# Usage: make mas
#        ./mas.sh

# shellcheck source=./library.sh
source "${BASH_SOURCE%/*}/library.sh"

################################################################################
#                                                                              #
#  Configuration                                                               #
#                                                                              #
#  Define applications to be installed. Note that items flagged with a *       #
#  are purchased apps. First runs for purchases can be run with the command    #
#  `mas purchase [app]`. Adjust the APPLICATIONS list accordingly.             #
#                                                                              #
################################################################################

APPLICATIONS=( \
    '1352778147' \                 # Bitwarden
    '494803304' \                  # * WiFi Explorer (2.6.2)
    '1107828211' \                 # * ScreenFlow (6.2.2)
#   '405399194' \                  # Kindle (1.29.0)
#   '409183694' \                  # Keynote (10.1)
#   '1295203466' \                 # Microsoft Remote Desktop (10.4.0)
    '928871589' \                  # * Noizio (2.0.7)
    '890031187' \                  # * Marked 2 (2.6.1)
#   '409201541' \                  # Pages (10.1)
    '430798174' \                  # * HazeOver (1.8.6)
    '439697913' \                  # * Icon Slate (4.6.0)
#   '682658836' \                  # GarageBand (10.3.5)
#   '409203825' \                  # Numbers (10.1)
#   '926036361' \                  # LastPass (4.4.0)
    '497799835' \                  # Xcode (latest)
#   '1444383602' \                 # * GoodNotes (5.5.8)
    '965442961' \                  # Screenie (2.2.2)
)

ARMAPPS=( \
    '1215230801' \                 # tokaido
    '311941991' \                  # myst classic
    '400293367' \                  # riven
    '681966300' \                  # suburbia
    '561521557' \                  # agricola
    '517685886' \                  # le havre the harbor
    '1118398079' \                 # agricola all creatures 2p
    '1075851197' \                 # patchwork the game
    '1044671796' \                 # le havre the inland port
    '1100292960' \                 # castles of mad king ludwig
    '432504470' \                  # ticket to ride
    '1162168455' \                 # terra mystica
    '966245474' \                  # through the ages
    '933026434' \                  # brass
    '775474270' \                  # set mania
    '1353471030' \                 # terraforming mars
    '1330451888' \                 # pocket-city
)

################################################################################
#                                                                              #
#  Run                                                                         #
#                                                                              #
################################################################################

# handle dependencies
dep_xcode_clt

# install mas if necessary
if ! command -v mas &> /dev/null; then
  brew install mas
fi

# install apps
for i in "${APPLICATIONS[@]}"; do
  mas install "$i"
done

# install ios packages if on arm architecture
if [[ ("$(/usr/bin/uname -m)" == "arm64") || ("$(/usr/bin/uname -m)" == "x86_64" && "$(/usr/sbin/sysctl -in sysctl.proc_translated)" = "1") ]]; then
  for i in "${ARMAPPS[@]}"; do
    mas install "$i"
  done
fi

# assuming we installed xcode, accept the license
sudo xcode-select -r
sudo xcodebuild -license accept
