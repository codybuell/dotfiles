"""""""""""""""""""""
"                   "
"   vim-camelsnek   "
"                   "
"""""""""""""""""""""

" bail if vim-camelsnek is not installed
if !buell#helpers#PluginExists('vim-camelsnek')
  finish
endif

nnoremap  <silent>          <localleader>cs   :Snek<CR>
nnoremap  <silent>          <localleader>cc   :Camel<CR>
nnoremap  <silent>          <localleader>cb   :CamelB<CR>
nnoremap  <silent>          <localleader>ck   :Kebab<CR>

vmap      <silent>          <localleader>cs   :'<,'>Snek<CR>
vmap      <silent>          <localleader>cc   :'<,'>Camel<CR>
vmap      <silent>          <localleader>cb   :'<,'>CamelB<CR>
vmap      <silent>          <localleader>ck   :'<,'>Kebab<CR>
