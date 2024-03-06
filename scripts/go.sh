#!/bin/bash
#
# Go
#
# Go get some stuff to install.  Note that the vim plugin vim-go installs a
# number of binaries.  Rather than duplicate them here, we run GoUpdateBinaries
# as part of our vim installation.
#
# Author(s): Cody Buell
#
# Requisite: Go
#
# Tasks:
#
# Usage: make go
#        scripts/go.sh

# shellcheck source=./library.sh
source "${BASH_SOURCE%/*}/library.sh"

###################
#                 #
#  package lists  #
#                 #
###################

# linux only packages
LINUX=( \
)

# osx only packages
OSX=( \
  'github.com/wincent/passage@latest' \                   # utility for proxying to osx keychain
  'github.com/keybase/go-keychain@latest' \               # golang library for osx keychain, passage dep
)

# all platforms
ALL=( \
  'golang.org/x/tools/cmd/goimports@latest' \             # go formatter and auto imports
  'github.com/arduino/arduino-language-server@latest' \   # lsp for aduino, requires clang and arduino-cli
  'golang.org/x/tools/gopls@latest' \                     # langserver
  'github.com/go-delve/delve/cmd/dlv@latest' \            # golang debugger utility
)

# no longer in use:
# 'github.com/schachmat/wego' \                           # command line weather
# 'github.com/stamblerre/gocode' \                        # replacement for nsf/gocode, deoplete-go dependency
# 'github.com/jstemmer/gotags' \
# 'github.com/dominikh/go-tools' \

###############
#             #
#  functions  #
#             #
###############

# Configure Passage
#
# Build and configure passage to start on boot.

configurepassage() {
  PASSAGE_BUILD=$(ls -1 "${GOPATH//:*/}/pkg/mod/github.com/wincent/" | grep "passage@")
  cd "${GOPATH//:*/}/pkg/mod/github.com/wincent/${PASSAGE_BUILD}" || exit
  cp contrib/com.wincent.passage.plist ~/Library/LaunchAgents                 # place launch agent
  sudo cp "${GOPATH//:*/}/bin/passage" /usr/local/bin                         # expected location for launch agent
  launchctl load -w -S Aqua ~/Library/LaunchAgents/com.wincent.passage.plist
}

#####################
#                   #
#  env preparation  #
#                   #
#####################

read_config

# set gopath if currently null
if [ -z "$GOPATH" ]; then
  export GOPATH=$GoPath
fi

# build out gopaths if necessary
for godir in ${GOPATH//:/ }; do
  [ ! -d "$godir" ] && mkdir -p $godir
done

#######################
#                     #
#  run installations  #
#                     #
#######################

# os specific installations
case $(uname -s) in
  Linux )
    for i in ${LINUX[@]}; do
      go install $i
    done
    ;;
  Darwin )
    for i in ${OSX[@]}; do
      go install $i
    done
    configurepassage
    ;;
esac

# general installations
for i in ${ALL[@]}; do
  go install $i
done

exit 0
