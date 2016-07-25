#!/bin/bash
#
# Brew
#
# Brew bootstrapping script.
#
# Author(s): Cody Buell
#
# Revisions: 2016.07.18 Initial framework.

PACKAGES=( \
    ack \
    alpine \
    ansible \
    awscli \
    bash-completion \
    bittlebee \
    coreutils \
    ctags \
    ddclient \
    dos2unix \
    ffmpeg \
    fwknop \
    gcc \
    gdal \
    git \
    git-lfs \
    gnu-typist \
    go \
    homebrew/php/composer \
    httrack \
    imagemagick \
    irssi \
    jq \
    markdown \
    minicom \
    nmap \
    node \
    openssl \
    packer \
    php70 \
    php70-mcrypt \
    picocom \
    pidgin \
    python \
    s3cmd \
    s3sync \
    sqlite \
    tmux \
    todo-txt \
    tree \
    vim \
    wakeonlan \
    watch \
    weechat \
    webkit2png \
    wget \
    wireshark \
    zsh \
)

CASKS=( \
    amazon-workspaces \
    box-sync \
    cubicsdr \
    dockertoolbox \
    firefox \
    geektool \
    google-drive \
    inkscape \
    imageoptim \
    iterm2 \
    keycastr \
    libreoffice \
    qlstephen \
    sketch \
    slack \
    vagrant \
    virtualbox \
    vmware-horizon-client \
    xquartz \
)

# install brew if necessary
which brew
[[ $? -gt 0 ]] && {
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

# update brew if necessary
brew update

# upgrade brew if neccessary
brew upgrade

# install brew packages
for i in ${PACKAGES[@]}; do
  brew install $i
done

# install brew casks
for i in ${CASKS[@]}; do
  brew cask install $i
done
