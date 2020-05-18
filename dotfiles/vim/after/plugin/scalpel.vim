"""""""""""""""
"             "
"   Scalpel   "
"             "
"""""""""""""""

" bail if scalpel is not installed
if !buell#helpers#PluginExists('scalpel')
  finish
endif

" some settings reside in init.vim due to load order reqs

nmap                        <leader>s         <Plug>(Scalpel)
