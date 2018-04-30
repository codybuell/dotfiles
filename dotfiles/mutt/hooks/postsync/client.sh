#!/bin/sh

~/.mutt/scripts/notmuch.sh

find ~/.mail/Client/Client -type f -mtime -365 -exec sh -c 'cat {} | lbdb-fetchaddr' \;
