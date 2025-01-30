#!/bin/bash
#
# Shell Script Library
#
# A mix of helper variables and functions intended to be used with the toolkit
# repo: https://github.com/codybuell/dotfiles.
#
# Author(s): Cody Buell
#
# Requisite:
#
# Tools:
#
# Usage: source "${BASH_SOURCE%/*}/library.sh"

################################################################################
#                                                                              #
#  Variables                                                                   #
#                                                                              #
################################################################################

# repo root, path to directory containing `.config`, allows for consistent
# pathing regardless of the current working directory during script execution
CONFIGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../ && pwd )"
export CONFIGDIR

# location of dotfiles folder and array of all objects in root of folder
DOTS_LOC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../dotfiles && pwd )"
export DOTS_LOC
export DOTFILES=()
while IFS= read -r -d '' file; do
  DOTFILES+=("$file")
done < <(find "${DOTS_LOC}" -maxdepth 1 -mindepth 1 -print0)

# system information
UNAME=$(uname -s)
export UNAME

# home directory
HOMEDIR=$HOME
export HOMEDIR

# homebrew directory
tmp=$(brew --prefix 2> /dev/null)
HOMEBREW_PREFIX=${tmp:-/opt/homebrew}
export HOMEBREW_PREFIX

# color helpers
if [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
  BOLD="$(tput bold)"
  UNDER="$(tput smul)"
  NOUNDER="$(tput rmul)"
  DIM="$(tput dim)"
  export BOLD
  export UNDER
  export NOUNDER
  export DIM

  BLACK="$(tput setaf 0)"
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  MAGENTA="$(tput setaf 5)"
  CYAN="$(tput setaf 6)"
  WHITE="$(tput setaf 7)"
  export BLACK
  export RED
  export GREEN
  export YELLOW
  export BLUE
  export MAGENTA
  export CYAN
  export WHITE

  NORM="$(tput sgr0)"
  export NORM
fi

################################################################################
#                                                                              #
#  Functions                                                                   #
#                                                                              #
################################################################################

# Pretty Print
#
# Helper for printing status. Expects left hand and right hand text, separated
# by a ':'. Dots are added between to easily associate keys and values.

prettyprint() {
  printf "%s" "$1" | awk -F: '{file=$1;$1="";printf "%-50s %s\n", file, $0}' | sed "s/ /,/g;s/\([^,]\),/\1 /g;s/,\([^,]\)/ \1/g;s/^,/ /;s/,/./g";
}

##
 # Read Config
 #
 # Ingest $CONFIGDIR/.config and defines variables for each setting. Also
 # generates an array $CONFIGVARS containing all keys set.
 #
 # @params none
 # @return none
##
read_config() {
  CONFIGVARS=("CONFIGDIR" "UNAME" "HOMEDIR" "HOMEBREW_PREFIX")
  shopt -s extglob
  configfile="$CONFIGDIR/.config"
  if [[ -e $configfile ]]; then
    tr -d '\r' < "$configfile" > "$configfile.tmp"
    while IFS='= ' read -r lhs rhs; do
      if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
        rhs="${rhs%%\#*}"    # del in line right comments
        rhs="${rhs%%*( )}"   # del trailing spaces
        rhs="${rhs%\"*}"     # del opening string quotes
        rhs="${rhs#\"*}"     # del closing string quotes
        export "$lhs"="$rhs"
        CONFIGVARS+=("$lhs")
      fi
    done < "$configfile.tmp"
    export CONFIGVARS
  else
    printf "\033[0;31mno configuration file detected\033[0m\n"
    exit 1
  fi
  rm "$configfile.tmp"
}

## Log
 #
 # Helper function to output standardized log messages.
 #
 # @param <LOG_COLOR> <LOG_MSG> [LOG_MSG_RHS]
 #  LOG_COLOR (quoted string), one of [decoration](mageta|red|cyan|yellow|green|blue)
 #  LOG_MSG (quoted string), freehand message
 #  LOG_MSG_RHS (quoted string) right-hand side log message (optional)
 #
 # Example: log 1 "INFO" "Informational message"
## @return VOID
log () {
  LOG_COLOR=$1
  LOG_MSG=$2
  LOG_MSG_RHS=$3
  PFRESET=$NORM
  PAD_C=$(printf '%0.1s' "."{1..80})
  PAD_L=40

  # handle basic colors
  case $LOG_COLOR in
    *magenta )
      PFCOLOR=$MAGENTA
      ;;
    *red )
      PFCOLOR=$RED
      ;;
    *cyan )
      PFCOLOR=$CYAN
      ;;
    *yellow )
      PFCOLOR=$YELLOW
      ;;
    *green )
      PFCOLOR=$GREEN
      ;;
    *blue )
      PFCOLOR=$BLUE
      ;;
    *white )
      PFCOLOR=$WHITE
      ;;
    * )
      PFCOLOR=""
  esac

  # handle text decorations
  [[ ${LOG_COLOR} =~ .*under.* ]] && PFCOLOR=${PFCOLOR}${UNDER}
  [[ ${LOG_COLOR} =~ .*bold.* ]] && PFCOLOR=${PFCOLOR}${BOLD}
  [[ ${LOG_COLOR} =~ .*dim.* ]] && PFCOLOR=${PFCOLOR}${DIM}

  # if right side is supplied then columnate
  if [ -n "$LOG_MSG_RHS" ]; then
    printf "%s %*.*s ${PFCOLOR}%s${PFRESET}\n" "${LOG_MSG}" 0 $((PAD_L - ${#LOG_MSG})) "$PAD_C" "$LOG_MSG_RHS"
  else
    printf "${PFCOLOR}%s${PFRESET}\n" "${LOG_MSG}"
  fi
}

##
 # Check Xcode
 #
 # Checks for presence of Xcode and fails of not located.
 #
 # @params none
 # @return none
##
check_xcode() {
  if [[ "$(xcode-select -p)" != "/Applications/Xcode.app/Contents/Developer" ]]; then
    log red "Xcode is required, install then retry"
    exit 1
  else
    log green "Xcode is installed, continuing"
  fi
}

##
 # Dependency: Xcode Command Line Tools
 #
 # Installs Xcode Command Line Tools if not present.
 #
 # @params none
 # @return none
##
dep_xcode_clt() {
  [[ $(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables | grep -c version) -eq 0 ]] && {
    log yelow "Xcode Command Line Tools missing, installing..."
    xcode-select --install
  }
}

##
 # Dependency: Rosetta
 #
 # Installs homebrew if not present.
 #
 # @params none
 # @return none
##
dep_rosetta() {
  if [[ $(uname -m) == 'arm64' ]]; then
    if [ "$(/usr/bin/pgrep oahd >/dev/null 2>&1;echo $?)" -eq 0 ]; then
      log green "Rosetta already installed, continuing..."
    else
      log yellow "Rosetta not present, installing..."
      softwareupdate --install-rosetta --agree-to-license
    fi
  fi
}

##
 # Dependency: Homebrew
 #
 # Installs homebrew if not present.
 #
 # @params none
 # @return none
##
dep_homebrew() {
  if ! command -v brew &> /dev/null; then
    log yellow "Brew not detected, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
}

##
 # Run Commands
 #
 # Eval the value of every variables in ${CONFIGDIR}/.config that matches
 # the pattern `COMMAND.*`
 #
 # @params none
 # @return none
##
run_commands() {
  for c in "${CONFIGVARS[@]}"; do
    VAR=$c
    eval VAL="\$$c"
    [[ $VAR =~ COMMAND.* ]] && {
      log blue "executing: ${VAL}"
      eval "$VAL"
    }
  done
}
