################################################################################
#                                                                              #
#  Helpers                                                                     #
#                                                                              #
################################################################################

# turn all subsequent targets after some targets into arguments for command
FIRSTWORD=$(firstword $(MAKECMDGOALS))
ifeq ($(FIRSTWORD), $(filter $(FIRSTWORD), dots))
  # use the remaining targets as arguments
  CMD_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # and turn them into null / do-nothing targets
  $(eval $(CMD_ARGS):;@:)
endif

# set ALL targets to be PHONY
.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))

# text decoration helpers
B="$$(tput bold)"
UN="$$(tput smul)"
NU="$$(tput rmul)"
DIM="$$(tput dim)"

# text color helpers
RED="$$(tput setaf 1)"
GRN="$$(tput setaf 2)"
YLW="$$(tput setaf 3)"
BLU="$$(tput setaf 4)"
MGT="$$(tput setaf 5)"
CYN="$$(tput setaf 6)"

# color / decoration reset
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
	    $(B)$(GRN)bootstrap$(NRM)   $(DIM)$(GRN)attempt to detect os and run all configurations$(NRM)\n\n\
	\
	    $(B)$(YLW)subs$(NRM)        $(DIM)$(YLW)pull and or update all repository git submodules$(NRM)\n\n\
	\
	    $(B)$(BLU)dots$(NRM)        $(DIM)$(BLU)place dotfiles for current user$(NRM)\n\
	    $(B)$(BLU)nix$(NRM)         $(DIM)$(BLU)install nix and nix managed packages$(NRM)\n\
	    $(B)$(BLU)mas$(NRM)         $(DIM)$(BLU)install mas and app store packages$(NRM)\n\
	    $(B)$(BLU)brew$(NRM)        $(DIM)$(BLU)install brew and brew managed packages$(NRM)\n\
	    $(B)$(BLU)node$(NRM)        $(DIM)$(BLU)install nvm, node, and npm managed packages$(NRM)\n\
	    $(B)$(BLU)gem$(NRM)         $(DIM)$(BLU)install required gem packages$(NRM)\n\
	    $(B)$(BLU)pip$(NRM)         $(DIM)$(BLU)install required pip packages$(NRM)\n\
	    $(B)$(BLU)karabiner$(NRM)   $(DIM)$(BLU)install generate karabiner config and place$(NRM)\n\
	    $(B)$(BLU)osx$(NRM)         $(DIM)$(BLU)install brew and brew managed packages$(NRM)\n\n\
	\
	    $(B)$(RED)clean$(NRM)       $(DIM)$(RED)delete all backups of previous dotfiles$(NRM)\n\n"

bootstrap: subs dots nix mas brew node karabiner osx

subs:
	git submodule init
	git submodule update
	git submodule update --init

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

pip:
	scripts/pip.sh

karabiner:
	node scripts/karabiner.mjs --emit-karabiner-config > dotfiles/config/karabiner/karabiner.json
	scripts/dots.sh config/karabiner
	launchctl stop org.pqrs.karabiner.karabiner_console_user_server
	launchctl start org.pqrs.karabiner.karabiner_console_user_server

osx:
	scripts/osx.sh

clean:
	find ~/ -maxdepth 2 -name \*.dotorig.\* -prune -exec rm -rf {} \;

# TODO: implement
# test:
# 	scripts/test.sh
# config:
# 	scripts/config.sh
# repos:
# 	scripts/repos.sh
# paths:
# 	scripts/paths.sh
# symlinks:
# 	scripts/symlinks.sh
# go:
# 	scripts/go.sh
# composer:
# 	scripts/composer.sh
# fonts:
# 	scripts/fonts.sh
# iterm:
# 	scripts/iterm.sh
# linux:
# 	scripts/linux.sh
