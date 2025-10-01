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
      tmux send-keys -t HOME:home.1 'cd ~/Downloads && neomutt' Enter
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

# IntIP (mnemonic: INTernal IP)
#
# Get internal IP address.
function intip() {
  [[ -f /etc/redhat-release ]] && {
    ifconfig $(netstat -rn | grep UG | awk '{print $8}') | grep inet | egrep -v '::|inet 127.' | awk '{print $2}'
  } || {
    ifconfig $(netstat -rn -f inet | grep default | awk '{print $6}') | grep inet | egrep -v '::|inet 127.' | awk '{print $2}'
  }
}

# ExtIP (mnemonic: EXTernal IP)
#
# Get external IP address.
function extip() {
  /usr/bin/dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | sed 's/[^0-9.]//g'
}

# Ping Sweep
#
# Ping a range of IPs: pingsweep 10.10.1 1..50
function pingsweep() {
  #trap "exit" INT
  for i in $(eval echo "{$2}"); do
    ping -noq -c 1 -t 1 -i 0.1 ${1}.${i} > /dev/null
    echo -e "${1}.${i}\t`[[ $? == 0 ]] && echo up || echo down`"
  done
}

#################
#  AWS Helpers  #
#################

# EC2 LS
#
# List out EC2 instances for the AWS account you are currently authenticated
# against.
ec2ls() {
  if [ ! -z ${1} ]; then
    REGION="--region ${1}"
  fi
  aws ec2 describe-instances --query \
  "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value,Status:State.Name,ID:InstanceId,AZ:Placement.AvailabilityZone,Key:KeyName,Type:InstanceType,Launched:LaunchTime}" \
  --output table $(echo ${REGION})
}

# RM Buckets
#
# Helper to remove S3 buckets. Provide a pattern to match against. Will Empty
# then delete the matched buckets after confirmation.
rmbuckets() {
  pattern=$1
  for b in $(aws s3 ls | grep $pattern | awk '{print $3}'); do
    # prompt to confirm
    echo -n "Delete bucket $b? [y/n] "
    read -r confirmation
    if [[ $confirmation =~ ^[Yy]$ ]]; then
      echo "emptying bucket $b"
      aws s3 rm --recursive --quiet s3://$b/
      aws s3api list-object-versions --bucket $b --output text | grep "DELETEMARKERS" | while read obj
      do
        KEY=$(echo $obj| awk '{print $3}')
        VERSION_ID=$(echo $obj | awk '{print $5}')
        aws s3api delete-object --bucket $b --key $KEY --version-id $VERSION_ID
      done
      aws s3api delete-bucket --bucket $b
      echo "deleted bucket $b"
    fi
  done
}

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

# Nok (mnemonic: knocking)
#
# Wrapper for fwknop port knocking.
function nok() {
  TARGETPORT=${3:-22}
  case $1 in
    int )
      SRCIP=`intip`
      ;;
    ext )
      SRCIP=`extip`
      ;;
  esac
  fwknop -A tcp/22 -a $SRCIP -D $2

  case `basename $SHELL` in
    zsh )
      read "choice?connect to host? [y/n] "
      ;;
    * )
      read -p "connect to host? [y/n] " choice
      ;;
  esac

  case "$choice" in
    n|N|no ) return;;
  esac

  # fix ssh-agent issue
  if [ ! -z $TMUX ] && [ "$(uname)" = "Darwin" ]; then
    TERM=xterm-256color reattach-to-user-namespace ssh -p $TARGETPORT $2
  else
    ssh -p $TARGETPORT $2
  fi
}

# Note
#
# Helper to open note files or navigate to the notes directory.
note() {
  NOTEPATH=$(echo {{ Notes }})
  if [ $1 ]; then
    ARGEXT=`echo $1 | sed -n 's/^.*\.\(.*$\)/\1/p'`
    EXT=`[[ ${#ARGEXT} -eq 0 ]] && echo '.md'`
    vim ${NOTEPATH}/${1}${EXT}
  else
    cd ${NOTEPATH}
  fi
}

# VEnv (mnemonic: Virtual ENVironment)
#
# Helper to setup a python virtual environment.
function venv() {
  python3 -m venv .venv
  if ! grep -q "^source .venv/bin/activate$" .gitignore; then
    echo "source .venv/bin/activate" >> .envrc
  fi
  if ! grep -q "^\.venv$" .gitignore; then
    echo ".venv" >> .gitignore
  fi
  direnv allow
}

