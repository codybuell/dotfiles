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

# Handle keymap changes and line initialization
zle-keymap-select() zle-line-init() {
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

# Reset cursor when line editing finishes
zle-line-finish() {
  set_cursor_shape 0  # block cursor
}

# Register ZLE widgets
zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

################################
#  Basic Navigation & Editing  #
################################

# Arrow key navigation
bindkey "\e[A" up-history         # Up arrow
bindkey "\e[B" down-history       # Down arrow

# Character and word deletion
bindkey '^?' backward-delete-char  # Backspace
bindkey '^H' backward-delete-char  # Ctrl+H
bindkey '^W' backward-kill-word    # Ctrl+W

###############################
#  Advanced Editing Features  #
###############################

# Word selection style (matches bash behavior)
autoload -Uz select-word-style
select-word-style bash  # Only alphanumeric chars are considered WORDCHARS

# Command line editing in external editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^X' edit-command-line  # Ctrl+X Ctrl+X

# History expansion on space
bindkey ' ' magic-space

####################
#  Custom Widgets  #
####################

# Smart Ctrl+Z: background/foreground toggle
fg-bg() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg  # No command in buffer, foreground last job
  else
    zle push-input  # Save current command and clear line
  fi
}
zle -N fg-bg
bindkey '^Z' fg-bg

########################
#  Plugin Integration  #
########################

# Autosuggestions navigation (if plugin loaded)
bindkey '^L' forward-char          # Ctrl+L to accept suggestion
bindkey '^O' forward-word          # Ctrl+O to accept word
