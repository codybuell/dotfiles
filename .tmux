#!/bin/bash
#
# .--------------------------------------.
# |                 |                    |
# |        1        |                    |
# |                 |                    |
# |-----------------|          3         |
# |                 |                    |
# |        2        |                    |
# |                 |                    |
# '--------------------------------------'

CMDPANE1='git status'
CMDPANE2=''
CMDPANE3=''

# get session name based on folder
SESSION=`basename $(pwd) | sed 's/\.//g' | tr '[:upper:]' '[:lower:]'`

# attach if session already exists
if tmux has-session -t $SESSION 2> /dev/null; then
  tmux -u attach -t $SESSION
  exit
fi

# else create a new session
tmux new-session -d -s $SESSION -n main -x $(tput cols) -y $(tput lines)

# build out panes
tmux split-window -t ${SESSION}:main.1 -h -p 60
tmux split-window -t ${SESSION}:main.1 -v -p 60

# run commands
tmux send-keys -t ${SESSION}:main.1 "$CMDPANE1" Enter
tmux send-keys -t ${SESSION}:main.2 "$CMDPANE2" Enter
tmux send-keys -t ${SESSION}:main.3 "$CMDPANE3" Enter

# attach to the new session, focus left pane
tmux -u attach -t ${SESSION}:main.3
