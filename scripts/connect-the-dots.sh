#!/bin/bash
#
# Connect The Dots
#
# Script to quickly deploy dotfiles into your accounts home directory.
#
# Author(s): Cody Buell
#
# Revisions: 2013.11.28 Initial framework
#            2016.07.22 Add configuration file
#            2016.07.23 Fixes to diff checking and templating

#######################
# Establish Variables #
#######################

# defaults
SKIPBACKUPS=false

# define locations
CONFGDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../ && pwd )"
DOTS_LOC="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &&  cd ../dotfiles && pwd )"
DOTFILES=(`ls $DOTS_LOC`)
UNAME=`uname -s`

# what to exclude when comparing existing files (tmp files, compiled bits, etc)
DIFFEXCLUDES=( \
  "-name *.DS_Store" \
  "-regex .*.vim.*/.netrwhist" \
  "-regex .*.vim.*/bundle/ultisnips/pythonx/.*.pyc" \
  "-regex .*.vim.*/bundle/.*/doc/tags" \
  "-path *.vim*/bundle/command-t/ruby/command-t/*" \
  "-path *.vim*/tmp/*" \
  "-path *.vim*/view/*" \
  "-path *.homestead*/src/*" \
  )

# what to exclude when templating (tmp files, git submodules, etc)
TEMPLATEEXCLUDES=( \
  "-name *.DS_Store" \
  "-path *.shell*/base16-shell/*" \
  "-path *.vim*/bundle/*" \
  "-path *.vim*/tmp/*" \
  "-path *.terminfo*/*" \
  )

# compile excludes to find statement for diffs
for (( i = 0; i < ${#DIFFEXCLUDES[@]}; i++ )); do
  DIFFEXCLUDE+=" -not ${DIFFEXCLUDES[$i]}"
done

# compile excludes to find statement for templating
for (( i = 0; i < ${#TEMPLATEEXCLUDES[@]}; i++ )); do
  TEMPLATEEXCLUDE+=" -not ${TEMPLATEEXCLUDES[$i]}"
done

# determin sed syntax
[[ $UNAME =~ ^Darwin ]] && {
  sedi="sed -i ''"
} || {
  sedi="sed -i"
}

####################
# Define Functions #
####################

usage() {

  cat <<-ENDOFUSAGE
	usage: $(basename $0) [-i file] [-n]

	  -h, --help           Display usage information.
	  -n, --no-backup      No backups, does not make a ".orig" copy.
	  -i [file]            Dotfiles to ignore, one argument per flag

	ENDOFUSAGE

}

prettyprint() {

  printf "$1" | awk '{file=$1;$1="";printf "  %-30s %s\n", file, $0}' | sed "s/ /,/g;s/\([^,]\),/\1 /g;s/,\([^,]\)/ \1/g;s/^,/ /;s/,/./g";

}

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

placefiles() {

  # grab home dir full path and timestamp
  cd; HOME=`pwd`
  DATE=`date +%Y%m%d%H%M%S`

  # iterate through the dotfiles
  for i in ${DOTFILES[@]}; do

    # pass on ignore files
    for IGN in ${IGNORE[@]}; do
      if [ $i == $IGN ]; then
        prettyprint "  .${i} \033[0;31mignoring\033[0m\n"
        continue 2
      fi
    done

    # place dotfile as dotfile.new.date
    cp -a $DOTS_LOC/$i $HOME/.$i.new.$DATE

    # run compilations if necessary
    case $i in
      vim )
        # compile command-t
        [[ -d ~/.vim.new.$DATE/bundle/command-t/ruby/command-t ]] && {
          cd ~/.vim.new.$DATE/bundle/command-t/ruby/command-t
          ruby extconf.rb > /dev/null
          make > /dev/null
          cd - > /dev/null
        }
        # # add hjkl rebindings if colemak
        # [[ $KBLayout == 'colemak' ]] && {
        #   $sedi 's/^"COLEMAK//' ~/.vim.new.$DATE/plugin/mappings/normal.vim
        # }
        ;;
      terminfo )
        cd ~/.terminfo.new.$DATE
        for terminfo in `ls`; do
          tic -o ~/.terminfo.new.$DATE $terminfo
        done
        cd - > /dev/null
        ;;
    esac

    # set the template variables
    for c in ${CONFIGVARS[@]}; do
      VAR=$c
      eval VAL=\$$c
      find ~/.$i.new.$DATE $TEMPLATEEXCLUDE -type f -exec $sedi "s|{{[[:space:]]*$VAR[[:space:]]*}}|$VAL|g" {} \;
    done

    # if the target file or dir already exists
    if [ -f $HOME/.$i ] || [ -d $HOME/.$i ]; then
      # if it is a symlink then remove it
      if [ -L $HOME/.$i ]; then
        prettyprint "  .${i} \033[0;32mremoving old symlink and replacing\033[0m\n"
        rm $HOME/.$i
      # if it is not a symlink compare it
      else
        # determine md5 binary name
        which md5 > /dev/null 2>&1
        [[ $? -gt 0 ]] && {
          MD5='md5sum'
          MD5Q='md5sum'
        } || {
          MD5='md5'
          MD5Q='md5 -q'
        }

        # gather the checksums
        if [ -d $HOME/.$i ]; then
          MD5NEW=`find $HOME/.$i.new.$DATE $DIFFEXCLUDE -type f -exec $MD5 {} \; | sort -k 2 | awk '{print \$4}' | $MD5 | awk '{print $1}'`
          MD5OLD=`find $HOME/.$i $DIFFEXCLUDE -type f -exec $MD5 {} \; | sort -k 2 | awk '{print \$4}' | $MD5 | awk '{print $1}'`
        else
          MD5NEW=`$MD5Q $HOME/.$i.new.$DATE | awk '{print $1}'`
          MD5OLD=`$MD5Q $HOME/.$i | awk '{print $1}'`
        fi

        # compare checksums
        if [ $MD5NEW == $MD5OLD ]; then
          # if the same
          prettyprint "  .${i} \033[0;32malready there\033[0m\n"
          rm -rf $HOME/.$i.new.$DATE
          continue
        elif [ $SKIPBACKUPS == 'false' ]; then
          # if different with backups enabled
          prettyprint "  .${i} \033[0;32mplacing dotfile\033[0m (\033[0;33moriginal moved to ~/.$i.orig.$DATE\033[0m)\n"
          mv $HOME/.$i $HOME/.$i.orig.$DATE
        else
          # if different with backups disabled
          prettyprint "  .${i} \033[0;32mplacing dotfile\033[0m\n"
          rm -rf $HOME/.$i
        fi
      fi
    else
      prettyprint "  .${i} \033[0;32mplacing dotfile\033[0m\n"
    fi

    # place new dotfile
    mv $HOME/.$i.new.$DATE $HOME/.$i

  done

}

################
# Long Options #
################

[ x"$1" == x"--help" ] && {
  usage
  exit
}

[ x"$1" == x"--no-backup" ] && {
  SKIPBACKUPS=true
}

#################
# Short Options #
#################

while getopts ":hi:n" Option; do
  case $Option in
    h )
      usage
      exit
      ;;
    i )
      IGNORE=(${IGNORE[@]} $OPTARG)
      ;;
    n )
      SKIPBACKUPS=true
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
