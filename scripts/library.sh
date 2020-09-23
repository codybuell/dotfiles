# Shell Script Library
#
# Intended for use with https://github.com/codybuell/dotfiles.

###########################
#                         #
#  Environment Variables  #
#                         #
###########################


CONFGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../ && pwd )"


######################
#                    #
#  Define Functions  #
#                    #
######################


# Read Config
#
# Ingests $CONFIGDIR/.config and defines variables for each setting. Also
# generates an array $CONFIGVARS containing all keys set.

readconfig() {
  CONFIGVARS=()
  shopt -s extglob
  configfile="$CONFGDIR/.config"
  [[ -e $configfile ]] && {
    tr -d '\r' < $configfile > $configfile.tmp
    while IFS='= ' read -r lhs rhs; do
      if [[ ! $lhs =~ ^\ *# && -n $lhs ]]; then
        rhs="${rhs%%\#*}"    # del in line right comments
        rhs="${rhs%%*( )}"   # del trailing spaces
        rhs="${rhs%\"*}"     # del opening string quotes
        rhs="${rhs#\"*}"     # del closing string quotes
        export $lhs="$rhs"
        CONFIGVARS+="$lhs "
      fi
    done < $configfile.tmp
    export CONFIGVARS
  } || {
    printf "\033[0;31mno configuration file detected\033[0m\n"
    exit 1
  }
  rm $configfile.tmp
}


# Pretty Print
#
# Helper for printing status. Expects left hand and right hand text, separated
# by a ':'. Dots are added between to easily associate keys and values.

prettyprint() {
  printf "$1" | awk -F: '{file=$1;$1="";printf "%-50s %s\n", file, $0}' | sed "s/ /,/g;s/\([^,]\),/\1 /g;s/,\([^,]\)/ \1/g;s/^,/ /;s/,/./g";
}
