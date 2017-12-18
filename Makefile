# turn all subsequent targets after dots into arguments for dots
ifeq (dots,$(firstword $(MAKECMDGOALS)))
  # use the remaining targets as arguments for "dots"
  DOTS_RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # and turn them into null / do-nothing targets
  $(eval $(DOTS_RUN_ARGS):;@:)
endif

default:
	@printf "usage: make [ \033[0;31mosx\033[0m | \033[0;31mlinux\033[0m | \033[0;31mcygwin\033[0m | osxdefs | linuxdefs | dots | brew | karabiner | subs ] [ \033[0;31mclean\033[0m ]\n\n\
	    osx:       run all configurations (osx specific)\n\
	    linux:     run all configurations (linux specific)\n\
	    cygwin:    run all configurations (cygwin specific)\n\
	    osxdefs:   run osx configurations\n\
	    linuxdefs: run linux configurations\n\
	    dots:      place dotfiles for current user\n\
	    brew:      run brew configuration\n\
	    keyboard:  place kareabiner config files\n\
	    subs:      grab and update all git submodules\n\
	    clean:     delete all backup files\n\n"

osx: subs osxdefs brew dots karabiner

linux: subs linuxdefs dots

cygwin: subs dots

osxdefs:
	scripts/osx.sh

linuxdefs:
	scripts/linux.sh

run:
	echo 

dots:
	scripts/connect-the-dots.sh $(DOTS_RUN_ARGS)

brew:
	scripts/brew.sh

karabiner:
	scripts/karabiner.sh

subs:
	git submodule init
	git submodule update

clean:
	find ~/ -depth 1 -name \*.orig.\* -prune -exec rm -rf {} \;
