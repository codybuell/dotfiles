Dotfiles
========

Personal dot and configuration files.

Although a majority of these configurations have been built up over the years and inspired from multiple sources, the better parts of my vim and tmux configurations have been shamelessly borrowed and or adapted from [Greg Hurrell's](https://github.com/wincent) excellent [dotfiles](https://github.com/wincent/wincent), give them a look over.  I'll cite other sources as they come to mind.

Installation
------------

 1. Clone this repository and get the submodules

        git clone https://github.com/codybuell/dotfiles.git; cd dotfiles
        git submodule init; git submodule update

 2. Copy and edit the example configuration file

        cp .config.example .config
        # edit .config to suit your needs

 3. Run make

        make [ osx | linux | osxdefs | linuxdefs | dots | brew ]

Todo
----

 - [ ] finish modding xoria colorscheme to fit shell, vim and tmux
 - [ ] copy .purple finch-notify.pl plugin

### vim

 - [ ] command to cycle nu rnu, subset of @wincent's solution
 - [ ] build tab bar (tab number, collapsing path if needed, show buffers if no tabs, remove X in top right)
 - [ ] add syntastic error alerts to statusbar
 - [ ] rework html email snippet
 - [ ] resize statusbar when error indicator column is present >>
 - [ ] refine ultisnips / supertab integration, tab for everything? exapand and go to next tabstop, with autocompletion?
   - try just setting gvars for expand and next to tab, may just work w supertab, also try filling out a tabs to then hitting tab, make sure supertab works as well, if so make comment that you need supertab 
 - [ ] add conditionals to be able to open vi, not vim, without errors
 - [ ] skim hacks, notes, and repos for handy snippets (getopts, prompts, etc)
 - [ ] clipboard integration solution, pbcopy? (define iskeyword separators, middle click to paste, help iskeyword)

### tmux

 - [ ] rework config to use scheme color names, dont hardcode the colors

### shell

 - [ ] move repocheck alias to a function
 - [ ] test out z-shell, output duration and exit code of execution after command

### ddclient

 - [ ] setup ddclient file... contains sensitive info
   - cp ddclient.conf to /usr/local/etc/ddclient/
   - sudo brew services start ddclient

### keycastr

 - add keycastr configfile to repo and deploy w make

### screenflow

 - copy settings to repo and deploy w make (text overlay color, font etc.)
 - ctrl + alt + command + space = toggle recording
