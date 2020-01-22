#!/bin/bash
#
# Dots
#
# Place repository dotfiles into production.  Replaces variables formatted as
# {{ var }} within the files with data from the repository .config and moves
# any existing files to ~/.[file].dotorig.[datetime].
#
# Author(s): Cody Buell
#
# Revisions: 2018.01.17 Initial framework.
#
# Requisite: 
#
# Task List:
#
# Usage: ./dots.sh [file|folder]

#########################
#                       #
#  Establish Variables  #
#                       #
#########################

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
  "-regex .*.vim.*/bundles" \
  "-regex .*.mutt*/tmp" \
  "-path *.vim*/tmp/*" \
  "-path *.vim*/snippits/*" \
  "-path *.vim*/bundles/*" \
  "-path *.mutt*/tmp/*" \
  "-path *.homestead*/src/*" \
  "-path *.imapfilter*/certificates" \
  "-path */__pycache__/*" \
  )

# what to exclude when templating (tmp files, git submodules, etc)
TEMPLATEEXCLUDES=( \
  "-name *.DS_Store" \
  "-path *.mutt*/scripts/vendor/*" \
  "-path *.shell*/base16-shell/*" \
  "-path *.shell*/zsh-*/*" \
  "-path *.vim*/bundles/*" \
  "-path *.vim*/tmp/*" \
  "-path *.terminfo*/*" \
  )

