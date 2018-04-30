#!/bin/sh

~/.mutt/scripts/notmuch.sh

find ~/.mail/Home/Home -type f -mtime -365 -exec sh -c 'cat {} | lbdb-fetchaddr' \;
