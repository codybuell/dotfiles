#!/bin/sh

~/.mutt/scripts/notmuch.sh

find ~/.mail/Kion/Kion -type f -mtime -365 -exec sh -c 'cat {} | lbdb-fetchaddr' \;
