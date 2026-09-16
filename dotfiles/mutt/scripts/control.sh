#!/bin/sh

# account names from ~/.mutt/accounts (generated from MailAccounts in
# .config); accounts flagged nosync are kept out of every sync action
ACCOUNTS=$(awk '!/^#/ && NF && $4 !~ /nosync/ { print $1 }' "$HOME/.mutt/accounts")

###########
# Helpers #
###########

usage() {
  echo "Commands:"
  echo "  exit   - exit this control loop"
  echo "  help   - show this help"
  echo "  pause  - pause email sync"
  echo "  resume - resume email sync"
  echo "  sync   - force an immediate email sync"
}

signal() {
  SIGNAL=$1
  PIDFILE=$2
  if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    kill "$SIGNAL" "$PID"
    echo "Sent $SIGNAL signal to PID $PID ($PIDFILE)"
  else
    echo "No signal sent (missing $PIDFILE)"
  fi
}

pause() {
  PIDFILE=$1
  signal "-STOP" "$PIDFILE"
}

resume() {
  PIDFILE=$1
  signal "-CONT" "$PIDFILE"
}

###########
# Actions #
###########

pausing() {
  for a in $ACCOUNTS; do
    pause "$HOME/.mutt/tmp/sync-$a.pid"
  done
}

resuming() {
  for a in $ACCOUNTS; do
    resume "$HOME/.mutt/tmp/sync-$a.pid"
  done
}

syncing() {
  for a in $ACCOUNTS; do
    "$HOME/.mutt/scripts/download.sh" "$a"
  done
}

##########
# Run It #
##########

if [ $# -eq 1 ]; then
  if echo "$ACCOUNTS" | grep -qx "$1"; then
    "$HOME/.mutt/scripts/sync.sh" "$1" || reattach-to-user-namespace terminal-notifier -title mutt -message "$HOME/.mutt/scripts/sync.sh ($1) exited" Enter
    exit 0
  fi
  case $1 in
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
      echo "Unrecognized argument: $1 (supported arguments: $(echo $ACCOUNTS | tr '\n' ' '), pause, resume, sync)"
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
  printf "> "
  read -r COMMAND
done
