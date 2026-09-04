#!/bin/sh

~/.mutt/scripts/notmuch.sh

find ~/.mail/Desert/Desert -type f -mtime -365 -exec sh -c 'cat {} | lbdb-fetchaddr' \;
