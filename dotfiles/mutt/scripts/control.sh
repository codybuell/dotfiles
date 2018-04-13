#!/bin/sh

###########
# Helpers #
###########

function usage() {
  echo "Commands:"
  echo "  exit   - exit this control loop"
  echo "  help   - show this help"
  echo "  pause  - pause email sync"
  echo "  resume - resume email sync"
  echo "  sync   - force an immediate email sync"
}

function signal() {
  SIGNAL=$1
  PIDFILE=$2
  if [ -f "$PIDFILE" ]; then
    PID=`cat "$PIDFILE"`
    kill "$SIGNAL" "$PID"
    echo "Sent $SIGNAL signal to PID $PID ($PIDFILE)"
  else
    echo "No signal sent (missing $PIDFILE)"
  fi
}

function pause() {
  PIDFILE=$1
  signal "-STOP" "$PIDFILE"
}

function resume() {
  PIDFILE=$1
  signal "-CONT" "$PIDFILE"
}

###########
# Actions #
###########

function pausing() {
  pause "$HOME/.mutt/tmp/sync-home.pid"
  pause "$HOME/.mutt/tmp/sync-work.pid"
  pause "$HOME/.mutt/tmp/sync-client.pid"
}

function resuming() {
  resume "$HOME/.mutt/tmp/sync-home.pid"
  resume "$HOME/.mutt/tmp/sync-work.pid"
  resume "$HOME/.mutt/tmp/sync-client.pid"
}

function syncing() {
  "$HOME/.mutt/scripts/download.sh" home
  "$HOME/.mutt/scripts/download.sh" work
  "$HOME/.mutt/scripts/download.sh" client
}

##########
# Run It #
##########

if [ $# -eq 1 ]; then
  case $1 in
    home|work|client )
      "$HOME/.mutt/scripts/sync.sh" "$1" || reattach-to-user-namespace terminal-notifier -title mutt -message "~/.mutt/scripts/sync.sh ($1) exited" Enter
      exit 0
      ;;
    pause|paus|pau|pa|p )
      pausing
      exit 0
      ;;
    resume|resum|resu|res|re|r )
      resuming
      exit 0
      ;;
    sync|syn|sy|s )
      syncing
      exit 0
      ;;
    * )
      echo "Unrecognized argument: $1 (supported arguments: home, work, client, pause, resume)"
      exit 1
      ;;
  esac
elif [ $# -ne 0 ]; then
  echo "Expected 0 or 1 arguments, got $#"
  exit 1
fi

COMMAND=help
while true; do
  case $COMMAND in
    exit|exi|ex|e)
      exit
      ;;
    help|hel|he|h|\?)
      usage
      ;;
    pause|paus|pau|pa|p)
      echo "Pausing:"
      pausing
      ;;
    resume|resum|resu|res|re|r)
      echo "Resuming:"
      resuming
      ;;
    sync|syn|sy|s)
      echo "Syncing:"
      syncing
      ;;
    *)
      echo "Invalid command: $COMMAND"
      echo "Valid commands: exit, help, pause, resume, sync"
      ;;
  esac
  /bin/echo -n "> "
  read COMMAND
done
