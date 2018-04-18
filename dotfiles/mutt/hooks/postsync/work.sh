#!/bin/sh

~/.mutt/scripts/notmuch.sh

find ~/.mail/Work/Work -type f -mtime -30 -exec sh -c 'cat {} | lbdb-fetchaddr' \;
