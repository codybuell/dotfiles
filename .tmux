#!/bin/bash

# get session name based on folder
SESSION=`basename $(pwd) | sed 's/\.//g' | tr '[:upper:]' '[:lower:]'`

# attach if session already exists
if tmux has-session -t $SESSION 2> /dev/null; then
  tmux attach -t $SESSION
  exit
fi

# else create a new session
tmux new-session -d -s $SESSION -n vim

# build out panes
tmux send-keys -t ${SESSION}:vim "git status" Enter
tmux split-window -t ${SESSION}:vim -h -p 60
tmux send-keys -t ${SESSION}:vim.right "vim -c CommandT" Enter
tmux split-window -t ${SESSION}:vim.left -v -p 60

# attach to the new session, focus left pane
tmux attach -t ${SESSION}:vim.right
