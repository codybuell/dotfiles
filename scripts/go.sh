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

go get github.com/wincent/passage
go get github.com/keybase/go-keychain
go get github.com/Netflix-Skunkworks/go-jira

# build and configure passage to start on boot
cd $GOPATH/src/wincent/passage
go build
sudo cp passage /usr/local/bin
cp contrib/com.wincent.passage.plist ~/Library/LaunchAgents
# NOTE: This won't work if run inside a tmux session:
launchctl load -w -S Aqua ~/Library/LaunchAgents/com.wincent.passage.plist
