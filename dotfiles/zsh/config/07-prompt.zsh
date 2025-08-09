################################################################################
##                                                                            ##
##  Prompt Configuration                                                      ##
##                                                                            ##
##  Custom prompt with detailed VCS information, command timing, conditional  ##
##  SSH display, job indicators, and shell nesting awareness.                 ##
##                                                                            ##
##  Dependencies: git (for VCS info)                                          ##
##                                                                            ##
################################################################################

if [[ -z "${__BUELL[PROMPT_INITIALIZED]:-}" ]]; then
  # Enable parameter expansion and color support
  setopt PROMPT_SUBST
  autoload -U colors
  colors

  ###################
  #  VCS Information #
  ###################

  # Load and configure VCS info system
  autoload -Uz vcs_info
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' stagedstr "%F{green}●%f"          # staged changes
  zstyle ':vcs_info:*' unstagedstr "%F{red}●%f"          # unstaged changes
  zstyle ':vcs_info:*' use-simple true
  zstyle ':vcs_info:git+set-message:*' hooks git-untracked
  zstyle ':vcs_info:git*:*' formats '%F{3}%b%f %m%c%u'   # branch + indicators
  zstyle ':vcs_info:git*:*' actionformats '[%b|%a%m%c%u]' # branch + action

  # Custom hook to show untracked files
  function +vi-git-untracked() {
    emulate -L zsh
    if [[ -n $(git ls-files --exclude-standard --others 2> /dev/null) ]]; then
      hook_com[unstaged]+="%F{blue}●%f"
    fi
  }

  ###################
  #  Command Timing  #
  ###################

  typeset -F SECONDS

  record-start-time() {
    emulate -L zsh
    ZSH_START_TIME=${ZSH_START_TIME:-$SECONDS}
  }

report-run-meta() {
  local EXITCODE=$?
  emulate -L zsh

  local TIMING_INFO=""
  if [[ -n $ZSH_START_TIME ]]; then
    local DELTA=$(($SECONDS - $ZSH_START_TIME))
    local DAYS=$((~~($DELTA / 86400)))
    local HOURS=$((~~(($DELTA - $DAYS * 86400) / 3600)))
    local MINUTES=$((~~(($DELTA - $DAYS * 86400 - $HOURS * 3600) / 60)))
    local SECS=$(($DELTA - $DAYS * 86400 - $HOURS * 3600 - $MINUTES * 60))
    local ELAPSED=''

    # Build elapsed time string
    [[ $DAYS -ne 0 ]] && ELAPSED="${DAYS}d"
    [[ $HOURS -ne 0 ]] && ELAPSED="${ELAPSED}${HOURS}h"
    [[ $MINUTES -ne 0 ]] && ELAPSED="${ELAPSED}${MINUTES}m"

    if [[ -z $ELAPSED ]]; then
      SECS="$(printf "%.2f" $SECS)s"
    elif [[ $DAYS -ne 0 ]]; then
      SECS=''
    else
      SECS="$((~~$SECS))s"
    fi
    ELAPSED="${ELAPSED}${SECS}"

    # Exit code with color
    if [[ $EXITCODE -gt 0 ]]; then
      local EXITSTR="%F{red}$EXITCODE%f"
    else
      local EXITSTR="%F{59}$EXITCODE%f"
    fi

    # Always show timing (removed the > 1 second condition)
    local ITALIC_ON=$'\e[3m'
    local ITALIC_OFF=$'\e[23m'
    TIMING_INFO=" %F{59}%{$ITALIC_ON%}${ELAPSED}%{$ITALIC_OFF%}%f ${EXITSTR}"

    unset ZSH_START_TIME
  fi

  # Set right prompt: VCS info + timing
  export RPROMPT="${vcs_info_msg_0_}${TIMING_INFO}"
}

  ######################
  #  Prompt Definition  #
  ######################

  # Anonymous function to build prompt (avoids variable leakage)
  function () {
    emulate -L zsh

    # Safer shell nesting detection with error handling
    local LVL=1  # Default fallback

    if [[ -n "$PPID" && "$PPID" =~ '^[0-9]+$' ]]; then
      local PARENTPID
      # Use safer method to get parent PID
      if PARENTPID=$(ps -o ppid= "$PPID" 2>/dev/null | tr -d '[:space:]'); then
        if [[ -n "$PARENTPID" && "$PARENTPID" =~ '^[0-9]+$' ]]; then
          # Only try to get parent process info on non-Darwin systems
          if [[ "$(uname)" != "Darwin" && "$PARENTPID" != "1" ]]; then
            local PARENTPROC
            if PARENTPROC=$(ps -o cmd= "$PARENTPID" 2>/dev/null); then
              if [[ "$PARENTPROC" == "sh -c urxvt" ]]; then
                LVL=1
              elif [[ -n "$TMUX" ]]; then
                LVL=$(($SHLVL - 1))
              else
                LVL=$SHLVL
              fi
            fi
          elif [[ "$PARENTPID" == "1" ]]; then
            LVL=1
          elif [[ -n "$TMUX" ]]; then
            LVL=$(($SHLVL - 1))
          else
            LVL=$SHLVL
          fi
        fi
      fi
    fi

    # Ensure LVL is reasonable
    [[ $LVL -lt 1 ]] && LVL=1
    [[ $LVL -gt 2 ]] && LVL=2

    # Create prompt suffix based on user and nesting level
    local SUFFIX
    if [[ $EUID -eq 0 ]]; then
      SUFFIX=$(printf '#%.0s' {1..$LVL})  # # for root
    else
      SUFFIX=$(printf '\$%.0s' {1..$LVL}) # $ for regular user
    fi

    # Build prompt with conditional SSH display and tmux handling
    if [[ -n "$TMUX" ]]; then
      # Non-breaking space for tmux pattern matching
      local NBSP=' '
      export PS1="%F{green}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b%F{blue}%1~%F{yellow}%B%(1j.*.)%b%f %F{red}%B${SUFFIX}%b%f${NBSP}"
      export ZLE_RPROMPT_INDENT=0
    else
      export PS1="%F{green}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b%F{blue}%1~%F{yellow}%B%(1j.*.)%b%f %F{red}%B${SUFFIX}%b%f "
    fi
  }

  # Spelling correction prompt
  export SPROMPT="zsh: correct %F{red}'%R'%f to %F{red}'%r'%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "

  # Hook to update VCS info before each prompt
  update-vcs-info() {
    vcs_info
  }

  ################
  #  Register Hooks #
  ################

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd update-vcs-info
  add-zsh-hook precmd report-run-meta
  add-zsh-hook preexec record-start-time

  __BUELL[PROMPT_INITIALIZED]=1
fi
