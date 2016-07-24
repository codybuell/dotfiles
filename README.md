Dotfiles
========

Personal dot and configuration files.

Installation
------------

 1. clone this repository

        git clone https://github.com/codybuell/dotfiles.git; cd dotfiles
        git submodule init; git submodule update

 2. copy and edit the example configuration file

        cp config.example config
        # edit config to suit your needs

 3. run connect the scripts

        ~/Repos/dotfiles/scripts/connect-the-dots.sh


Features
--------

### vim

### tmux

### brew

### shell


New System Checklist
--------------------

### OSX

 - set hostname (settings -> sharing)
 - make directories `~/Repos` `~/Gists`
 - pull down dotfiles repo, configure and deploy

### Linux


Todo
----

 - [ ] get this readme file into a reasonable state
 - [ ] write wrapper script for entire repo `deploy`
   - [ ] connect the dots
   - [ ] run brew
   - [ ] automate command-t plugin compiling
   - [ ] install fonts
   - [ ] set iterm preferences dir
 - [ ] add autocompletion to chdir shell function (repo d-> auto complete)
 - [ ] move repocheck alias to a function, add config for repo directory
 - [ ] scour dotfiles for paths, name, email, etc that need to be turned into config options
 - [ ] rework tmux config to use scheme colors, dont hardcode the colors
 - [ ] change tmux default key binding to something more...comfortable?
 - [ ] figure out a clipboard solution
   - [ ] want to be able to select in tmux copy mode, paste with click or cmd+v
   - [ ] same for vim
   - [ ] want iterms auto word selection features
 - [ ] fix list nu toggle to include fold column

 osx.sh script to do:

 - [ ] trackpad gesture configs
 - [ ] systemuiserver menu extras
 - [ ] keyboard shortcut for input type switching
 - [ ] analog clock in menu
 - [ ] firewall config
 - [ ] finder icon sizes and spacings
 - [ ] dock size and placement
 - [ ] go through systemsetup man page and config relevant options
