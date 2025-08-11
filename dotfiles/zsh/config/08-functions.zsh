################################################################################
##                                                                            ##
##  Functions                                                                 ##
##                                                                            ##
##  A collection of miscellaneous functions to expose to the shell. Common    ##
##  workflows are typically the focus with mnemonic names for easy adoption.  ##
##                                                                            ##
##  Dependencies: none                                                        ##
##                                                                            ##
################################################################################

##########
#  TMUX  #
##########

# TMUX
#
# Wrapper for starting up tmux. Looks for a `.tmux` configuration file in the
# current working directory and sources it if present. Configuration files
# handle creation of splits, executing commands, and any other project or
# directory specific tmux configs desired. A digest is maintained to prompt for
# approval of config files that have yet to be run.
function tmux() {
  # Make sure even pre-existing tmux sessions use the latest ssh_auth_sock
  local SOCK_SYMLINK=~/.ssh/ssh_auth_sock
  if [ -r "$SSH_AUTH_SOCK" -a ! -L "$SSH_AUTH_SOCK" ]; then
    ln -sf "$SSH_AUTH_SOCK" $SOCK_SYMLINK
  fi

  # If provided with args, pass them through
  if [[ -n "$@" ]]; then
    env SSH_AUTH_SOCK=$SOCK_SYMLINK tmux -u "$@"
    return
  fi

  # Check for .tmux file (poor man's tmuxinator)
  if [[ -e .tmux && -f .tmux ]]; then
    if [[ ! -x .tmux ]]; then
      chmod 755 .tmux
    fi
    # Prompt the first time we see a given .tmux file before running it
    local DIGEST="$(openssl sha512 .tmux)"
    if ! grep -q "$DIGEST" ~/.config/tmux/tmux.digests 2> /dev/null; then
      cat .tmux
      echo -n "Trust (and run) this .tmux file? (t = trust, otherwise = skip): "
      read REPLY
      if [[ $REPLY =~ ^[Tt]$ ]]; then
        echo "$DIGEST" >> ~/.config/tmux/tmux.digests
        ./.tmux
        return
      fi
    else
      ./.tmux
      return
    fi
  fi

  # Attach to existing session, or create one, based on current directory
  SESSION_NAME=$([[ `pwd` == $HOME ]] && echo 'HOME' || basename "$(pwd)" | sed 's/\.//g' | tr '[:upper:]' '[:lower:]')
  env SSH_AUTH_SOCK=$SOCK_SYMLINK tmux -u new -A -s "$SESSION_NAME"
}

# Home
#
# Handles the creation of or attachment to the "home" tmux session. Used as a
# home base in the terminal for not taking, email, and other non-project
# related tasks.
#
#  window 1:                               window 2:
# .----------------------------------.    .----------------------------------.
# |                                  |    |           |           |          |
# |          1: neomutt              |    |           |           |          |
# |                                  |    | 1. home   | 2. work   | 3. tbd   |
# |----------------------------------|    |           |           |          |
# |                    |             |    |           |           |          |
# |    2. nvim home    |   3. zsh    |    |----------------------------------|
# |                    |             |    |        4. mail controller        |
# '----------------------------------'    '----------------------------------'
function home() {
  if [ -z "$TMUX" ]; then
    if ! tmux has-session -t HOME 2> /dev/null; then
      cd ~
      # build home window
      tmux new-session -d -s HOME -n home -x `tput cols` -y `tput lines`
      tmux set-window-option -t HOME:home automatic-rename off

      # create main window panes
      tmux split-window -t HOME:home -v -l 60% -c ~/
      tmux split-window -t HOME:home.2 -h -l 45% -c ~/
      tmux send-keys -t HOME:home.1 'cd ~/Downloads && mutt' Enter
      tmux send-keys -t HOME:home.2 'cd ~/Desktop; vi -c ":so ~/.config/nvim/sessions/home"' Enter
      tmux send-keys -t HOME:home.3 'cd ~/Desktop && clear' Enter

      # build control window
      tmux new-window -t HOME: -c ~/.mutt -n control
      tmux set-window-option -t HOME:control automatic-rename off
      tmux set-window-option -t HOME:control monitor-activity off
      tmux split-window -t HOME:control -h -l 66% -c ~/.mutt
      tmux split-window -t HOME:control -h -l 50% -c ~/.mutt
      tmux split-window -t HOME:control -v -l 7 -f -c ~/.mutt
      tmux send-keys -t HOME:control.1 '~/.mutt/scripts/control.sh home' Enter
      tmux send-keys -t HOME:control.2 '~/.mutt/scripts/control.sh work' Enter
      # tmux send-keys -t HOME:control.3 '~/.mutt/scripts/control.sh proj' Enter
      tmux send-keys -t HOME:control.4 '~/.mutt/scripts/control.sh' Enter

      ## attach to home session, home window, weechat pane
      tmux -u attach -t HOME:home.3
    else
      tmux -u attach -t HOME
    fi
  else
    tmux switch-client -t HOME
  fi
}