# compile excludes to find statement for diffs
DIFFEXCLUDE=''
for (( i = 0; i < ${#DIFFEXCLUDES[@]}; i++ )); do
  DIFFEXCLUDE+=" -not ${DIFFEXCLUDES[$i]}"
done

# compile excludes to find statement for templating
TEMPLATEEXCLUDE=''
for (( i = 0; i < ${#TEMPLATEEXCLUDES[@]}; i++ )); do
  TEMPLATEEXCLUDE+=" -not ${TEMPLATEEXCLUDES[$i]}"
done

######################
#                    #
#  Define Functions  #
#                    #
######################

usage() {

  cat <<-ENDOFUSAGE
	usage: $(basename $0) [-i file] [-n]

	  -h, --help           Display usage information.
	  -n, --no-backup      No backups, does not make a ".dotorig" copy.
	  -i [file]            Dotfiles to ignore, one argument per flag

	ENDOFUSAGE

}

prettyprint() {

  printf "$1" | awk '{file=$1;$1="";printf "  %-40s %s\n", file, $0}' | sed "s/ /,/g;s/\([^,]\),/\1 /g;s/,\([^,]\)/ \1/g;s/^,/ /;s/,/./g";

}

readconfig() {

  ENVVARS=()
  CONFIGVARS=()
  # add in some baseline configs
  CONFIGVARS+="CONFGDIR UNAME "
  # parse the config file
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
        # build configvars and envvars arrays
        if [[ $lhs =~ ENVVAR_.* ]]; then
          ENVVARS+="$lhs "
        else
          CONFIGVARS+="$lhs "
        fi
      fi
    done < $configfile.tmp
    export CONFIGVARS
  } || {
    printf "\033[0;31mno configuration file detected\033[0m\n"
    exit 1
  }
  rm $configfile.tmp

}

preplacehooks() {

  CURRENTTARGET=$1

  case $CURRENTTARGET in
    vim )
      cd ~/.vim.new.$DATE
      ln -s $CONFGDIR/assets/snippets snippits
      ln -s $CONFGDIR/assets/en.utf-8.add spell/en.utf-8.add
      ln -s init.vim vimrc
      cd - > /dev/null
      ;;
    terminfo )
      cd ~/.terminfo.new.$DATE
      for terminfo in `ls`; do
        tic -o ~/.terminfo.new.$DATE $terminfo
      done
      cd - > /dev/null
      ;;
    mutt )
      # bundler gem bits (mime types) need to be installed
      cd ~/.mutt.new.$DATE/scripts
      bundle install
      cd ~/.mutt.new.$DATE/vendor
      ln -s $CONFGDIR/submodules/mutt-notmuch-py
      cd - > /dev/null
      ;;
    shell )
      cd ~/.shell.new.$DATE
      # link up repo based resources
      ln -s $CONFGDIR/submodules/base16-shell .
      ln -s $CONFGDIR/submodules/zsh-autosuggestions .
      ln -s $CONFGDIR/submodules/zsh-syntax-highlighting .
      # place dynamic environment variables from config
      echo "" >> exports
      echo "### CONFIG DRIVEN VARS ###" >> exports
      for e in ${ENVVARS[@]}; do
        VAR=`echo $e | sed "s/ENVVAR_//"`
        eval VAL=\$$e
        echo "export ${VAR}=${VAL}" >> exports
      done
      cd - > /dev/null
      ;;
  esac

}

postplacehooks() {

  CURRENTTARGET=$1

  case $CURRENTTARGET in
    Xresources )
      xrdb ~/.Xresources
      ;;
    vim )
      NVIMPATH=`which -a nvim | uniq | grep -v 'alias' | head -1`
      VIMPATH=`which -a vim | uniq | grep -v 'alias' | head -1`
      $NVIMPATH -E -s -u "~/.vim/init.vim" +PlugInstall +qa
      $VIMPATH -E +'PlugInstall --sync' +qa &> /dev/null
      gsed -i '/Base16hi/! s/a:\(attr\|guisp\)/l:\1/g' ~/.vim/bundles/base16-vim/colors/*.vim

      # link up neovim
      NVIMRTPROOT='~/.config/nvim'
      [[ -d $NVIMRTPROOT || -L $NVIMRTPROOT ]] && {
        [[ -L $NVIMRTPROOT ]] && {
          unlink $NVIMRTPROOT
        } || {
          mv ~/.config/nvim ~/.config/nvim.dotorig.`date +%Y%m%d%H%M%S`
        }
      }
      ln -s ~/.vim ~/.config/nvim

      # if linux (or vim older than ?), you need to symlink ~/.vimrc to .vim/init.vim

      # make tmp dirs
      mkdir -p ~/.vim/tmp/view ~/.vim/tmp/backup ~/.vim/tmp/undo ~/.vim/tmp/swap
      ;;
  esac

}

placefiles() {

  printf "\033[0;34mplacing files...\033[0m\n"

  # grab home dir full path and timestamp
  cd; HOME=`pwd`
  DATE=`date +%Y%m%d%H%M%S`

  # iterate through the dotfiles
  for i in ${DOTFILES[@]}; do

    # if file or dir does not exist, bail
    if [[ (! -f $DOTS_LOC/$i) && (! -d $DOTS_LOC/$i) ]]; then
      prettyprint "  .${i} \033[0;31mnot found in repo\033[0m\n"
      continue 2
    fi

    # pass on ignore files
    for IGN in ${IGNORE[@]}; do
      if [ $i == $IGN ]; then
        prettyprint "  .${i} \033[0;31mignoring\033[0m\n"
        continue 2
      fi
    done

    # place dotfile as dotfile.new.date
    cp -a $DOTS_LOC/$i $HOME/.$i.new.$DATE

    # run custom commands as necessary
    preplacehooks $i

    # set the template variables
    for c in ${CONFIGVARS[@]}; do
      VAR=$c
      eval VAL=\$$c
      [[ $UNAME =~ ^Darwin ]] && {
        find ~/.$i.new.$DATE $TEMPLATEEXCLUDE -type f -print0 | xargs -0 sed -i '' "s|{{[[:space:]]*${VAR}[[:space:]]*}}|${VAL}|g"
      } || {
        find ~/.$i.new.$DATE $TEMPLATEEXCLUDE -type f -print0 | xargs -0 sed -i "s|{{[[:space:]]*${VAR}[[:space:]]*}}|${VAL}|g"
      }
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
          prettyprint "  .${i} \033[0;32mplacing dotfile\033[0m (\033[0;33moriginal moved to ~/.$i.dotorig.$DATE\033[0m)\n"
          mv $HOME/.$i $HOME/.$i.dotorig.$DATE
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

    # run any needed configs after placing dotfiles
    postplacehooks $i

  done

}

runcommands() {

  for c in ${CONFIGVARS[@]}; do
    VAR=$c
    eval VAL=\$$c
    [[ $VAR =~ COMMAND.* ]] && {
      printf "\033[0;34mexecuting: $VAL\033[0m\n"
      eval "$VAL"
    }
  done

}

fixperms() {
  [ -e ~/.msmtprc ] && {
    chmod 600 ~/.msmtprc
  }
}

##################
#                #
#  Long Options  #
#                #
##################

[ x"$1" == x"--help" ] && {
  usage
  exit
}

[ x"$1" == x"--no-backup" ] && {
  SKIPBACKUPS=true
}

###################
#                 #
#  Short Options  #
#                 #
###################

while getopts ":hi:n" Option; do
  case $Option in
    h )
      usage
      exit
      ;;
    i )
      IGNORE=(${IGNORE[@]} $OPTARG)
      shift 2
      ;;
    n )
      SKIPBACKUPS=true
      shift
      ;;
    : )
      echo "Option -$OPTARG requires an argument." >&2
      exit
      ;;
  esac
done

############
#          #
#  Run It  #
#          #
############

readconfig
# if unflagged arg passed set $DOTFILES with its value
if [ "$1" != "" ]; then
  DOTFILES=($1)
fi
placefiles
fixperms
if [ "$1" == "" ]; then
  runcommands
fi
exit 0
