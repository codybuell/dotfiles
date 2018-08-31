# turn all subsequent targets after dots into arguments for dots
ifeq (dots,$(firstword $(MAKECMDGOALS)))
  # use the remaining targets as arguments for "dots"
  DOTS_RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # and turn them into null / do-nothing targets
  $(eval $(DOTS_RUN_ARGS):;@:)
endif

default:
	@printf "\n\
	\
	  usage:      \033[1;37mmake [ command ]\033[0m\n\n\
	\
	  commands:\n\n\
	\
	    \033[1;33mtest\033[0;33m      test to see if your env can be detected\033[0m\n\
	    \033[1;33mconfig\033[0;33m    utility to help generate the repository config file\033[0m\n\
	    \033[1;33msubs\033[0;33m      pull and or update all repository git submodules\033[0m\n\n\
	\
	    \033[1;32mfull\033[0;32m      attempt to detect os and run all configurations\033[0m\n\n\
	\
	    \033[1;34mrepos\033[0;34m     clone repositories listed in the config file\033[0m\n\
	    \033[1;34mpaths\033[0;34m     create all needed paths and symlinks\033[0m\n\
	    \033[1;34mbrew\033[0;34m      run brew installations\033[0m\n\
	    \033[1;34mgo\033[0;34m        run go configuration\033[0m\n\
	    \033[1;34mpip\033[0;34m       run pip configuration\033[0m\n\
	    \033[1;34mgem\033[0;34m       run gem configuration\033[0m\n\
	    \033[1;34mnode\033[0;34m      run node configuration\033[0m\n\
	    \033[1;34mcomposer\033[0;34m  run composer configuration\033[0m\n\
	    \033[1;34mdots\033[0;34m      place dotfiles for current user\033[0m\n\
	    \033[1;34mosx\033[0;34m       run osx configurations\033[0m\n\
	    \033[1;34mlinux\033[0;34m     run linux os configurations\033[0m\n\n\
	\
	    \033[1;31mclean\033[0;31m     delete all backups of previous dotfiles\033[0m\n\n"

test:
	scripts/test.sh

config:
	scripts/config.sh

subs:
	git submodule init
	git submodule update
	git submodule update --init

repos:
	scripts/repos.sh

paths:
	scripts/paths.sh

brew:
	scripts/brew.sh

go:
	scripts/go.sh

pip:
	scripts/pip.sh

gem:
	scripts/gem.sh

node:
	scripts/node.sh

composer:
	scripts/composer.sh

dots:
	scripts/dots.sh $(DOTS_RUN_ARGS)

osx:
	scripts/osx.sh

linux:
	scripts/linux.sh

clean:
	find ~/ -maxdepth 1 -name \*.dotorig.\* -prune -exec rm -rf {} \;
