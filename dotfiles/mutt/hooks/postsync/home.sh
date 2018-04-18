#!/bin/sh

~/.mutt/scripts/notmuch.sh

find ~/.mail/Home/Home -type f -mtime -30 -exec sh -c 'cat {} | lbdb-fetchaddr' \;
