#!/bin/sh

WINDOWNAME=`tmux display-message -t home:1 -p '#W'`

INBOXHOME="$HOME/.mail/Home/Home/new/"
INBOXWORK="$HOME/.mail/Work/Work/new/"
INBOXCLIENT="$HOME/.mail/Client/Client/new/"

NEWHOME=`find $INBOXHOME -type f | wc -l`
NEWWORK=`find $INBOXWORK -type f | wc -l`
NEWCLIENT=`find $INBOXCLIENT -type f | wc -l`

tmux rename-window -t home:1 "H:$NEWHOME W:$NEWWORK C:$NEWCLIENT"
