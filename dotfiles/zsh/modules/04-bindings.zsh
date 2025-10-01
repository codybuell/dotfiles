################################################################################
##                                                                            ##
##  Bindings                                                                  ##
##                                                                            ##
##  Key bindings, vim mode configuration, and custom ZLE widgets.             ##
##  Provides vim-like editing with enhanced cursor shapes and shortcuts.      ##
##                                                                            ##
##  Dependencies: none                                                        ##
##  Enhanced by: tmux (for cursor shape forwarding)                           ##
##                                                                            ##
################################################################################

##############
#  Vim Mode  #
##############

# Enable vim key bindings
bindkey -v

# Reduce delay between pressing ESC and switching to normal mode
export KEYTIMEOUT=1

############################
#  Cursor Shape Functions  #
############################

# Print Device Control String for tmux passthrough
print_dcs() {
  print -n -- "\EP$1;\E$2\E\\"
}

# Set cursor shape based on mode
# 0 = block (normal mode), 1 = line (insert mode)
set_cursor_shape() {
  if [[ -n "$TMUX" ]]; then
    # tmux requires DCS sequence wrapping for escape sequence forwarding
    print_dcs tmux "\E]50;CursorShape=$1\C-G"
  else
    print -n -- "\E]50;CursorShape=$1\C-G"
  fi
}

#####################################
#  ZLE Widgets for Mode Indication  #
#####################################

# Shared cursor shape logic
_set_cursor_for_mode() {
  case $KEYMAP in
    vicmd)
      set_cursor_shape 0  # block cursor for normal mode
      ;;
    viins|main)
      set_cursor_shape 1  # line cursor for insert mode
      ;;
  esac
  zle reset-prompt
  zle -R
}

# Handle keymap changes
zle-keymap-select() {
  _set_cursor_for_mode
}

# Handle line initialization
zle-line-init() {
  _set_cursor_for_mode
}

# Reset cursor when line editing finishes
zle-line-finish() {
  set_cursor_shape 0  # block cursor
}

# Smart Ctrl+z: background/foreground toggle
fg-bg() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg  # No command in buffer, foreground last job
  else
    zle push-input  # Save current command and clear line
  fi
}

#############################
#  ZLE Widget Registration  #
#############################

#  (Only register once)       #
if [[ -z "${__BUELL[BINDINGS_INITIALIZED]:-}" ]]; then
  # Register ZLE widgets
  zle -N zle-line-init
  zle -N zle-line-finish
  zle -N zle-keymap-select
  zle -N fg-bg

  # Command line editing in external editor
  autoload -Uz edit-command-line
  zle -N edit-command-line

  __BUELL[BINDINGS_INITIALIZED]=1
fi

################################
#  Basic Navigation & Editing  #
################################

# Arrow key navigation
bindkey "\e[A" up-history         # Up arrow
bindkey "\e[B" down-history       # Down arrow

# Key bindings for enhanced history search
bindkey "^P" history-beginning-search-backward-end          # Ctrl+P
bindkey "^N" history-beginning-search-forward-end           # Ctrl+N

# Pattern-based incremental search (supports patterns like a*b)
bindkey "^R" history-incremental-pattern-search-backward    # Ctrl+R
bindkey "^S" history-incremental-pattern-search-forward     # Ctrl+S

# Character and word deletion
bindkey '^?' backward-delete-char  # Backspace
bindkey '^H' backward-delete-char  # Ctrl+h
bindkey '^W' backward-kill-word    # Ctrl+w

###############################
#  Advanced Editing Features  #
###############################

# Word selection style (matches bash behavior)
autoload -Uz select-word-style
select-word-style bash  # Only alphanumeric chars are considered WORDCHARS

# Key bindings for ZLE widgets
bindkey '^X^X' edit-command-line  # Ctrl+x Ctrl+x
bindkey '^Z' fg-bg                # Ctrl+z

# History expansion on space
bindkey ' ' magic-space

########################
#  Plugin Integration  #
########################

# Autosuggestions navigation (if plugin loaded)
bindkey '^L' forward-char          # Ctrl+l to accept suggestion
bindkey '^O' forward-word          # Ctrl+o to accept word