# RDP
#
# Wrapper for xfreedesktop/rdesktop to RDP into target instances.
# Usage: rdp user@domain host
rdp() {

  RDP_CLIENT='rdesktop'
  RDP_USER=`echo $1 | sed 's/\@.*$//'`
  RDP_DOMAIN=`echo $1 | sed 's/^.*\@//;s/\..*$//'`
  RDP_HOST=$2
  RDP_GEOMETRY='1920x1300'

  case $RDP_CLIENT in
    rdesktop )
      # -D removes the window decorations for the session, no more menu bar taking up space
      # -K lets you pass shortcuts back to the primary host, so you can switch workspaces
      # -b use bitmaps, slower to start but better visually
      # -P cache the bitmaps to reduce network traffic and improve performance
      # -g your screens res, minus the os menu bar...
      # -a your bit depth
      # -p '-' to prompt for password
      rdesktop -DKbP -g ${RDP_GEOMETRY} -a 24 -d ${RDP_DOMAIN} -u ${RDP_USER} -p - ${RDP_HOST}
      ;;
    xfreerdp )
      # -K try not to mangle host os keyboard bindings
      # -z compression
      # -g set a geometry
      # --plugin cliprdr allow clipboard sharing
      # -x 0x80 font smoothing over lan connection
      xfreerdp -K --plugin cliprdr -x 0x80 -g ${RDP_GEOMETRY} -u ${RDP_USER} -d ${RDP_DOMAIN} ${RDP_HOST}:3389
      ;;
  esac
}

