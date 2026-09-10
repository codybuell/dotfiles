#!/bin/sh

# Generic postsync hook, run by sync.sh with the account name as $1 for any
# account without its own <name>.sh alongside this file.

ACCOUNT="$1"
CAPS=$(awk -v a="$ACCOUNT" '!/^#/ && $1 == a { print $2 }' "$HOME/.mutt/accounts")
[ -z "$CAPS" ] && exit 0

~/.mutt/scripts/notmuch.sh

# harvest addresses from the last year of inbox mail
find "$HOME/.mail/$CAPS/$CAPS" -type f -mtime -365 -exec sh -c 'cat {} | lbdb-fetchaddr' \;
