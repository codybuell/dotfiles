"""""""""""""""
"             "
"     vis     "
"             "
"""""""""""""""

" bail if base16-vim is not installed
if !buell#helpers#PluginExists('vis')
  finish
endif

" remove unwanted mappings
unmap <space>swp
unmap <space>rwp
