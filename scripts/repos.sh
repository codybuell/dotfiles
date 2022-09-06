#!/bin/bash
#
# Repos
#
# Clone git repositories listed in the repository configuration file.
#
# Author(s): Cody Buell
#
# Requisite:
#
# Tasks: 
#
# Usage: make repos
#        scripts/repos.sh

source scripts/library.sh

######################
#                    #
#  Define Functions  #
#                    #
######################

# git clone to folder structure $Repos/site/userORgroup/userORgroupN/repo
function gcl() {
  CLONEPATH=`echo $1 | sed -E 's/git\@|http(s)?:\/\///;s/\.git$//;s/:/\//g'`
  git clone $1 $Repos/$CLONEPATH
  cd $Repos
  find $Repos -type d -name .git -maxdepth 8 | sed 's/\/\.git$//' | awk -F\/ '{print $NF":"$0}' > .repos
  cd -
}

# Clone Repos
#
# Clone repos to the $Repos path as defined by every $REPO.* variable in
# $CONFIGDIR/.config.

clonerepos() {
  printf "\033[0;34msetting up repositories...\033[0m\n"
  for r in ${CONFIGVARS[@]}; do
    VAR=$r
    eval VAL=\$$r
    [[ $VAR =~ REPO.* ]] && {
      MAKEMODEL=`echo $VAL | sed 's/\// /g;s/\.git//;s/:/ /g' | awk '{print $(NF-1)"/"$NF}'`
      CLONEPATH=`echo $VAL | sed -E 's/git\@|http(s)?:\/\///;s/\.git$//;s/:/\//g'`
      echo $MAKEMODEL
      echo $CLONEPATH
      [[ ! -d $CLONEPATH ]] && {
        prettyprint "  ${MAKEMODEL}:\033[0;32mcloning\033[0m\n"
        gcl $VAL
      } || {
        prettyprint "  ${MAKEMODEL}:\033[0;32malready cloned\033[0m\n"
      }
    }
  done
}

############
#          #
#  Run It  #
#          #
############

readconfig
clonerepos
exit 0
