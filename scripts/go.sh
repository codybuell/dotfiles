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

source scripts/library.sh

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
  'github.com/wincent/passage' \                   # utility for proxying to osx keychain
  'github.com/keybase/go-keychain' \               # golang library for osx keychain, passage dep
)

# all platforms
ALL=( \
  'github.com/stamblerre/gocode' \                 # replacement for nsf/gocode, deoplete-go dependency
  'golang.org/x/tools/cmd/goimports' \             # go formatter and auto imports
  'github.com/schachmat/wego' \                    # command line weather
  'github.com/arduino/arduino-language-server' \   # lsp for aduino, requires clang and arduino-cli
)

# no longer in use:
# 'github.com/jstemmer/gotags' \
# 'github.com/dominikh/go-tools' \

# all platforms with GO111MODULE=on
ALL_GO111MODULE_ON=( \
  'golang.org/x/tools/gopls@latest' \      # langserver, no -u flag, or deps will update to imcompat versions
)

###############
#             #
#  functions  #
#             #
###############

# Configure Passage
#
# Build and configure passage to start on boot.

configurepassage() {
  cd ${GOPATH//:*/}/src/github.com/wincent/passage
  go build
  cp contrib/com.wincent.passage.plist ~/Library/LaunchAgents                 # place launch agent
  cp passage /usr/local/bin                                                   # expected location for launch agent
  launchctl load -w -S Aqua ~/Library/LaunchAgents/com.wincent.passage.plist  # fails if run inside tmux
}

#####################
#                   #
#  env preparation  #
#                   #
#####################

readconfig

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
case `uname -s` in
  Linux )
    for i in ${LINUX[@]}; do
      go get -u $i
    done
    ;;
  Darwin )
    for i in ${OSX[@]}; do
      go get -u $i
    done
    configurepassage
    ;;
esac

# general installations
for i in ${ALL[@]}; do
  go get -u $i
done

# go111module installations NO -u OR GOMODULES WILL BREAK
for i in ${ALL_GO111MODULE_ON[@]}; do
  GO111MODULE=on go get $i
done

exit 0
