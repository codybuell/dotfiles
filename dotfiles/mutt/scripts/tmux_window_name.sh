#!/bin/sh

# WINDOWNAME=$(tmux display-message -t HOME:1 -p '#W')

INBOXHOME="$HOME/.mail/Home/Home/new/"
INBOXWORK="$HOME/.mail/Work/Work/new/"
INBOXPROJ="$HOME/.mail/Proj/Proj/new/"

NEWHOME=$(find "$INBOXHOME" -type f | wc -l | sed 's/ //g')
NEWWORK=$(find "$INBOXWORK" -type f | wc -l | sed 's/ //g')
NEWPROJ=$(find "$INBOXPROJ" -type f | wc -l | sed 's/ //g')

tmux rename-window -t HOME:1 "H:$NEWHOME W:$NEWWORK P:$NEWPROJ "

echo "H:$NEWHOME W:$NEWWORK P:$NEWPROJ"
echo
