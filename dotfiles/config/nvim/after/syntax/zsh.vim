" Clear existing zsh syntax highlighting
syntax clear

" Include sh syntax rules
syntax include @SHELL syntax/sh.vim

" Apply sh syntax to the current buffer
syntax region zshScript matchgroup=NONE start="^" end="$" contains=@SHELL
