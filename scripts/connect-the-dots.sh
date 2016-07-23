#!/bin/bash
#
# Connect The Dots
#
# Script to quickly symlink dotfiles into your accounts home directory.
#
# Author(s): Cody Buell
#
# Revisions: 2013.11.28 Initial framework
#            2016.07.22 Add configuration file

#######################
# Establish Variables #
#######################

SYMLINK='false'

CONFGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../ && pwd )"
DOTS_LOC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../dotfiles && pwd )"
DOTFILES=(`ls $DOTS_LOC`)
WHO_AM_I=`whoami`

####################
# Define Functions #
####################

usage() {
  cat <<-ENDOFUSAGE
	usage: $(basename $0) [-i file]

	  -h, --help           Display usage information.
	  -i [file]            Dotfiles to ignore, one argument per flag

	ENDOFUSAGE
}

readconfig() {
  CONFIGVARS=()
  shopt -s extglob
  configfile="$CONFGDIR/config"
  [[ -e $configfile ]] && {
    tr -d '\r' < $configfile > $configfile.tmp
    while IFS='= ' read lhs rhs; do
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

placefiles() {
  # establish home directory
  cd; HOME=`pwd`

  # set timestamp
  DATE=`date +%Y%M%d%H%m%S`

  # iterate through dotfiles
  for i in ${DOTFILES[@]}; do

    # pass on ignore files
    for IGN in ${IGNORE[@]}; do
      if [ $i == $IGN ]; then
        printf "  .${i}: \033[0;31mignoring\033[0m\n"
        continue 2
      fi
    done

    # if the file or dir already exists
    if [ -f $HOME/.$i ] || [ -d $HOME/.$i ]; then
      if [ -L $HOME/.$i ]; then
        # if file is a symlink then remove it
        printf "  .${i}: \033[0;32mremoving old symlink and replacing\033[0m\n"
        rm $HOME/.$i
      else
        # if not symlink move files to dot orig.date
        mv $HOME/.$i $HOME/.$i.orig.$DATE
      fi
    # if nothing is in place
    else
      printf "  .${i}: \033[0;32mplacing dotfile\033[0m\n"
    fi

    # place the file
    [[ $SYMLINK == 'true' ]] && ln -s $DOTS_LOC/$i .$i || cp $DOTS_LOC/$i .$i

    # set the template variables
    for c in ${CONFIGVARS[@]}; do
      VAR=$c
      eval VAL=\$$c
      sed -i '' "s/{{[[:space:]]*$VAR[[:space:]]*}}/$VAL/g" ~/.$i
    done

    # if a backup was created determine if its a duplicate
    if [ -e $HOME/.$i.orig.$DATE ]; then
      # determine md5 binary name
      which md5 > /dev/null
      MD5=`[[ $? -gt 0 ]] && echo md5sum || echo md5`

      # if newly placed file or dir is same as the old one, delete the old one
      if [ -d $HOME/.$i ]; then
        MD5NEW=`find $HOME/.$i -type f -exec $MD5 {} \; | sort -k 2 | $MD5`
        MD5OLD=`find $HOME/.$i -type f -exec $MD5 {} \; | sort -k 2 | $MD5`
      else
        MD5NEW=`$MD5 -q $HOME/.$i`
        MD5OLD=`$MD5 -q $HOME/.$i.orig.$DATE`
      fi
  
      [[ $MD5NEW == $MD5OLD ]] && {
         printf "  .${i}: \033[0;32malready there\033[0m\n"
         rm -rf $HOME/.$i.orig.$DATE
      } || {
         printf "  .${i}: \033[0;32mplacing dotfile\033[0m (\033[0;33moriginal moved to ~/.$i.orig.$DATE\033[0m)\n"
      }
    fi
  done
}

################
# Long Options #
################

[ x"$1" = x"--help" ] && {
  usage
  exit
}

#################
# Short Options #
#################

while getopts ":hi:" Option; do
  case $Option in
    h )
      usage
      exit
      ;;
    i )
      IGNORE=(${IGNORE[@]} $OPTARG)
      ;;
    : )
      echo "Option -$OPTARG requires an argument." >&2
      exit
      ;;
  esac
done

##########
# Run It #
##########

echo 'connecting the dots...'
readconfig
placefiles
