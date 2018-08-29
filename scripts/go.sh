#!/bin/bash
#
# Go
#
# Script to base level go packages.
#
# Author(s): Cody Buell
#
# Revisions: 2018.01.17 Initial framework.
#
# Requisite: 
#
# Resources: 
#
# Task List: 
#
# Usage: 


UNAME=`uname -s`

case $UNAME in
  Linux )
    echo
    ;;
  Darwin )
    go get github.com/wincent/passage
    go get github.com/keybase/go-keychain

    # build and configure passage to start on boot
    cd $GOPATH/src/github.com/wincent/passage
    go build
    sudo cp passage /usr/local/bin
    cp contrib/com.wincent.passage.plist ~/Library/LaunchAgents
    # NOTE: This won't work if run inside a tmux session:
    launchctl load -w -S Aqua ~/Library/LaunchAgents/com.wincent.passage.plist
    ;;
esac

go get github.com/Netflix-Skunkworks/go-jira
