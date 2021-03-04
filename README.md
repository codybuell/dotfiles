Dotfiles
========

![Version](https://img.shields.io/badge/version-3.0.0--alpha-lightgrey.svg)
![OSX](https://img.shields.io/badge/OSX-supported-green.svg)
![Centos](https://img.shields.io/badge/Centos-supported-green.svg)
![Ubuntu](https://img.shields.io/badge/Ubuntu-unsupported-red.svg)
![Windows](https://img.shields.io/badge/Windows-unsupported-red.svg)

Personal host customizations primarily in the form of dotfiles for cli based applications.

Features
--------

### Configurable ###

Configuration options are available via a `.config` file to customize settings to your account (think folder locations, email accounts, git configs, etc) so there is no need to dig through files.

### Non Destructive ###

Dotfiles are moved in place rather than symlinked.  Before this occurs time-stamped backups are made of any existing configs.

### Automated ###

Fully automated deployment of configurations via `make` as well as the ability to piecemeal deployments.

### Extensible ###

Ability to define extra commands in the repository configuration file.  You can automate the creation of folders, symlinks and also run any number of custom commands.

### Vim ###

Minimal to no overrides of default mappings.  Fully documented additional mappings and plugins in `~/.vim/init.vim`.  Smooth support for `vi`, `vim`, and `neovim` in single configuration.

### Color Schemes and Fonts ###

Consistent colorschemes and fonts throughout the terminal, with easy switching between Base16 themes.


Assumptions / Best Practices
----------------------------

- git structure
- dynamic and base go paths
- keyboard remappings

Structure
---------
```bash
/                        # repository root, git dotfiles, configuration, readme, makefile
applications/            # application configurations (non dotfile configs)
assets/                  # other miscellaneous system files and resources
  applications/          # small apps worth having that dont fit into submodules or ~/.shell/bin
  autostart/             # linux *.desktop autostart files applied with `make linux`
  dconf/                 # dconf configurations applied with `make linux`
  fonts/                 # fonts utilized by configurations
  keyboard/              # karabiner keyboard configurations
  snippets/              # ultisnip formatted snippets for vim (symlinked in place)
dotfiles/                # contains actual dotfiles in templated form
scripts/                 # contains scrips utilized by repository for deployment and configuration
submodules/              # repository submodules (external repos utilized by configurations)
```
Installation
------------

### Simple

A `Makefile` has been provided to handle system preparation, testing, and ultimately deployment.  Run `make` from the root of the repository to see all available options.  The recommended flow is as follows:

1. Clone this repository to your system.

        git clone https://github.com/codybuell/dotfiles.git; cd dotfiles

2. Test for compatibility and prepare the system.

        make test       # checks that the host os can be properly detected among other things
        make subs       # pulls down or updates the git submodules used in this repository
        make config     # build the repository configuration file via the wizard

3. Deploy the configurations.

        make all

### Manual

1. Clone this repository to your system.

        git clone https://github.com/codybuell/dotfiles.git; cd dotfiles

2. Test for compatibility and prepare the system.

        make test       # checks that the host os can be properly detected among other things
        make subs       # pulls down or updates the git submodules used in this repository
        cp .config.example .config      # then work through all the variables with you favorite editor

3. Depending on your OS:

    Note that order is important here!

    OSX:

        make repos
        make paths
        make brew
        make go
        make pip
        make ruby
        make gem
        make node
        make composer
        make dots
        make osx

    Centos:

        make repos
        make paths
        make linux
        make go
        make pip
        make ruby
        make gem
        make node
        make composer
        make dots

### Ad Hoc Dotfiles

You can deploy specific dotfiles.  For example:

    make dots vim
    make dots config
    make dots config/karabiner
    make dots tmux tmux.conf

Gotchas
-------

At the moment qlstephen, a quick look plugin, is not trusted by OSX Catalina.  You need to open it manually after installation, click to trust, then restart quick look.  Should be good to go from there on.

    cd ~/Library/Quicklook/QLStephen.qlgenerator/Contents/MacOS/
    open .
    # right click on QLStephen, then click on open in the modal
    qlmanage -r
