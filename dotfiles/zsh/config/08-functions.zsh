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


###################
#  Git Workflows  #
###################

# repo
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

# md (mnemonic: MarkDown)
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

# root
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

# gpb (mnemonic: Git Push Branch)
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

# gcr (mnemonic: Git Commit Retry)
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

# gpl (mnemonic: Git PuLl)
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
