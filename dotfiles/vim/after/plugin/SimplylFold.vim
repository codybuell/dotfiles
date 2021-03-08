"""""""""""""""""""
"                 "
"   SimplylFold   "
"                 "
"""""""""""""""""""

" bail if nerdtree is not installed
if !buell#helpers#PluginExists('SimplylFold')
  finish
endif

let g:SimpylFold_docstring_preview = 0
let g:SimpylFold_fold_docstring    = 1
let g:SimpylFold_fold_import       = 1
let g:SimpylFold_fold_blank        = 0
