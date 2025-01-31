#!/bin/bash
#
# Dots
#
# Utility to place repository dotfiles into production. For the specified
# dotfile (file or folder), or all dotfiles if none specified, the script will
# first replace all variables found within each file. Variables take the format
# of {{ variable }} where `variable` corresponds to a key in the repository
# .config file. Variables are case sensitive. Next it will compare the
# finalized dotfiles with the targets destination and do one of three things:
#
#  - Skip placing the dotfile(s) if no change was detected.
#  - Place the dotfile(s) if nothing was at the target already.
#  - Backup the items currently in production by copying them and adding a
#    `.dotorig.[datetime]` extension, then placing the new dotfile(s).
#
# There are also pre and post hooks that can be configured to run before or
# after placing the corresponding dotfiles. See the functions pre_place_hooks
# and post_place_hooks below.
#
# Backup dotfiles can be removed by running `make clean`.
#
# Author(s): Cody Buell
#
# Requisite: - ../.config (or .config in dir $CONFIGDIR)
#            - ../dotfiles/* (or dir configured by DOTS_LOC)
#
# Tools:
#
# Usage: make dots [file|folder] [file|folder] ...
#        ./dots.sh [file|folder] [file|folder] ...

# shellcheck source=./library.sh
source "${BASH_SOURCE%/*}/library.sh"

################################################################################
#                                                                              #
#  Configuration                                                               #
#                                                                              #
################################################################################

# flag / option defaults
SKIPBACKUPS=false
FORCE=false

# what to exclude when templating (tmp files, git submodules, etc)
TEMPLATEEXCLUDES=( \
  "-name *.DS_Store" \
  "-path *.mutt*/scripts/vendor/*" \
  "-path *.zsh*/plugins/base16-shell/*" \
  "-path *nvim*/bundles/*" \
  "-path *nvim*/pack/*" \
  "-path *nvim*/tmp/*" \
  "-path *.terminfo*/*" \
  )

# what to exclude when comparing existing files (tmp files, compiled bits, etc)
DIFFEXCLUDES=( \
  "-name *.DS_Store" \
  "-regex .*.mutt*/tmp" \
  "-path *.config/nvim*/backup" \
  "-path *.config/nvim*/sessions" \
  "-path *.config/nvim*/swap" \
  "-path *.config/nvim*/spell" \
  "-path *.config/nvim*/undo/*" \
  "-path *.config/nvim*/view/*" \
  "-path *.config/nvim*/pack/bundle/opt/*" \
  "-path *.mutt*/tmp/*" \
  "-path *.homestead*/src/*" \
  "-path *.imapfilter*/certificates" \
  "-path */__pycache__/*" \
  )

# grab home dir full path and timestamp
HOME=$(cd && pwd)
DATE=$(date +%Y%m%d%H%M%S)

# determine md5 binary name
if which md5 &> /dev/null; then
  MD5='md5'
  MD5Q='md5 -q'
else
  MD5='md5sum'
  MD5Q='md5sum'
fi

################################################################################
#                                                                              #
#  Functions                                                                   #
#                                                                              #
################################################################################

##
 # Usage
 #
 # Prints script usage, does not exit.
 #
 # @params none
 # @return none
##
usage() {
  cat <<-ENDOFUSAGE
	usage: $(basename "$0") [-hfn] [-i file]

	  -h, --help           Display usage information.
	  -f, --force          Place files even if no diff is found
	  -n, --no-backup      No backups, does not make a ".dotorig" copy.
	  -i [file]            Dotfiles to ignore, one argument per flag

	ENDOFUSAGE
}

##
 # Pre-Place Hooks
 #
 # Defines and exutes commands to be run BEFORE placing a corresponding dotfile
 # into production. Case statements should match the name of the file here in
 # the repository, ie no preceeding `.`.
 #
 # @params <TARGET>
 #   TARGET (str): dotfile (file/folder) being placed
 # @return none
