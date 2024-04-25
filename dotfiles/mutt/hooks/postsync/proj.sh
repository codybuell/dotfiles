#!/bin/sh

~/.mutt/scripts/notmuch.sh

find ~/.mail/Proj/Proj -type f -mtime -365 -exec sh -c 'cat {} | lbdb-fetchaddr' \;
