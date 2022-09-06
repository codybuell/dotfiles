#!/bin/bash
#
# Nix
#
# Provisions Nix as a brew alternative package manager and installs a baseline
# set of packages. This is intended to be run along with brew.sh and mas.sh to
# fully install all the applications used on an a system.
#
# Nix  - General package management on osx / linux
# Brew - OSX applications and additional softwares that don't work well w/ Nix
# Mas  - OSX applications from the App Store (purchased or not avail via Brew)
# ??   - Linux native package managers, bits that don't work well with Nix
#
# Author(s): Cody Buell
# 
# Requisite: - dotfiles (specifically ~/.config/nixpkgs/config.nix)
#
# Tools: nix-env
#        nix-env -iA nixpkgs.[package name]     # install a nix package
#        nix-env -q --installed                 # list installed packages
#        nix-env -e [package name]              # erase one or more packages
#        nix-env -qaP [pattern]                 # search for packages
#        nix-env --list-generations             # show previos states of nix-env
#        nix-env --rollback                     # go to previous generation
#        nix-env --switch-generation [number]   # jump to a specific generation
#
# Usage: make nix
#        ./nix.sh

# shellcheck source=./library.sh
source "${BASH_SOURCE%/*}/library.sh"

# check if nix is already installed, if not install
if ! command -v nix-env &> /dev/null; then
  log yellow "Nix not present, installing..."
  sh <(curl -L https://nixos.org/nix/install) --daemon
else
  log green "Nix found on the system, skipping installation"
fi

# run installation of base packages and os specific packages
if [ -f ~/.config/nixpkgs/config.nix ]; then
  log green "Installing base packages..."
  nix-env -iA nixpkgs.basePackages &> /dev/null
  if [[ "$(uname -s)" == "Darwin" ]]; then
    log green "Installing OSX specific packages..."
    nix-env -iA nixpkgs.osxPackages &> /dev/null
  else
    log green "Installing Linux specific packages..."
    nix-env -iA nixpkgs.linuxPackages &> /dev/null
  fi
else
  log boldred "Base packages configuration missing"
fi

# symlink missing ~/.nix-profile/Applications/* -> ~/Applications/*
# TODO: clear out stale links
if [[ "$(uname -s)" == "Darwin" ]]; then
  log green "Symlinking OSX applications..."
  cd ~/.nix-profile/Applications
  for APP in $(ls -1); do
    DST=/Applications/${APP}
    SRC=~/.nix-profile/Applications/${APP}
    [[ -d $DST || -L $DST ]] && {
      if [[ -L $DST ]]; then
        unlink "$DST"
        LINKMSG="re-linking symlink"
      else
        log green "  ${DST}" "already exists as a dir"
        continue
      fi
    }
    log yellow "  ${DST}" "${LINKMSG}"
    ln -s "$SRC" "$DST"
  cd -
  done
fi
