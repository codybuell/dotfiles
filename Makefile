################################################################################
#                                                                              #
#  Helpers                                                                     #
#                                                                              #
################################################################################

# Work in bash as opposed to sh
SHELL := /bin/bash

# Turn all subsequent targets after some targets into arguments for command
FIRSTWORD=$(firstword $(MAKECMDGOALS))
ifeq ($(FIRSTWORD), $(filter $(FIRSTWORD), dots colortest))
  # use the remaining targets as arguments
  CMD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # and turn them into null / do-nothing targets
  $(eval $(CMD_ARGS):;@:)
endif

# Set ALL targets to be PHONY
.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))

# Text decoration helpers
B="$$(tput bold)"
UN="$$(tput smul)"
NU="$$(tput rmul)"
DIM="$$(tput dim)"

# Text color helpers
RED="$$(tput setaf 1)"
GRN="$$(tput setaf 2)"
YLW="$$(tput setaf 3)"
BLU="$$(tput setaf 4)"
MGT="$$(tput setaf 5)"
CYN="$$(tput setaf 6)"

# Color / decoration reset
NRM="$$(tput sgr0)"

################################################################################
#                                                                              #
#  Targets                                                                     #
#                                                                              #
################################################################################

default:
	@printf "\n\
	\
	  $(DIM)usage:$(NRM)        $(B)make <command>$(NRM)\n\n\
	\
	  $(DIM)commands:$(NRM)\n\n\
	\
	    $(B)$(DIM)REPOSITORY$(NRM)\n\n\
	\
	    $(B)$(GRN)subs$(NRM)            $(GRN)initialize and update git submodules$(NRM)\n\
	    $(B)$(GRN)update-themes$(NRM)   $(GRN)update the color theme submodules, place files$(NRM)\n\n\
	\
	    $(B)$(DIM)DEPLOYMENT$(NRM)\n\n\
	\
	    $(B)$(GRN)bootstrap$(NRM)       $(GRN)attempt to detect os and run all configurations$(NRM)\n\n\
	\
	    $(B)$(RED)clean$(NRM)           $(RED)delete all backups of previous dotfiles$(NRM)\n\n\
	\
	    $(B)$(BLU)paths$(NRM)           $(BLU)stub out paths as defined in .config$(NRM)\n\
	    $(B)$(BLU)symlinks$(NRM)        $(BLU)stub out symlinks as defined in .config$(NRM)\n\
	    $(B)$(BLU)repos$(NRM)           $(BLU)clone git repositories as defined in .config$(NRM)\n\
	    $(B)$(BLU)dots $(DIM)[dots]$(NRM)     $(BLU)place dotfiles for current user$(NRM)\n\
	    $(B)$(BLU)nix$(NRM)             $(BLU)install nix and nix managed packages$(NRM)\n\
	    $(B)$(BLU)mas$(NRM)             $(BLU)install mas and app store packages$(NRM)\n\
	    $(B)$(BLU)brew$(NRM)            $(BLU)install brew and brew managed packages$(NRM)\n\
	    $(B)$(BLU)node$(NRM)            $(BLU)install nvm, node, and npm managed packages$(NRM)\n\
	    $(B)$(BLU)gem$(NRM)             $(BLU)install required gem packages$(NRM)\n\
	    $(B)$(BLU)go$(NRM)              $(BLU)install required go packages$(NRM)\n\
	    $(B)$(BLU)pip$(NRM)             $(BLU)install required pip packages$(NRM)\n\
	    $(B)$(BLU)karabiner$(NRM)       $(BLU)install generate karabiner config and place$(NRM)\n\
	    $(B)$(BLU)osx$(NRM)             $(BLU)install brew and brew managed packages$(NRM)\n\
	    $(B)$(BLU)fonts$(NRM)           $(BLU)install fonts located in assets/fonts/*$(NRM)\n\
	    $(B)$(BLU)commands$(NRM)        $(BLU)run commands as defined in .config$(NRM)\n\n\
	\
	    $(B)$(DIM)TESTING$(NRM)\n\n\
	\
	    $(B)$(BLU)colortest$(NRM)       $(BLU)run color tests for the terminal and show codes\n\
	    $(B)$(BLU)zsh-test$(NRM)        $(BLU)build & start a container with zsh configuration\n\n"

################
#  Repository  #
################

subs:
	git submodule init
	git submodule update
	git submodule update --init

decrypt:
	git cipher decrypt dotfiles/ssh/.config.encrypted
	git cipher decrypt ..config.encrypted

encrypt:
	git cipher encrypt dotfiles/ssh/config
	git cipher encrypt .config

update-themes:
	@echo "Updating theme submodules..."
	git submodule update --init --remote -- vendor/tinted-*
	git submodule update --init --remote -- dotfiles/config/nvim/pack/bundle/opt/tinted-nvim
	@echo "Copying tinted-shell Zsh scripts..."
	mkdir -p dotfiles/zsh/colors/scripts
	cp -r vendor/tinted-shell/scripts/*.sh dotfiles/zsh/colors/scripts/
	@echo "Copying tinted-terminal Kitty configs..."
	mkdir -p dotfiles/config/kitty/colors
	cp -r vendor/tinted-terminal/themes/kitty/*.conf dotfiles/config/kitty/colors/
	@echo "Copying tinted-tmux Tmux configs..."
	mkdir -p dotfiles/config/tmux/colors
	cp -r vendor/tinted-tmux/colors/*.conf dotfiles/config/tmux/colors/

################
#  Deployment  #
################

bootstrap: subs paths symlinks repos dots nix mas brew node gem go pip karabiner osx fonts commands

clean:
	find ~/ -maxdepth 2 -name \*.dotorig.\* -prune -exec rm -rf {} \;

paths:
	@source scripts/library.sh && read_config && cd && run_paths

symlinks:
	@source scripts/library.sh && read_config && cd && run_links

repos:
	scripts/repos.sh

dots:
	scripts/dots.sh $(CMD_ARGS)

nix:
	scripts/nix.sh

mas:
	scripts/mas.sh

brew:
	scripts/brew.sh

node:
	scripts/node.sh

gem:
	scripts/gem.sh

go:
	scripts/go.sh

pip:
	scripts/pip.sh

karabiner:
	node scripts/karabiner.mjs --emit-karabiner-config > dotfiles/config/karabiner/karabiner.json
	scripts/dots.sh -f config/karabiner
	# launchctl stop org.pqrs.karabiner.karabiner_console_user_server
	# launchctl start org.pqrs.karabiner.karabiner_console_user_server

osx:
	scripts/osx.sh

fonts:
	scripts/fonts.sh

commands:
	@source scripts/library.sh && read_config && cd && run_commands

cron:
	@(crontab -l 2>/dev/null; echo "*/5 * * * * /Users/pbuell/.zsh/bin/repo_profiler.py") | crontab -

keychain:
	scripts/keychain.sh

#############
#  Testing  #
#############

colortest:
	@scripts/colortest $(CMD_ARGS)

zsh-test:
	@docker build -t zsh-test assets/docker/zsh-test
	@docker run -it --rm -v $$(pwd)/dotfiles/config:/root/.config -v $$(pwd)/dotfiles/zsh:/root/.zsh -v $$(pwd)/dotfiles/zshrc:/root/.zshrc zsh-test
