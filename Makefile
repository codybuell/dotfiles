# turn all subsequent targets after dots into arguments for dots
ifeq (dots,$(firstword $(MAKECMDGOALS)))
  # use the remaining targets as arguments for "dots"
  DOTS_RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # and turn them into null / do-nothing targets
  $(eval $(DOTS_RUN_ARGS):;@:)
endif

default:
	@printf "usage: make [ full | \033[0;31mosx\033[0m | \033[0;31mlinux\033[0m | \033[0;31mcygwin\033[0m | osxdefs | linuxdefs | dots | brew | karabiner | subs ] [ \033[0;31mclean\033[0m ]\n\n\
	    full:      attempt to detect os and run all configs\n\
	    subs:      grab and update all git submodules\n\
	    brew:      run brew configuration\n\
	    dots:      place dotfiles for current user\n\
	    osx:       run osx os configurations\n\
	    linux:     run linux os configurations\n\
	    composer:  run composer configuration\n\
	    gem:       run gem configuration\n\
	    go:        run go configuration\n\
	    node:      run node configuration\n\
	    pip:       run pip configuration\n\
	    clean:     delete all backup files\n\n"

#default: subs [brew] [osconfigs] dots etc... run it all and detect env

full:
	scripts/full.sh

osx:
	scripts/osx.sh

linux:
	scripts/linux.sh

dots:
	scripts/connect-the-dots.sh $(DOTS_RUN_ARGS)

brew:
	scripts/brew.sh

composer:
	scripts/composer.sh

gem:
	scripts/gem.sh

go:
	scripts/go.sh

node:
	scripts/node.sh

pip:
	scripts/pip.sh

subs:
	git submodule init
	git submodule update
	git submodule update --init

clean:
	find ~/ -maxdepth 1 -name \*.orig.\* -prune -exec rm -rf {} \;
