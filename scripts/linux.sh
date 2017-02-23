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

# mv .otf fonts to ~/.local/share/fonts
mkdir -p $HOME/.local/share/fonts
find fonts -type f -name \*.otf -exec cp {} $HOME/.local/share/fonts/ ;\

# 16.04+ suck in dconf settings
dconf reset -f /org/gnome/terminal/legacy/profiles:/
dconf load /org/gnome/terminal/legacy/profiles:/ < dconf/terminal.dconf
