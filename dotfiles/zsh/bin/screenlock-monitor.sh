#!/bin/bash

locking() {
  echo "locking screen at `date`" > ~/.sclmonitor.log
  $HOME/.mutt/scripts/control.sh pause >> ~/.sclmonitor.log
}

unlocking() {
  echo "unlocking screen at `date`" >> ~/.sclmonitor.log
  $HOME/.mutt/scripts/control.sh resume >> ~/.sclmonitor.log
}

loop() {
  while true; do
    read X
    if echo $X | grep "boolean true" &> /dev/null; then
      locking
    elif echo $X | grep "boolean false" &> /dev/null; then
      unlocking
    fi
  done
}

dbus-monitor --session "type='signal',interface='org.gnome.ScreenSaver'" | loop
