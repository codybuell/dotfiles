"""""""""""""
"           "
"   Loupe   "
"           "
"""""""""""""

" bail if loupe is not installed
if !buell#helpers#PluginExists('loupe')
  finish
endif

" dont center results
let g:LoupeCenterResults=0

nmap                        ,/                <Plug>(LoupeClearHighlight)
