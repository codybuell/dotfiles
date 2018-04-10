Dotfiles
========

Personal dot and configuration files for Linux & OSX systems.

Setup
-----

 1. Clone this repository and get the submodules

        git clone https://github.com/codybuell/dotfiles.git; cd dotfiles

        git submodule init; git submodule update

        # or alternatively

        make subs

 2. Copy and edit the example configuration file

        cp .config.example .config
        # edit .config to suit your needs

 3. Run make

        make         # detects system type and places all configs
        
        # alternatively you can run individual configuration components
        make [ subs | brew | dots | osx | linux | composer | gem | go | node | pip | clean ]
        
        # subs:     pulls down all the git submodules / repo dependencies
        # brew:     runs package installs for osx (see scripts/brew.sh for full list)
        # dots:     places dotfiles in ~/, existing files are moved to .[name].orig.[timestamp]
        #           takes an argument to target a single dotfile i.e. `make dots vimrc`
        # osx:      runs os configs, hotcorners, system cofig settings, etc
        # linux:    runs os configs, dconf settings, font setup, tweak tool, package installs
        # composer: installs php packages, laravel valet, etc (see scripts/composer.sh for full list)
        # gem:      installs ruby packages (see scripts/gem.sh for full list)
        # go:       installs go packages (see scripts/go.sh for full list)
        # node:     installs node packages (see scripts/node.sh for full list)
        # pip:      installs python packages (see scripts/pip.sh for full list)
        # clean:    removes backups of old configurations
        
        # suggested order if running manually:
        #
        #   1. subs (then brew if on osx)
        #   2. dots
        #   3. [os]
        #   4. [ composer | gem | go | node | pip ] in any order

Additional New System Configurations
------------------------------------

 - setup chrome account(s)
 - lpass cli login
 - weechat configuration (follow `~/.weechatrc` instructions)

        # on linux hosts, you need to point to the right cert bundle, within weechat:
        /set weechat.network.gnutls_ca_file /etc/ssl/certs/ca-bundle.crt

 - any necessary graphic card drivers
 - any necessary bios updates
 - any necessary os updates
 - any necessary pci card drivers
 - ?? yubikey udev rules on linux hosts ??
 - fstab mounts
 - configure any additional internal drives

Todo
----

- build tie in to vim calendar for journal mappings
- setup imap filter rules in .config to be deployed with make dots
- smooth vim configs, feat compat checks, au groups and load checks
- tmux cursor change changes cursor in all panes (vi and zsh mode changes)...
   - callback in tmux when changing pane to set the cursor to what it's supposed to be?
   - move it to a ps1 line update instead...?
   - solution for vim?
   - just deal with it?

References
----------

- [Greg Hurrell's dotfiles](https://github.com/wincent/wincent)
- [Greg Hurrell's YouTube channel](https://www.youtube.com/channel/UCXPHFM88IlFn68OmLwtPmZA)
