#!/bin/sh

if [ $# -ne 1 ]; then
  echo "error: expected exactly 1 argument, got $#."
  exit 1
fi

# resolve the account's capitalized name from ~/.mutt/accounts (generated
# from the MailAccounts .config key)
CAPS=$(awk -v a="$1" '!/^#/ && $1 == a { print $2 }' "$HOME/.mutt/accounts")

if [ -z "$CAPS" ]; then
  echo "error: unrecognized account handle: $1."
  exit 1
fi

SYNC="$CAPS-Download"

echo "Downloading $SYNC..."
mbsync "$SYNC"
