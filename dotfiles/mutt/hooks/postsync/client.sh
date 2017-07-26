#!/bin/sh

~/.mutt/scripts/notmuch.sh

find ~/.mail/Client/Client -type f -mtime -30d -exec sh -c 'cat {} | lbdb-fetchaddr' \;