##
pre_place_hooks() {
  CURRENTTARGET=$1
  CWD=$(pwd)
  if [[ -d ~/".${CURRENTTARGET}.new.${DATE}" ]]; then
    cd ~/".${CURRENTTARGET}.new.${DATE}" || exit 1
  fi

  case $CURRENTTARGET in
    *nvim )
      # ln -s "$CONFIGDIR"/assets/snippits snippits
      # ln -s "$CONFIGDIR"/assets/en.utf-8.add spell/en.utf-8.add
      # ln -s init.vim vimrc
      ;;
    terminfo )
      for terminfo in *; do
        tic -o ~/".terminfo.new.$DATE" "$terminfo" > /dev/null 2>&1
      done
      ;;
    mutt )
      # bundler gem bits (mime types) need to be installed
      cd scripts > /dev/null || exit 1
      bundle install
      cd - > /dev/null || exit 1
      ;;
    shell )
      # place dynamic environment variables from config
      echo "" >> exports
      echo "### CONFIG DRIVEN VARS ###" >> exports
      for e in "${ENVVARS[@]}"; do
        VAR="${e//ENVVAR_/}"
        eval VAL="\$$e"
        echo "export ${VAR}=${VAL}" >> exports
      done
      ;;
  esac

  cd "$CWD" > /dev/null || exit 1
}

##
 # Post-Place Hooks
 #
 # Defines and exutes commands to be run AFTER placing a corresponding dotfile
 # into production. Case statements should match the name of the file here in
 # the repository, ie no preceeding `.`.
 #
 # @params <TARGET>
 #   TARGET (str): dotfile (file/folder) being placed
 # @return none
##
post_place_hooks() {
  CURRENTTARGET=$1
  CWD=$(pwd)
  if [[ -d ~/".${CURRENTTARGET}.new.${DATE}" ]]; then
    cd ~/".${CURRENTTARGET}.new.${DATE}" || exit 1
  fi

  case $CURRENTTARGET in
    msmtprc )
      chmod 600 ~/.msmtprc
      ;;
    Xresources )
      xrdb ~/.Xresources
      ;;
    config/karabiner )
      launchctl stop org.pqrs.karabiner.karabiner_console_user_server
      launchctl start org.pqrs.karabiner.karabiner_console_user_server
      ;;
    gnupg )
      chmod 700 ~/.gnupg
      ;;
    config|*nvim )
      NVIMPATH=$(which -a nvim | uniq | grep -v 'alias' | head -1)

      # symlink spell from this repo
      rm -rf "${HOME}"/.config/nvim/spell; ln -s "${DOTS_LOC}"/config/nvim/spell "${HOME}"/.config/nvim/spell

      # generate helptags for all plugins
      ${NVIMPATH} --headless +'helptags ALL' +qa > /dev/null 2>&1

      # run treesitter-install (not working)
      # ${NVIMPATH} --headless +'TSInstall' +qa > /dev/null 2>&1

      # markdown-preview.nvim
      ${NVIMPATH} --headless +'lua vim.fn["mkdp#util#install"]()' +qa > /dev/null 2>&1
      ;;
  esac

  cd "$CWD" > /dev/null || exit 1
}

##
 # Place Files
 #
 # Handles placing files into production and the associated logic to fill
 # variables, diff, backup etc.
 #
 # @params none
 # @return none
