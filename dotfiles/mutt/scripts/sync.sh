#!/bin/sh

# color helpers
if [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
  export BOLD="$(tput bold)"
  export UNDER="$(tput smul)"
  export NOUNDER="$(tput rmul)"
  export DIM="$(tput dim)"

  export BLACK="$(tput setaf 0)"
  export RED="$(tput setaf 1)"
  export GREEN="$(tput setaf 2)"
  export YELLOW="$(tput setaf 3)"
  export BLUE="$(tput setaf 4)"
  export MAGENTA="$(tput setaf 5)"
  export CYAN="$(tput setaf 6)"
  export WHITE="$(tput setaf 7)"

  export NORM="$(tput sgr0)"
fi

if [ $# -ne 1 ]; then
  echo "${RED}error: expected exactly 1 argument, got $#${NORM}"
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
    echo "${YELLOW}Backing off for ${BACKOFF}s.${NORM}"
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
      echo "${YELLOW}Presync hook exited with status $?; skipping sync.${NORM}"
      sleep 60
      BACKOFF=0
      continue
    }
  fi

  delay

  echo "${BLUE}Running imapfilter ($ACCOUNT):${NORM}"
  echo

  # ONCE=1 time imapfilter -vc "${HOME}/.imapfilter/${ACCOUNT}.lua" -t {{ CONFGDIR }}/assets/system_root_certificates.pem || {
  ONCE=1 time imapfilter -vc "${HOME}/.imapfilter/${ACCOUNT}.lua" || {
    [[ -f /etc/redhat-release ]] && {
      notify-send "imapfilter" "imapfilter ($ACCOUNT) exited"
    } || {
      reattach-to-user-namespace terminal-notifier -title imapfilter -message "imapfilter ($ACCOUNT) exited"
    }
    backoff
    continue
  }

  echo
  echo "${BLUE}Running mbsync ($ACCOUNT):${NORM}"
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

  # accounts flagged slow-archive in MailAccounts keep All Mail out of their
  # main mbsync group; sync it via <account>-archive in the first 5 minutes
  # of each hour instead (see ~/.mutt/accounts and scripts/mailgen.py)
  FLAGS=$(awk -v a="$ACCOUNT" '!/^#/ && $1 == a { print $4 }' "$HOME/.mutt/accounts")
  if [[ "$(date +%M)" -lt 5 && ",$FLAGS," == *",slow-archive,"* ]]; then
    echo "${BLUE}Running mbsync $ACCOUNT-archive:${NORM}"
    echo

    [[ -f /etc/redhat-release ]] && {
      time timeout 600 mbsync "$ACCOUNT-archive" || {
        notify-send "mbsync" "mbsync ($ACCOUNT-archive) exited"
        backoff
        continue
      }
    } || {
      time gtimeout 600 mbsync "$ACCOUNT-archive" || {
        reattach-to-user-namespace terminal-notifier -title mbsync -message "mbsync ($ACCOUNT-archive) exited"
        backoff
        continue
      }
    }
  fi

  echo
  echo "${BLUE}Running postsync hooks ($ACCOUNT):${NORM}"
  echo

  # account-specific hook wins; otherwise the generic one gets the name
  if [ -x "${HOME}/.mutt/hooks/postsync/${ACCOUNT}.sh" ]; then
    time "${HOME}/.mutt/hooks/postsync/${ACCOUNT}.sh" # notmuch, lbdb, etc
  else
    time "${HOME}/.mutt/hooks/postsync/default.sh" "$ACCOUNT"
  fi

  echo
  echo "${BLUE}Deduplicating lbdb-fetchaddr db:${NORM}"

  CURTIME=`date '+%Y.%m.%d.%H.%M.%S'`
  awk '!seen[$1]++' ~/.local/share/lbdb/m_inmail.db > /tmp/m_inmail.$CURTIME.db && mv /tmp/m_inmail.$CURTIME.db ~/.local/share/lbdb/m_inmail.db
  echo
  echo "${BLUE}Updating mailboxes listing:${NORM}"

  ~/.mutt/scripts/mailboxes.rb

  echo
  echo "${BLUE}Updating tmux window name:${NORM}"

  ~/.mutt/scripts/tmux_window_name.sh

  echo "${BLUE}Finished at $(date)."
  echo "Sleeping for 1m...${NORM}"
  echo

  BACKOFF=0
  sleep 60
done