###################
#  Git Workflows  #
###################

# Repo
#
# Helper to quickly navigate to repositories. Takes an argument of the target
# repository name. No arguments will place you at the root of the repos directory.
#
# Expected directory structure:
# {{ Repos }}/
# ├── .repos                    # Index file created by cron job
# ├── github.com/
# │   ├── codybuell/
# │   │   ├── dotfiles/
# │   │   ├── scripts/
# │   │   └── other-repo/
# │   └── otheruser/
# │       └── their-repo/
# ├── gitlab.com/
# │   └── company/
# │       ├── project-a/
# │       └── project-b/
# └── bitbucket.org/
#     └── team/
#         └── legacy-project/
#
# Usage:
#   repo                        # Navigate to {{ Repos }} root
#   repo dotfiles               # Navigate to repository named "dotfiles"
#   repo project-a              # Navigate to repository named "project-a"
#
# Requirements:
#   - .repos file in {{ Repos }} directory containing indexed repositories
#   - Cron job running indexer to maintain .repos file
#   - Optional: zsh completion file for tab completion support
#
# Notes:
#   - Searches for repositories ending with "/$1" in the .repos index
#   - Presents selection menu when multiple repositories match
#   - Expects .repos format: "field1:field2" where field2 is the full path
repo() {
  if [ $1 ]; then
    REPOLIST=$(cat {{ Repos }}/.repos | awk -F: '{print $2}')
    TARGETREPO=$(echo $REPOLIST | grep "/${1}$")
    if [[ "$TARGETREPO" =~ .*'\n'.* ]]; then
      OPTIONS=( $(echo $TARGETREPO | sed 's/\\n/ /g') )
      if [ ${#OPTIONS[@]} -eq 1 ]; then
        cd $TARGETREPO
      else
        echo "Please select a repo:"
        select option in "${OPTIONS[@]}"; do
          if [[ -z "$option" ]]; then
            echo "Invalid selection"
          else
            cd $option
            break
          fi
        done
      fi
    else
      cd $TARGETREPO
      #changedir '{{ Repos }}' $@
    fi
  else
    cd {{ Repos }}
  fi
}

# MD (mnemonic: MarkDown)
#
# Helper to quickly open the repository main documentation file.
md() {
  local target=""
  local files=('README.md' 'readme.md' 'docs/README.md' 'README.txt' 'readme.txt' 'README' 'readme')

  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      target="$file"
      break
    fi
  done

  if [[ -z "$target" ]]; then
    target="README.md"
    echo "# $(basename "$(pwd)")" > "$target"
    echo "Created new $target"
  fi

  "${VISUAL:-${EDITOR:-vi}}" "$target"
}

# Root
#
# Cd up till you reach the project root dir (git). When within a submodule it
# will still move you to the parent repository root path.
function root() {
  GOTO="./"
  CLOC=`pwd | sed 's/[^\/]//g'`
  EXST='false'
  for ((i=1; i<=${#CLOC}; i++)); do
    [[ ! -d ${GOTO}.git ]] && {
      GOTO+="../"
    } || {
      EXST='true'
      break
    }
  done
  [[ $EXST == 'true' ]] && {
    cd $GOTO
  } || {
    echo 'cwd is not part of a repository'
  }
}

# gcl (mnemonic: Git CLone)
#
# Clones a repository into the folder structure:
#   {{ Repos }}/[ Domain ]/[ user OR group ]/[ repo ]
#
# @param none
function gcl() {
  CLONEPATH=`echo $1 | sed -E 's/git\@|http(s)?:\/\///;s/\.git$//;s/:/\//g'`
  git clone $1 {{ Repos }}/$CLONEPATH
  cd {{ Repos }}/$CLONEPATH
  repo_profiler
}

# GPB (mnemonic: Git Push Branch)
#
# Pushes a branch to a remote. Attempts to open any returned URLs to create
# a merge/pull request.
#
# Usage:
#   gpb                    # Push current branch to origin
#   gpb [branch]           # Push specified branch to origin
#   gpb [remote] [branch]  # Push specified branch to specified remote
function gpb() {
  # Default values
  local REMOTE="origin"
  local BRANCH=$(git rev-parse --abbrev-ref HEAD)

  # Parse arguments
  if [[ $# -eq 1 ]]; then
    BRANCH=$1
  elif [[ $# -eq 2 ]]; then
    REMOTE=$1
    BRANCH=$2
  elif [[ $# -gt 2 ]]; then
    echo "Usage: gpb [remote] [branch] or gpb [branch]" >&2
    return 1
  fi

  git push --progress $REMOTE $BRANCH 2>&1 | tee /tmp/lastgitpush
  MRLINK=$(awk '/(To )?(c|C)reate a (merge|pull) request/{getline;print $2}' /tmp/lastgitpush)

  if [[ ! -z "$MRLINK" ]]; then
    # Cross-platform URL opening
    if command -v xdg-open > /dev/null 2>&1; then
      xdg-open "$MRLINK"
    elif command -v open > /dev/null 2>&1; then
      open "$MRLINK"
    elif [[ -n "$WSL_DISTRO_NAME" ]] || [[ -n "$WSL_INTEROP" ]]; then
      cmd.exe /c start "$MRLINK"
    else
      echo "Merge/Pull request URL: $MRLINK"
    fi
  fi
}

# GCR (mnemonic: Git Commit Retry)
#
# Retry a commit with the last git commit message. Helpful if you wrote
# something long and well composed but the commit failed for some reason.
function gcr() {
  OLDCOMMITMESSAGE=`cat "$(git rev-parse --git-dir)/COMMIT_EDITMSG" | sed '/^#.*$/d;${/^$/d}' | perl -p -e 'chomp if eof'`
  echo $OLDCOMMITMESSAGE
  echo
  case `basename $SHELL` in
    zsh )
      read "selection?Retry commit with this message (y[es]/n[o]): "
      ;;
    * )
      read -r -p "Retry commit with this message (y[es]/n[o]): " selection
      ;;
  esac
  case $selection in
    [yY][eE][sS]|[yY] )
      echo -n $OLDCOMMITMESSAGE | git commit -F - -e
      #cat "$(git rev-parse --git-dir)/COMMIT_EDITMSG" | sed '/^#.*$/d' | perl -p -e 'chomp if eof' | git commit -F - -e
      ;;
    [nN][oO]|[nN] )
      ;;
  esac
}

# GPL (mnemonic: Git PuLl)
#
# Pulls a branch from a remote.
#
# Usage:
#   gpl                    # Pull current branch from origin
#   gpl [branch]           # Pull specified branch from origin
#   gpl [remote] [branch]  # Pull specified branch from specified remote
function gpl() {
  # Default values
  local REMOTE="origin"
  local BRANCH=$(git rev-parse --abbrev-ref HEAD)

  # Parse arguments
  if [[ $# -eq 1 ]]; then
    BRANCH=$1
  elif [[ $# -eq 2 ]]; then
    REMOTE=$1
    BRANCH=$2
  elif [[ $# -gt 2 ]]; then
    echo "Usage: gpl [remote] [branch] or gpl [branch]" >&2
    return 1
  fi

  git pull $REMOTE $BRANCH
}

################
#  Networking  #
################


###################
#  Miscellaneous  #
###################

# Test Regex
#
# Test regular expressions interactively, ctrl-D to stop
# Usage: testregex 'string to match against'
# Enter regex patterns line by line to test matches
function testregex() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: testregex 'string to match against'" >&2
        echo "Enter regex patterns (Ctrl-D to stop)" >&2
        return 1
    fi

    local target="$1"
    echo "Testing against: '$target'"
    echo "Enter regex patterns:"

    while IFS= read -r pattern; do
        # Skip empty lines
        [ -n "$pattern" ] || continue

        printf "\nPattern: %s\n" "$pattern"

        # Handle invalid regex gracefully and show results clearly
        if matches=$(printf '%s\n' "$target" | grep -Eoe "$pattern" 2>/dev/null); then
            echo "Matches:"
            printf '  %s\n' $matches
        else
            echo "No matches (or invalid pattern)"
        fi
    done
}
