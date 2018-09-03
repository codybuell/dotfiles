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

Structure
---------

```
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


Todo
----

### Baseline ###

- [ ] `all` make target for fully automated deployment
- [ ] make dots needs to check if symlinks are there too, md5 summable?
- [ ] Additional make targets??
  - `fonts`
  - `full`??
  - `ddclient`
  - `iterm`
  - `karabiner`
  - `windows`
- [ ] Document all your dotfiles inline, what they do, etc so you dont forget!
- [ ] Pull in remaining configurations from dotfiles repo
- [ ] Merge this in as a branch of the core dotfiles repo
- [ ] After merging into master tag commits (latest iteration 3.0.0)
  - v1.0.0 baseline dotfiles
  - v2.0.0 automated installations
  - v3.0.0 refactor with nvim
- [ ] De-duplicate configurations in .config[.example] and update references in repo `{{ VAR }}` (i.e. ~/Repos is referenced several times, rename var to PATHRepos and it will be made in scripts/paths, just need to update it's references elsewhere)
- [ ] submodules
  - <https://github.com/chriskempson/base16-shell.git>
  - <https://github.com/honza/mutt-notmuch-py.git>
  - <https://github.com/zsh-users/zsh-autosuggestions.git>
  - <https://github.com/zsh-users/zsh-syntax-highlighting.git>

#### weechat ####

- [ ] automate deployment of ~/weechatrc

#### zsh ####

- [ ] refactor zshrc, break into sub files in ~/.shell

#### tmux ####

- [ ] Get copy and paste working with the system clipboard

#### vim/nvim ####

- [ ] Deoplete completion source for generating wiki links (internal links, inter wiki links, etc)
- [ ] Linux compatibility
  - Test installation, ensure free from errors
  - Get copy and paste working with the system
  - Need to add symlink of `~/.vimrc` to `~/.vim/init.vim`
- [ ] Consistent functionality between Vim / Nvim
- [ ] Nerdtree fails to load fully when running `wj` or `pj` alias from shell, `r` to refresh then have to toggle folds twice to open
- [ ] Color settings
  - Something is changing `UserN` highlight groups on various focus events
  - For not standard buffer windows / splits just show an all gray statusbar with plugin / window name (quickfix, command-t etc)
- [ ] Setup tabbar / tabline
- [ ] Snippets
- [ ] Finish wiki plugin, add assoc. array of wiki's and locations, create / follow link function to handle wiki and internal links
- [ ] On focus / blur events
  - Toggle syntax hl
  - Toggle statusline simple gray / full
  - Reload buffer on focus if file changed

#### ruby / rvm ####

- [ ] Implement: <https://tecadmin.net/install-ruby-latest-stable-centos/>

#### osx ####

- [ ] Clean up scripts/osx.sh, add `prettyprint` for consistency
- [ ] Finish providing options at head

#### hammerspoon ####

- [ ] refactor (break into files, add comments, clean syntax)

#### Mutt ####

- [ ] Mail filtering rules in config (forward public goods to Court, etc)
- [ ] Add alias groups in mutt (gamenight, etc)

#### Shell ####

- [ ] Alias vi and vim to nvim
- [ ] Need to dynamically setup gopath for projects... right way??  better way??  when will go do away with gopath??
- [ ] Improve color support for mosh (does not support 24 bit color?)

### New Features

- [ ] Transition to Universal CTags?

#### vim/nvim ####

- [ ] Move `plugin/math.vim` to an auto-loaded function? fix instances where it doesn't work!
- [ ] Improve foldtext to better show fold depth and folded object?
  - Remove `#`s from title sections?
  - Show a sparkline representation of size? `[:::.......]`
- [ ] Improve markdown syntax highlighting so its super easy to digest
- [ ] Dragvisuals plugin to replace text it is moving to rather than push it out of the way or flow through it, the stuff pushed over should flow to the back of the motion (moving down the text covered on the bottom would go to the top where the moved text once was)
- [ ] CycleViews function, additional modes:
  - Black and white syntax theme
  - No syntax
  - No special chars (line ending markrs)
  - No line wrapping
  - Hide numbers and sidebars
  - Conceal comments
- [ ] Tie in for GPG file encryption
- [ ] Markdown syntax support in mail filetype
- [ ] possilbe vim plugins:
  - <https://github.com/pangloss/vim-javascript>
  - <https://github.com/bkad/CamelCaseMotion>
  - <https://github.com/lvht/phpcd.vim>
  - <https://github.com/codybuell/vim-comceal.git>
  - Something for blade syntax
