# script to configure linux environment, comprable to brew.sh

# detect system w/uname or lsb_release -a

# if ubuntu
apt-get install \
  cmake \
  exuberant-ctags \
  gcc \
  git \
  libevent-dev \
  libncurses5-dev \
  nfs-common
  ruby \
  ruby-dev \
  vim-nox \
# uninstall apt tmux, curl the latest, ./config && make; make install

# set colemak and caps lock to ctrl
# /etc/defaults/keyboard -> XKBOPTIONS="ctrl:nocaps" XKBVARIANT="colemak"
