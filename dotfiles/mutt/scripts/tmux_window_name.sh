#!/bin/sh

# Build "H:2 K:0 D:1 " style window title from unread counts, one segment per
# account in ~/.mutt/accounts (generated from the MailAccounts .config key).

LABEL=""
while read -r name caps key flags; do
  case "$name" in ''|\#*) continue ;; esac
  COUNT=$(find "$HOME/.mail/$caps/$caps/new/" -type f 2>/dev/null | wc -l | sed 's/ //g')
  INITIAL=$(printf %.1s "$caps")
  LABEL="$LABEL$INITIAL:$COUNT "
done < "$HOME/.mutt/accounts"

tmux rename-window -t HOME:1 "$LABEL"

echo "$LABEL"
echo
