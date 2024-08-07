#!/bin/bash
#
# Left:
# .--------------------------------------.
# |                      |               |
# |                      |       2       |
# |                      |               |
# |           1          |---------------|
# |                      |               |
# |                      |       3       |
# |                      |               |
# '--------------------------------------'
#
# Right:
# .--------------------------------------.
# |                |                     |
# |        1       |                     |
# |                |                     |
# |----------------|           3         |
# |                |                     |
# |        2       |                     |
# |                |                     |
# '--------------------------------------'

CMDPANE1=''
CMDPANE2='clear && git status && git branch -v'
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

# build out panes - left
tmux split-window -t ${SESSION}:main.1 -h -l 45%
tmux split-window -t ${SESSION}:main.2 -v -l 60%

# build out panes - right
# tmux split-window -t ${SESSION}:main.1 -h -l 55%
# tmux split-window -t ${SESSION}:main.1 -v -l 60%

# run commands
tmux send-keys -t ${SESSION}:main.1 "$CMDPANE1" Enter
tmux send-keys -t ${SESSION}:main.2 "$CMDPANE2" Enter
tmux send-keys -t ${SESSION}:main.3 "$CMDPANE3" Enter

# attach to the new session, focus left pane
tmux -u attach -t ${SESSION}:main.1
