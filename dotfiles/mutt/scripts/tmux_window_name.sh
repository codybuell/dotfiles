#!/bin/sh

WINDOWNAME=`tmux display-message -t home:1 -p '#W'`

INBOXHOME="$HOME/.mail/Home/Home/new/"
INBOXWORK="$HOME/.mail/Work/Work/new/"
INBOXCLIENT="$HOME/.mail/Client/Client/new/"

NEWHOME=`find $INBOXHOME -type f | wc -l | sed 's/ //g'`
NEWWORK=`find $INBOXWORK -type f | wc -l | sed 's/ //g'`
NEWCLIENT=`find $INBOXCLIENT -type f | wc -l | sed 's/ //g'`

tmux rename-window -t home:1 "H:$NEWHOME W:$NEWWORK C:$NEWCLIENT "

echo "H:$NEWHOME W:$NEWWORK C:$NEWCLIENT"
echo
