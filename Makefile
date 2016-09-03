default:
	@printf "usage: make [ \033[0;31mosx\033[0m | \033[0;31mlinux\033[0m | osxdefs | linuxdefs | dots | brew | karabiner ] [ \033[0;31mclean\033[0m ]\n\n\
	    osx:       run all configurations (osx specific)\n\
	    linux:     run all configurations (linux specific)\n\
	    osxdefs:   run osx configurations\n\
	    linuxdefs: run linux configurations\n\
	    dots:      place dotfiles for current user\n\
	    brew:      run brew configuration\n\
	    keyboard:  place kareabiner config files\n\
	    clean:     delete all backup files\n\n"

osx: osxdefs brew dots karabiner

linux: linuxdefs dots

osxdefs:
	scripts/osx.sh

linuxdefs:
	scripts/linux.sh

dots:
	scripts/connect-the-dots.sh

brew:
	scripts/brew.sh

karabiner:
	scripts/karabiner.sh

clean:
	find ~/ -depth 1 -name \*.orig.\* -prune -exec rm -rf {} \;