##
place_files() {
  log blue "placing files..."

  # iterate through the dotfiles
  for i in ${DOTFILES[@]}; do

    ###########
    #  skips  #
    ###########

    # skip if file or dir does not exist
    if [[ (! -f ${DOTS_LOC}/${i}) && (! -d ${DOTS_LOC}/${i}) ]]; then
      log red "  .${i}" "not found in repo"
      continue 2
    fi

    # skip if in ignore list
    for IGN in ${IGNORE[@]}; do
      if [ "${i}" == "${IGN}" ]; then
        log red "  .${i}" "ignoring"
        continue 2
      fi
    done

    ########################################
    #  placing, pre hooks, and templating  #
    ########################################

    # place dotfile as dotfile.new.date
    cp -a "${DOTS_LOC}/${i}" "${HOME}/.${i}.new.${DATE}"

    # run custom commands as necessary
    pre_place_hooks "${i}"

    # replace all variables found in dotfiles
    for c in ${CONFIGVARS[@]}; do
      VAR=${c}
      eval VAL="\$$c"
      # escape any @'s in the value so perl dosen't hose it
      VAL=$(echo $VAL | sed 's/\@/\\\@/g')
      find ~/".${i}.new.${DATE}" ${TEMPLATEEXCLUDE} -type f -print0 | xargs -0 perl -pi -e "s|{{[[:space:]]*${VAR}[[:space:]]*}}|${VAL}|g"
    done

    #############
    #  diffing  #
    #############

    # if the target file or dir already exists
    if [ -f "${HOME}/.${i}" ] || [ -d "${HOME}/.${i}" ]; then
      # if it is a symlink then remove it
      if [ -L "${HOME}/.${i}" ]; then
        log green "  .${i}" "removing old symlink and replacing"
        rm "${HOME}/.${i}"
      # if it is not a symlink compare it
      else
        # gather the checksums
        if [ -d "${HOME}/.${i}" ]; then
          MD5NEW=$(find "${HOME}/.${i}.new.${DATE}" ${DIFFEXCLUDE} -type f -exec ${MD5} {} \; | sort -k 2 | awk '{print $4}' | ${MD5} | awk '{print $1}')
          MD5OLD=$(find "${HOME}/.${i}" ${DIFFEXCLUDE} -type f -exec ${MD5} {} \; | sort -k 2 | awk '{print $4}' | ${MD5} | awk '{print $1}')
          # find "${HOME}/.${i}.new.${DATE}" ${DIFFEXCLUDE} -type f -exec ${MD5} {} \; | sort -k 2 > ~/Desktop/new.txt
          # find "${HOME}/.${i}" ${DIFFEXCLUDE} -type f -exec ${MD5} {} \; | sort -k 2 > ~/Desktop/old.txt
        else
          MD5NEW=$(${MD5Q} "${HOME}/.${i}.new.${DATE}" | awk '{print $1}')
          MD5OLD=$(${MD5Q} "${HOME}/.${i}" | awk '{print $1}')
        fi

        # compare checksums
        if [[ "${MD5NEW}" == "${MD5OLD}" && "${FORCE}" == "false" ]]; then
          # if the same
          log green "  .${i}" "already there"
          rm -rf "${HOME}/.${i}.new.${DATE}"
          continue
        elif [ "${SKIPBACKUPS}" == "false" ]; then
          # if different with backups enabled
          log green "  .${i}" "placing dotfile ${YELLOW}original moved to ~/.${i}.dotorig.${DATE}"
          mv "${HOME}/.${i}" "${HOME}/.${i}.dotorig.${DATE}"
        else
          # if different with backups disabled or forcing
          log green "  .${i}" "placing dotfile"
          rm -rf "${HOME}/.${i}"
        fi
      fi
    else
      log green "  .${i}" "placing dotfile"
    fi

    ############################
    #  placing and post hooks  #
    ############################

    # place new dotfile
    mv "${HOME}/.${i}.new.${DATE}" "${HOME}/.${i}"

    # run any needed configs after placing dotfiles
    post_place_hooks "${i}"

  done
}

################################################################################
#                                                                              #
#  Handle Options                                                              #
#                                                                              #
################################################################################

[ "$1" = "--help" ] && {
  usage
  exit
}

[ "$1" = "--no-backup" ] && {
  SKIPBACKUPS=true
}

[ "$1" = "--force" ] && {
  FORCE=true
}

while getopts ":hi:nf" Option; do
  case $Option in
    h )
      usage
      exit
      ;;
    i )
      IGNORE+=("${OPTARG}")
      ;;
    n )
      SKIPBACKUPS=true
      ;;
    f )
      FORCE=true
      ;;
    : )
      echo "Option -${OPTARG} requires an argument." >&2
      exit
      ;;
    \? )
      echo "Invalid option: -${OPTARG}" >&2
      ;;
  esac
done

shift $(( OPTIND - 1 ))

################################################################################
#                                                                              #
#  Run                                                                         #
#                                                                              #
################################################################################

# compile excludes to find statement for templating
TEMPLATEEXCLUDE=''
for (( i = 0; i < ${#TEMPLATEEXCLUDES[@]}; i++ )); do
  TEMPLATEEXCLUDE+=" -not ${TEMPLATEEXCLUDES[$i]}"
done

# compile excludes to find statement for diffs
DIFFEXCLUDE=''
for (( i = 0; i < ${#DIFFEXCLUDES[@]}; i++ )); do
  DIFFEXCLUDE+=" -not ${DIFFEXCLUDES[$i]}"
done

read_config

# if unflagged arg passed set $DOTFILES with its value
if [ "$1" != "" ]; then
  # shellcheck disable=SC2206
  DOTFILES=($@)
fi

place_files
