#!/bin/sh

~/.mutt/scripts/notmuch.sh

find ~/.mail/Work/Work -type f -mtime -365 -exec sh -c 'cat {} | lbdb-fetchaddr' \;
