Dotfiles
========

Personal dot and configuration files.

Although a majority of these configurations have been built up over the years and inspired from multiple sources, the better parts of my vim and tmux configurations have been shamelessly borrowed and or adapted from [Greg Hurrell's](https://github.com/wincent) excellent [dotfiles](https://github.com/wincent/wincent), give them a look over.  I'll cite other sources as the come to mind.

Installation
------------

 1. Clone this repository

        git clone https://github.com/codybuell/dotfiles.git; cd dotfiles
        git submodule init; git submodule update

 2. Copy and edit the example configuration file

        cp config.example config
        # edit config to suit your needs

 3. Run connect the scripts

        ~/Repos/dotfiles/scripts/connect-the-dots.sh

 4. Check out scripts folder for other bits you may like

Features
--------

### vim

### tmux

### brew

### shell

New System Checklist
--------------------

### OSX

 - set hostname and ip (settings -> sharing, settings -> networking)
 - make directories `~/Repos` `~/Gists`
 - pull down dotfiles repo, configure and deploy
 - symlink `~/Repos/bin` -> `~/Bin`
 - configure google drive
 - install from app store
   - icon slate
   - microsoft remote desktop
   - screenflow
   - spriteright
   - volume for itunes
   - wifi explorer
   - xcode

### Linux


Todo
----

### general

 - [ ] scour dotfiles for paths, name, email, etc that need to be turned into config options
 - [ ] figure out a clipboard solution
   - want to be able to select in tmux copy mode, paste with middle click or cmd+v
   - same for vim
   - want iterms auto word selection features
 - [ ] write wrapper script for entire repo `deploy`
   - connect the dots
   - run brew
   - install fonts
   - set iterm preferences dir
 - [ ] work on transition to zsh
 - [ ] finish modding xoria colorscheme to fit shell, vim and tmux

### vim

 - [ ] how to automate set bg=dark or light with base16 color schemes?
 - [ ] command to cycle nu rnu
 - [ ] add mnemonics for mappings
 - [ ] build tab bar (tab number, collapsing path if needed, show buffers if no tabs, remove X in top right)
 - [ ] add syntastic error alerts to statusbar
 - [ ] build / find gulpfile snippet

### tmux

 - [ ] change default key binding to something more... comfortable
 - [ ] rework config to use scheme color names, dont hardcode the colors

### shell

 - [ ] move repocheck alias to a function

### irssi

 - [ ] add config

### scripts/osx.sh

 - [ ] trackpad gesture configs
 - [ ] systemuiserver menu extras
 - [ ] keyboard shortcut for input type switching
 - [ ] analog clock in menu
 - [ ] firewall config
 - [ ] default finder icon sizes and spacings
 - [ ] dock size and placement
 - [ ] turn on screensharing
 - [ ] set finder sidebar
   - remove all my files, documents
   - add home dir repos and gists dirs
   - re-arrange devices
   - rearrange favorites (home dir, desktop, applications, google drive, icloud drive, downloads, repos, gists)
 - [ ] set chrome as default

### scripts/fonts.sh

 - [ ] build it
