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

### Issues ###

#### vim/nvim ####

- [ ] Tie `make pip` as a post vim make dots hook, pre `PlugInstall`
- [ ] Make dots vim always replaces, even if no change (check your checksums)
- [ ] Command-t help, ctr-t does not open help file in new tab
- [ ] Linux compatibility
  - Terminal cursor color gets mangled with NonText hl group set in `after/base16-vim.vim` (linux only)
  - Need to add symlink of `~/.vimrc` to `~/.vim/init.vim`
- [ ] Nerdtree fails to load fully when running `wj` or `pj` alias from shell, `r` to refresh then have to toggle folds twice to open

#### shell ####

- [ ] `md:13: bad floating point constant` on occasion when running md

### New Features

- [ ] Describe the system here in the readme, purpose of `Workbench`, `Projects`, `Repo`, `Codex`, etc.  and also document in `.config.example`
- [ ] Additional make targets
  - `all`
  - `fonts`
  - `full`
  - `ddclient`
  - `iterm`
  - `karabiner`
  - `windows`
- [ ] De-duplicate configurations in `.config[.example]` and update references in repo `{{ VAR }}` (i.e. ~/Repos is referenced several times, rename var to PATHRepos and it will be made in scripts/paths, just need to update it's references elsewhere)
- [ ] Transition to Universal CTags?
- [ ] Document all your dotfiles and scripts inline
- [ ] Provide option to use vim or nvim, edit dots accordingly (gitconfig, aliases, etc)
- [ ] Tag commits
  - v1.0.0 baseline dotfiles
  - v2.0.0 automated installations
  - v3.0.0 refactor with nvim

#### vim/nvim ####

- [ ] Fix tab completion while entered into a snippet, tab currently jumps to next stop rather than cycle options
- [ ] pull in snippets for sh, css, js, html, etc from honza, build out more
      boilerplates (sass/scss, js, html, etc) consistent triggers across
      languages (for comments `/*` `/**` etc), check for same bbox sections in all
      snippets, even if emtpy for placeholder purposes
- [ ] Setup php clang and js completion sources
- [ ] setup some au FileType go nmap mappings for vim-go
- [ ] Deoplete completion source for generating wiki links (internal links, inter wiki links, etc)
- [ ] Setup tabbar / tabline
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
- [ ] refine ale
  - config ale messages in status line
  - config ale colors
  - config what linters to use with ale (explicitly define??)
  - make ale less obnoxious (less frequent??, not as blaring?, gutter only?)
- [ ] On focus / blur events
  - Toggle syntax hl
  - Reload buffer on focus if file changed

#### shell ####

- [ ] Dynamically set `$GOPATH` for projects
- [ ] Improve color support for MOSH (does not support 24 bit color?)

#### hammerspoon ####

- [ ] Refactor (break into files, add comments, clean syntax)

#### osx ####

- [ ] Clean up scripts/osx.sh, add `prettyprint` for consistency
- [ ] Finish providing options at head

#### zsh ####

- [ ] Refactor `zshrc`, break into sub files in `~/.shell`

#### weechat ####

- [ ] Automate deployment of `~/.weechatrc`

#### Mutt ####

- [ ] Open attachments not working
- [ ] Mail filtering rules in config (forward public goods to Court, etc)
- [ ] Add alias groups in mutt (gamenight, etc)

#### ruby / rvm ####

- [ ] Implement: <https://tecadmin.net/install-ruby-latest-stable-centos/>

#### docker ####

- [ ] build out `script/docker.sh`
- [ ] initialize kubernetes cluster

#### virtualbox ####

- [ ] set vm location on host to a var in `.config`

#### rxvt ####