# Repo Check
#
# Runs through all git repositories and provides a status. Helpful to identify
# dirty repos.
#
# Usage:
#   repocheck                           # Show all repos
#   repocheck github.com/codybuell      # Show only repos under that path
function repocheck() {
    local CWD=$(pwd)
    local REPOS_ROOT="{{ Repos }}"
    local FILTER_PATH="$1"

    # Get repository list - prefer .repos file if available
    local REPOS=()
    if [[ -f "$REPOS_ROOT/.repos" ]]; then
        # Parse .repos file (format: reponame:full/path)
        while IFS=':' read -r name repo_path; do
            REPOS+=("$name:$repo_path")
        done < "$REPOS_ROOT/.repos"
    else
        # Fall back to find method
        local found_repos=($(find "$REPOS_ROOT" -type d -name .git 2>/dev/null))
        for repo_git in $found_repos; do
            local repo_path="${repo_git%/.git}"
            local rel_path="${repo_path#$REPOS_ROOT/}"
            REPOS+=("$rel_path:$repo_path")
        done
    fi

    # Print headers
    printf "%-80s %-8s %s\n" "REPOSITORY" "LOCAL" "REMOTE"

    # Loop through all repos
    for entry in "${REPOS[@]}"; do
        local name="${entry%%:*}"
        local repo_path="${entry##*:}"
        local rel_path="${repo_path#$REPOS_ROOT/}"
        local path_without_repo="${rel_path%/*}"

        # Filter repos if path is provided
        if [[ -n "$FILTER_PATH" ]]; then
            # Check if the relative path starts with the filter path
            if [[ "$rel_path" != "$FILTER_PATH"/* ]]; then
                continue
            fi
        fi

        # Test repo
        if ! git -C "$repo_path" rev-parse --git-dir > /dev/null 2>&1; then
            # Create the display string with bold name and dimmed parent path
            local display_string="\033[1m${name}\033[0m (\033[2m${path_without_repo}\033[0m)"
            local display_len=$((${#name} + ${#path_without_repo} + 3)) # 3 for " ()"
            local dots_needed=$((80 - display_len))
            local dots=""
            for ((j=0; j<dots_needed; j++)); do
                dots+="."
            done
            printf "%b%s \033[0;31mnot a repo\033[0;m\n" "$display_string" "$dots"
            continue
        fi

        # Create the display string with bold name and dimmed parent path
        local display_string="\033[1m${name}\033[0m (\033[2m${path_without_repo}\033[0m)"
        local display_len=$((${#name} + ${#path_without_repo} + 3)) # 3 for " ()"
        local dots_needed=$((80 - display_len))
        local dots=""
        for ((j=0; j<dots_needed; j++)); do
            dots+="."
        done

        # Output with inline status checks to avoid variable assignments
        printf "%b%s " "$display_string" "$dots"

        # Local status - output directly
        if [ "$(git -C "$repo_path" status --porcelain 2>/dev/null | wc -l)" -gt 0 ]; then
            printf "\033[0;31mdirty\033[0;m "
        else
            printf "\033[0;32mclean\033[0;m "
        fi

        # Remote status - output directly
        if [ "$(git -C "$repo_path" remote 2>/dev/null | wc -l)" -lt 1 ]; then
            printf "\033[0;31morphaned\033[0;m\n"
        else
            # Get git info and output status directly
            if ! git -C "$repo_path" rev-parse @{u} > /dev/null 2>&1; then
                printf "\033[1;31muntracked\033[0;m\n"
            elif [ "$(git -C "$repo_path" rev-parse @)" = "$(git -C "$repo_path" rev-parse @{u})" ]; then
                printf "\033[0;32mcurrent\033[0;m\n"
            elif [ "$(git -C "$repo_path" rev-parse @)" = "$(git -C "$repo_path" merge-base @ @{u})" ]; then
                printf "\033[0;31mbehind\033[0;m\n"
            elif [ "$(git -C "$repo_path" rev-parse @{u})" = "$(git -C "$repo_path" merge-base @ @{u})" ]; then
                printf "\033[1;33mahead\033[0;m\n"
            else
                printf "\033[0;33mdiverged\033[0;m\n"
            fi
        fi
    done
}

# Regex Move
#
# Rename files using sed-style regex patterns.
#
# Usage: regmv [OPTIONS] 'regex' file(s)
#   -n, --dry-run        Preview changes without renaming
#   -q, --quiet          Suppress output
#   --no-interactive     Don't prompt before overwriting
#   -h, --help           Show detailed help
#
# Regex format: '/find/replace/[flags]'
# Example: regmv '/\.txt$/\.md/' *.txt
#          regmv -n '/IMG_/Photo_/' *.jpg  # dry run
regmv() {
    local dry_run=false
    local verbose=true
    local interactive=true
    local regex=""
    local files=()

    # Parse options (same as before)
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--dry-run) dry_run=true; shift ;;
            -q|--quiet) verbose=false; shift ;;
            --no-interactive) interactive=false; shift ;;
            -h|--help)
                echo "Usage: regmv [OPTIONS] 'regex' file(s)"
                echo "Rename files using sed-style regex patterns"
                return 0
                ;;
            *)
                if [[ -z "$regex" ]]; then
                    regex="$1"
                else
                    files+=("$1")
                fi
                shift
                ;;
        esac
    done

    # Validation (same as before)
    if [[ -z "$regex" ]] || [[ ${#files[@]} -eq 0 ]]; then
        echo "Error: Missing regex pattern or files" >&2
        return 1
    fi

    local changes_made=0
    local errors=0
    local newname  # Declare once outside the loop

    # Process each file
    for file in "${files[@]}"; do
        [[ ! -e "$file" ]] && continue

        newname=$(echo "$file" | sed "s${regex}g")
        [[ "$newname" == "$file" ]] && continue
        [[ -z "$newname" ]] && continue

        if [[ "$dry_run" == true ]]; then
            [[ "$verbose" == true ]] && printf "\033[33m%s\033[0m  →  \033[32m%s\033[0m\n" "$file" "$newname"
            ((changes_made++))
        else
            local mv_args=()
            [[ "$interactive" == true ]] && mv_args+=("-i")
            mv_args+=("$file" "$newname")

            if mv "${mv_args[@]}"; then
                [[ "$verbose" == true ]] && printf "\033[36m%s\033[0m  →  \033[32m%s\033[0m\n" "$file" "$newname"
                ((changes_made++))
            else
                echo "Error: Failed to rename '$file' to '$newname'" >&2
                ((errors++))
            fi
        fi
    done

    [[ $changes_made -gt 0 || $errors -gt 0 ]] && echo
    if [[ "$dry_run" == true ]]; then
        echo "Dry run: $changes_made files would be renamed"
    elif [[ $changes_made -gt 0 ]]; then
        echo "Successfully renamed $changes_made files"
    fi

    [[ $errors -gt 0 ]] && echo "Encountered $errors errors" >&2
    return $errors
}
