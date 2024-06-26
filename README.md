Dotfiles
========

Personal scripts, configurations, and dotfiles to bootstrap a new system.
Attempts to be idempotent, configurable, and composable while requiring as
little pre-configuration as possible. A rough outline of this repository is
below, refer to inline comments / documentation for more details.

Setup
-----

Assuming a fresh system requiring all dependencies and configurations:

1. Clone and `cd` into this repository.

    ```bash
    git clone https://github.com/codybuell/dotfiles && cd dotfiles
    ```

2. Edit the configuration file to as needed.

    ```bash
    cp .config.example .config; vi .config
    ```

3. Run the command to bootstrap the system.

    ```bash
    make bootstrap
    ```

There are several make targets that can be run sequentially in lieu of `make
bootstrap` or independently as needed. They are ordered below as run by `make
bootstrap`, which is determined by dependencies.

```bash
make subs                       # pull in all git repository submodules
make paths                      # create paths scaffolding as defined in `.config`
make symlinks                   # create symlinks as defined in `.config`
make repos                      # clone git repositories as defined in `.config`
make dots                       # places dotfiles, depends on repo `.config` file
make nix                        # installs nix and packages, depends on `make dots`
make mas                        # installs App Store apps, depends on `make nix`
make brew                       # installs brew packages, casks, services
make node                       # installs NVM, latest lts of Node, and global node packages
make gem                        # installs ruby gems needed for nvim support etc
make go                         # installs go tools needed lsp and credential access
make pip                        # installs pip packages needed for nvim support etc
make karabiner                  # compiles and places config, restarts service, depends on node
make osx                        # applies as many OSX configurations as possible via cli
make fonts                      # install fonts found in `assets/fonts/*`
make commands                   # run commands as defined in `.config`
```

The `make dots` target is generally the most heavily used. This is because
dotfiles are not symlinked back to this repository, so any changes made to
configurations must be placed into production. To reduce the lift the `make
dots` endpoint takes any number of arguments, being the dotfiles or dotfolders
you wish to place.

```bash
make dots vim                   # will place the dotfiles/vim folder to ~/.vim
make dots tmux.conf tmux        # can take any number of arguments
make dots config/karabiner      # also handles explicitly calling out a sub path
```

Tooling
-------

Some general notes on what's being used for what. Despite aiming for simplicity
there inevitably is a large set of tools being used because they are the right
one for the job. See configurations for Nix, Brew, and Mas for a full list of
all items used, just major items are referenced here.

### Application / Package Management

- ~~__Nix:__ Used for package installations where possible. Useful for custom dev
  environments when used in conjunction with direnv, testing packages, and
  cross OS consistency.~~ This proved to be too difficult to keep in path.
- Brew: Used for packages which are not well suited for Nix. Also used to
  install OSX applications that are not installed through the App Store.
- Mas: Command line installation of Apple App Store packages.
- NVM: For managing / switching node versions.

Since Go has a v1 compatibility promise we'll just make sure we install the
latest version, and since go modules are now the default some things are a lot
simpler now. All that to say there isn't a big need for a go version manager.

### OSX Tooling

- __Hammerspoon:__ Improved mappings, window management, automation of convenineces.
- __Karabiner-Elements:__ Keyboard remappings, SpaceFN layering, key overloading.
- __Raycast:__ Spotlight replacement that can do math and supports plugins.

### Terminal

- __Kitty:__ Available on each OS and architecture. Fast.
- __Tmux:__ Screen or Tmux, we use Tmux here... good terminal multiplexer.
- __Neovim:__ Vim + Lua + LSP. A great editor to invest in if you have a career in tech.
- __Zsh:__ Some great conveniences over bash, in particular working with history.

Structure
---------

```bash
/                         # repo root, git dotfiles, config file, readme, makefile
applications/             # application configurations (non dotfile configs)
assets/                   # miscellaneous system files and resources
  applications/           # small apps worth having that dont fit in submodules or ~/.shell/bin
  autostart/              # linux *.desktop autostart files applied with `make linux`
  dconf/                  # dconf configurations applied with `make linux`
  fonts/                  # fonts utilized by configurations
  keyboard/               # karabiner keyboard configurations
dotfiles/                 # contains actual dotfiles in templated form
scripts/                  # repo specific deployment scripts and utilities
```

Usage
-----

Take a look at the code and inline comments for a better understanding of the
configurations applied. `.config.example` is a good place to start as it calls
out a lot of specifics.

`git-cipher` is used to encrypt or decrypt the config file:

```bash
gem install git-cipher
brew install git gnupg gpg-agent
git cipher encrypt [FILES...]
git cipher decrypt [FILES...]
```

- You need to make the keychain entries manually for any mail servers you define.
- On newer versions of OSX, the OS binds Ctrl-Space to change input sources. This blocks tmux from picking up the prefix. Go into System Preferences -> Keyboard -> Keyboard Shortcuts -> Input Sources and uncheck both mappings.
- You need to tell Google Drive to stream by default but make the codex available offline for nvim to play nicely.
- You need to import the gpg key you define in the config.
- Currently you have to build isync manually because of bug with openssl3 (isync v 1.4.4 has a problem, 1.5.0 is good)
    - Then update calls to mbsync under mutt dotfiles to path to `/usr/local/bin/mbsync`
- Contacts on iCloud seems to be enabled by default, disable it if you are using Google or another service else new contacts may default to be stored in iCloud.
