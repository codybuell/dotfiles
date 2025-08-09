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

  #####################
  #  VCS Information  #
  #####################

  autoload -Uz vcs_info
  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' stagedstr ""     # We'll handle this in hooks
  zstyle ':vcs_info:*' unstagedstr ""   # We'll handle this in hooks
  zstyle ':vcs_info:*' use-simple true
  zstyle ':vcs_info:git+set-message:*' hooks git-status-display
  zstyle ':vcs_info:git*:*' formats '%F{3}%b%f%m'
  zstyle ':vcs_info:git*:*' actionformats '%F{3}[%b|%a]%f%m'

  # Hook to build consistent 3-dot status display
  function +vi-git-status-display() {
    emulate -L zsh

    # Check for each type of change
    local has_untracked=false
    local has_unstaged=false
    local has_staged=false

    # Check for untracked files
    if [[ -n $(git ls-files --exclude-standard --others 2>/dev/null) ]]; then
      has_untracked=true
    fi

    # Check for unstaged changes
    if ! git diff-files --quiet 2>/dev/null; then
      has_unstaged=true
    fi

    # Check for staged changes
    if git rev-parse --verify HEAD >/dev/null 2>&1; then
      # Repository has commits, use normal diff-index
      if ! git diff-index --quiet --cached HEAD 2>/dev/null; then
        has_staged=true
      fi
    else
      # New repository with no commits, check if anything is staged
      if [[ -n $(git ls-files --cached 2>/dev/null) ]]; then
        has_staged=true
      fi
    fi

    # Build the 3-dot display: untracked | unstaged | staged
    local status_display=""

    # Position 1: Untracked (blue)
    if [[ "$has_untracked" == "true" ]]; then
      status_display+="%F{blue}⏺%f"
    else
      status_display+="%F{59}⏺%f"
    fi

    # Position 2: Unstaged (red)
    if [[ "$has_unstaged" == "true" ]]; then
      status_display+="%F{red}⏺%f"
    else
      status_display+="%F{59}⏺%f"
    fi

    # Position 3: Staged (green)
    if [[ "$has_staged" == "true" ]]; then
      status_display+="%F{green}⏺%f"
    else
      status_display+="%F{59}⏺%f"
    fi

    # Set the misc field with leading space
    hook_com[misc]=" ${status_display}"
  }

  # Set up RPROMPT base exactly like old version
  RPROMPT_BASE="\${vcs_info_msg_0_}"

  # CRITICAL: Set initial RPROMPT value like old version (vim_mode empty for now)
  export RPROMPT='${vim_mode}${RPROMPT_BASE}'

  ####################
  #  Command Timing  #
  ####################

  typeset -F SECONDS

  record-start-time() {
    emulate -L zsh
    ZSH_START_TIME=${ZSH_START_TIME:-$SECONDS}
  }

  report-run-meta() {
    local EXITCODE=$?
    emulate -L zsh

    if [[ -n $ZSH_START_TIME ]]; then
      local DELTA=$(($SECONDS - $ZSH_START_TIME))
      local DAYS=$((~~($DELTA / 86400)))
      local HOURS=$((~~(($DELTA - $DAYS * 86400) / 3600)))
      local MINUTES=$((~~(($DELTA - $DAYS * 86400 - $HOURS * 3600) / 60)))
      local SECS=$(($DELTA - $DAYS * 86400 - $HOURS * 3600 - $MINUTES * 60))
      local ELAPSED=''

      # Build elapsed time string (match old version logic)
      test "$DAYS" != '0' && ELAPSED="${DAYS}d"
      test "$HOURS" != '0' && ELAPSED="${ELAPSED}${HOURS}h"
      test "$MINUTES" != '0' && ELAPSED="${ELAPSED}${MINUTES}m"

      if [[ -z $ELAPSED ]]; then
        SECS="$(print -f "%.2f" $SECS)s"
      elif [[ $DAYS -ne 0 ]]; then
        SECS=''
      else
        SECS="$((~~$SECS))s"
      fi
      ELAPSED="${ELAPSED}${SECS}"

      # Exit code styling: bold red if error, dim if success
      local EXITSTR
      if [[ $EXITCODE -gt 0 ]]; then
        EXITSTR="%F{red}%B%?%b%f"  # Bold red for errors
      else
        EXITSTR="%F{59}%?%f"       # Dim gray for success
      fi

      # Timing and exit code with proper italics
      local ITALIC_ON=$'\e[3m'
      local ITALIC_OFF=$'\e[23m'

      # Use exact same pattern as old version - reference RPROMPT_BASE variable
      export RPROMPT="%F{59}%{$ITALIC_ON%}${ELAPSED}%{$ITALIC_OFF%}%f ${EXITSTR} $RPROMPT_BASE"
      unset ZSH_START_TIME
    else
      export RPROMPT="$RPROMPT_BASE"
    fi
  }

  #######################
  #  Prompt Definition  #
  #######################

  # Anonymous function to build prompt (avoids variable leakage)
  function () {
    emulate -L zsh

    # Shell nesting detection (simplified version)
    local LVL=1
    if [[ -n "$TMUX" ]]; then
      LVL=$(($SHLVL - 1))
    else
      LVL=$SHLVL
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

  ####################
  #  Register Hooks  #
  ####################

  autoload -Uz add-zsh-hook
  add-zsh-hook precmd update-vcs-info
  add-zsh-hook precmd report-run-meta
  add-zsh-hook preexec record-start-time

  __BUELL[PROMPT_INITIALIZED]=1
fi
