#!/bin/sh

if [ $# -ne 1 ]; then
  echo "error: expected exactly 1 argument, got $#"
  exit 1
fi

ACCOUNT="$1"
BACKOFF=0
MAX_BACKOFF=480 # 8 minutes

mkdir -p $HOME/.mutt/tmp

PIDFILE="$HOME/.mutt/tmp/sync-$1.pid"
echo $$ > "$PIDFILE"
trap "rm -f '$PIDFILE'" SIGTERM

function delay() {
  if [ $BACKOFF -ne 0 ]; then
    echo "Backing off for ${BACKOFF}s."
    sleep $BACKOFF
  fi
}

function backoff() {
  if [ $BACKOFF -eq 0 ]; then
    BACKOFF=60
  elif [ $BACKOFF -ge $MAX_BACKOFF ]; then
    BACKOFF=$MAX_BACKOFF
  else
    BACKOFF=$(expr $BACKOFF '*' 2)
  fi
}

while true; do
  if [ -x "${HOME}/.mutt/hooks/presync/${ACCOUNT}.sh" ]; then
    "${HOME}/.mutt/hooks/presync/${ACCOUNT}.sh" || {
      echo "Presync hook exited with status $?; skipping sync."
      sleep 60
      BACKOFF=0
      continue
    }
  fi

  delay

  echo "Running imapfilter ($ACCOUNT):"
  echo

  ONCE=1 time imapfilter -vc "${HOME}/.imapfilter/${ACCOUNT}.lua" -t {{ CONFGDIR }}/assets/system_root_certificates.pem || {
    [[ -f /etc/redhat-release ]] && {
      notify-send "imapfilter" "imapfilter ($ACCOUNT) exited"
    } || {
      reattach-to-user-namespace terminal-notifier -title imapfilter -message "imapfilter ($ACCOUNT) exited"
    }
    backoff
    continue
  }

  echo
  echo "Running mbsync ($ACCOUNT):"
  echo

  [[ -f /etc/redhat-release ]] && {
    time timeout 600 mbsync "$ACCOUNT" || {
      notify-send "mbsync" "mbsync ($ACCOUNT) exited"
      backoff
      continue
    }
  } || {
    time gtimeout 600 mbsync "$ACCOUNT" || {
      reattach-to-user-namespace terminal-notifier -title mbsync -message "mbsync ($ACCOUNT) exited"
      backoff
      continue
    }
  }

  echo
  echo "Running postsync hooks ($ACCOUNT):"
  echo

  time ~/.mutt/hooks/postsync/$ACCOUNT.sh # Runs notmuch, lbdb-fetchaddr etc

  echo
  echo "Deduplicating lbdb-fetchaddr db:"

  CURTIME=`date '+%Y.%m.%d.%H.%M.%S'`
  awk '!seen[$1]++' ~/.lbdb/m_inmail.utf-8 > /tmp/m_inmail.$CURTIME.utf-8 && mv /tmp/m_inmail.$CURTIME.utf-8 ~/.lbdb/m_inmail.utf-8

  echo
  echo "Updating mailboxes listing:"

  ~/.mutt/scripts/mailboxes.rb

  echo
  echo "Updating tmux window name:"

  ~/.mutt/scripts/tmux_window_name.sh

  echo "Finished at $(date)."
  echo "Sleeping for 1m..."
  echo

  BACKOFF=0
  sleep 60
done
