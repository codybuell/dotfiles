Dotfiles
========

Personal dot and configuration files.

Although a majority of these configurations have been built up over the years and inspired from multiple sources, the better parts of my vim and tmux configurations have been shamelessly borrowed and or adapted from [Greg Hurrell's](https://github.com/wincent) excellent [dotfiles](https://github.com/wincent/wincent), give them a look over.  I'll cite other sources as they come to mind.

Installation
------------

 1. Clone this repository and get the submodules

        git clone https://github.com/codybuell/dotfiles.git; cd dotfiles

        git submodule init; git submodule update

        # or alternatively

        make subs


 2. Copy and edit the example configuration file

        cp .config.example .config
        # edit .config to suit your needs

 3. Run make

        make [ osx | linux | osxdefs | linuxdefs | dots | brew | subs ]
        # optionally you can add an argument to the dots target to make a single dotfile
        make dots vim

Todo
----

- rewrite prepostexec time func in c or migrate to zsh
- build tie in to vim calendar for journal mappings
- setup imap filter rules in .config to be deployed with make dots
- smooth vim configs, feat compat checks, au groups and load checks
