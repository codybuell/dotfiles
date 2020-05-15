" Dev Vimrc
"
" A barebones vim config for developing vim plugins.  Provides 'out of the
" box' vim/nvim + the plugin under development for a clean environment without
" the need to replace your personal vim/nvim config.
"
" Usage:
"
"   VIMDEVPATH=/path/to/plugin vim -Nu ~/.devimrc.vim
"     -N resets compatible, needed for vim, nvim defaults nocompatible
"     -u use a custom vimrc
"   
"   VIMDEVPATH=/path/to/plugin nvim -u ~/.devimrc.vim
"     -u use a custom vimrc

" unset normal vim user runtimepath
set rtp-=~/.vim
set rtp-=~/.vim/after

" unset normal nvim user runtimepath
set rtp-=~/.config/nvim
set rtp-=~/.config/nvim/after

" other bits in the runtimepath generated such as *vim/bundles/* aren't a
" concern as they are set in your normal vimrc / init.vim, not here

" add plugin to the runtimepath, root of plugin to start of rtp, after to end
set rtp^=$VIMDEVPATH
set rtp+=$VIMDEVPATH/after

" don't read in viminfo file as it may interfere, shadafile is nvim equivalent
set vif=NONE
set sdf=NONE

" don't set guicursor as it sends excape sequences to set shape of cursor that
" may muck with the terminal in a weird way when testing
set gcr=

" turn on filetype scripts (plugin), indent scripts (indent)
filetype plugin indent on

" turn on syntax
syntax enable

" mapping to quickly reload, leader defaults to \
nnoremap  <leader>so  :so $HOME/.devimrc.vim<cr>
