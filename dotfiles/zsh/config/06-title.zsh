################################################################################
##                                                                            ##
##  Terminal Title Management                                                 ##
##                                                                            ##
##  Automatically updates terminal window/tab titles to show current          ##
##  command or last executed command for better multitasking.                 ##
##                                                                            ##
##  Dependencies: none                                                        ##
##                                                                            ##
################################################################################

if [[ -z "${__BUELL[TITLE_INITIALIZED]:-}" ]]; then
  # Set terminal title with proper escaping
  set-tab-and-window-title() {
    emulate -L zsh
    local CMD="${1:gs/$/\\$}"
    print -Pn "\e]0;$CMD:q\a"
  }

  # Update title after command completes (show last command)
  update-window-title-precmd() {
    emulate -L zsh
    set-tab-and-window-title "$(history | tail -1 | cut -b8-)"
  }

  # Update title when command starts (show running command)
  update-window-title-preexec() {
    emulate -L zsh
    setopt extended_glob

    # Skip ENV=settings, sudo, ssh; show first distinctive word
    # Based on oh-my-zsh termsupport.zsh
    set-tab-and-window-title "${2[(wr)^(*=*|mosh|ssh|sudo)]}"
  }

  # Register hooks
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd update-window-title-precmd
  add-zsh-hook preexec update-window-title-preexec

  __BUELL[TITLE_INITIALIZED]=1
fi
