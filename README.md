Dotfiles
========

Personal scripts, configurations, and dotfiles to bootstrap a new system.
Attempts to be idempotent, configurable, and composable while requiring as
little pre-configuration as possible. A rough outline of this repository is
below, refer to inline comments / documentation for more details.

Setup
-----

Assuming a fresh system requiring all dependencies and configurations:
```bash
# on osx grant the terminal full disk access:
#
#   system preferences -> security & privacy -> privacy -> full disk access
#
git clone https://github.com/codybuell/dotfiles && cd dotfiles
cp .config.example .config; vi .config      # edit configuration as needed
make bootstrap                              # full install / configuration
```
There are several make targets that can be run sequentially in lieu of `make
bootstrap` or independently as needed. They are ordered below as run by `make
bootstrap`, which is determined by dependencies.
```bash
make subs       # pull in all git repository submodules
make dots       # places dotfiles, depends on repo `.config` file
make nix        # installs nix and packages, depends on `make dots`
make mas        # installs App Store apps, depends on `make nix`
make brew       # installs brew packages, casks, services
make node       # installs NVM, latest lts of Node, and global node packages
make gem        # installs ruby gems needed for nvim support etc
make pip        # installs pip packages needed for nvim support etc
make karabiner  # compiles and places config, restarts service, depends on node
make osx        # applies as many OSX configurations as possible via cli
```
The `make dots` target is generally the most heavily used. This is because
dotfiles are not symlinked back to this repository, so any changes made to
configurations must be placed into production. To reduce the lift the `make
dots` endpoint takes any number of arguments, being the dotfiles or dotfolders
you wish to place.
```bash
make dots vim              # will place the dotfiles/vim folder to ~/.vim
make dots tmux.conf tmux   # can take any number of arguments
make dots config/karabiner # also handles explicitly calling out a sub path
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
/                   # repo root, git dotfiles, config file, readme, makefile
applications/       # application configurations (non dotfile configs)
assets/             # miscellaneous system files and resources
  applications/     # small apps worth having that dont fit in submodules or ~/.shell/bin
  autostart/        # linux *.desktop autostart files applied with `make linux`
  dconf/            # dconf configurations applied with `make linux`
  fonts/            # fonts utilized by configurations
  keyboard/         # karabiner keyboard configurations
dotfiles/           # contains actual dotfiles in templated form
scripts/            # repo specific deployment scripts and utilities
submodules/         # repository submodules (external repos utilized by configurations)
```
