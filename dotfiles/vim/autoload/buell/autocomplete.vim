""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Autocomplete Functions                                                       "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"
" Deoplete Init
"
" Startup deoplete completion.
" 
" @return null
"
let s:deoplete_init_done=0
function! buell#autocomplete#deoplete_init() abort
  " bail if deoplete is loaded, not installed,  or we are not in nvim
  if s:deoplete_init_done || !buell#helpers#PluginExists('deoplete.nvim') || (!has('nvim') && v:version < 800)
    return
  endif
  " flag deoplete as loaded
  let s:deoplete_init_done=1
  call deoplete#enable()
endfunction
