################################################################################
##                                                                            ##
##  Prompt Configuration                                                      ##
##                                                                            ##
##  Custom prompt with detailed VCS information, command timing, conditional  ##
##  SSH display, job indicators, and shell nesting awareness.                 ##
##                                                                            ##
##  Dependencies: git (for VCS info), zsh-async (for background VCS updates)  ##
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

  # Check if zsh-async is available
  if [[ -f "$HOME/.zsh/plugins/zsh-async/async.zsh" ]]; then
    autoload -Uz vcs_info

    # Configure VCS info in anonymous function to avoid variable leakage
    () {
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

        # Detect if we should use Unicode or ASCII
        local use_unicode=true

        # Check for problematic environments
        if [[ -f /.dockerenv ]] || \
           [[ "$container" == "docker" ]] || \
           [[ -z "$LANG" ]] || \
           [[ "$LANG" != *"UTF-8"* ]] || \
           [[ -z "$LC_ALL" && -z "$LANG" ]] || \
           [[ "$TERM" == "linux" ]]; then
          use_unicode=false
        fi

        # Set characters based on detection of support
        local active_char inactive_char
        if [[ "$use_unicode" == "true" ]]; then
          active_char="⏺"
          inactive_char="⏺"
        else
          active_char="*"
          inactive_char="-"
        fi

        # Get all status info in one fast command
        local git_status="$(git status --porcelain 2>/dev/null)"

        local has_untracked=false
        local has_unstaged=false
        local has_staged=false

        # Parse the two-character status codes
        while IFS= read -r line; do
          [[ -z "$line" ]] && continue

          local index_status="${line:0:1}"
          local worktree_status="${line:1:1}"

          # Check staged (index) changes - any non-space in first column
          if [[ "$index_status" != " " ]]; then
              has_staged=true
          fi

          # Check unstaged (worktree) changes - any non-space in second column
          if [[ "$worktree_status" != " " ]]; then
              has_unstaged=true
          fi

          # Check untracked - ?? status
          if [[ "$line" == "??"* ]]; then
              has_untracked=true
          fi

        done <<< "$git_status"

        # Build the 3-dot display: untracked | unstaged | staged
        local status_display=""

        # Position 1: Untracked (blue)
        if [[ "$has_untracked" == "true" ]]; then
          status_display+="%F{blue}${active_char}%f"
        else
          status_display+="%F{59}${inactive_char}%f"
        fi

        # Position 2: Unstaged (red)
        if [[ "$has_unstaged" == "true" ]]; then
          status_display+="%F{red}${active_char}%f"
        else
          status_display+="%F{59}${inactive_char}%f"
        fi

        # Position 3: Staged (green)
        if [[ "$has_staged" == "true" ]]; then
          status_display+="%F{green}${active_char}%f"
        else
          status_display+="%F{59}${inactive_char}%f"
        fi

        # Set the misc field with leading space
        hook_com[misc]=" ${status_display}"
      }
    }

    # Source zsh-async
    source $HOME/.zsh/plugins/zsh-async/async.zsh

    # Async worker management functions
    -start-async-vcs-info-worker() {
      async_start_worker vcs_info
      async_register_callback vcs_info -async-vcs-info-worker-done
    }

    # Function to run in background worker
    -get-vcs-info-in-worker() {
      # -q stops chpwd hook from being called
      cd -q $1
      vcs_info
      print ${vcs_info_msg_0_}
    }

    # Callback when async worker completes
    -async-vcs-info-worker-done() {
      local job=$1
      local return_code=$2
      local stdout=$3
      local more=$6

      if [[ $job == '[async]' ]]; then
        if [[ $return_code -eq 2 ]]; then
          # Restart worker
          -start-async-vcs-info-worker
          return
        fi
      fi

      vcs_info_msg_0_=$stdout
      (( $more )) || zle reset-prompt
    }

    # Clear VCS info when changing directories
    -clear-vcs-info-on-chpwd() {
      vcs_info_msg_0_=
    }

    # Trigger VCS info update in background worker
    -trigger-vcs-info-run-in-worker() {
      async_flush_jobs vcs_info
      async_job vcs_info -get-vcs-info-in-worker $PWD
    }

    # Initialize async system
    async_init
    -start-async-vcs-info-worker

    # Set up RPROMPT base with async VCS info
    RPROMPT_BASE="\${vcs_info_msg_0_}"
  else
    # Fallback when zsh-async is not available
    RPROMPT_BASE=""
  fi

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

    # OSC-133 escape sequences for prompt navigation.
    #
    # See: https://gitlab.freedesktop.org/Per_Bothner/specifications/blob/master/proposals/semantic-prompts.md
    #
    # tmux only cares about $PROMPT_START, but we emit other escapes just for
    # completeness (see also, `-mark-output()`, further down).
    local PROMPT_START=$'\e]133;A\e\\'
    local PROMPT_END=$'\e]133;B\e\\'

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

    PS1="%{${PROMPT_START}%}"

    # Build prompt with conditional SSH display and tmux handling
    if [[ -n "$TMUX" ]]; then
      # Non-breaking space for tmux pattern matching
      local NBSP=' '
      PS1+="%F{green}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b%F{blue}%1~%F{yellow}%B%(1j.*.)%b%f %F{red}%B${SUFFIX}%b%f"
      PS1+="%{${PROMPT_END}%}"
      PS1+="${NBSP}"
      export PS1
      export ZLE_RPROMPT_INDENT=0
    else
      PS1+="%F{green}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b%F{blue}%1~%F{yellow}%B%(1j.*.)%b%f %F{red}%B${SUFFIX}%b%f"
      PS1+="%{${PROMPT_END}%}"
      PS1+=" "
      export PS1
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

  if [[ -f "$HOME/.zsh/plugins/zsh-async/async.zsh" ]]; then
    # Use async VCS info updates
    add-zsh-hook precmd -trigger-vcs-info-run-in-worker
    add-zsh-hook chpwd -clear-vcs-info-on-chpwd
  fi

  add-zsh-hook precmd report-run-meta
  add-zsh-hook preexec record-start-time

  __BUELL[PROMPT_INITIALIZED]=1
fi
