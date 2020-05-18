"""""""""""""""""""""
"                   "
"   vim-obsession   "
"                   "
"""""""""""""""""""""

" bail if vim-obsession is not installed
if !buell#helpers#PluginExists('vim-obsession')
  finish
endif

" sessions (save, restore, pause)
nnoremap                    <localleader>ss   :Obsession ~/.vim/sessions/
nnoremap                    <localleader>sr   :so ~/.vim/sessions/
nnoremap                    <localleader>sp   :Obsession<CR>
