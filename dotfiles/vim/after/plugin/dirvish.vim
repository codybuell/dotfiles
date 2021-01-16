"""""""""""""""
"             "
"   Dirvish   "
"             "
"""""""""""""""

" bail if dirvish is not installed
if !buell#helpers#PluginExists('dirvish')
  finish
endif

augroup BuellDirvish
  autocmd!
  " overwrite default mapping of o to open in current window instead of split
  autocmd FileType dirvish silent! nnoremap <nowait><buffer><silent> o :<C-U>.call dirvish#open('edit', 0)<CR>
  "autocmd FileType dirvish setlocal colorcolumn=
  " overwrite ! to start shdo in dirvish buffers
  autocmd FileType dirvish silent! vnoremap <nowait><buffer> ! :<C-U>'<,'>Shdo 
  autocmd FileType dirvish silent! nnoremap <nowait><buffer> ! :<C-U>Shdo 
augroup END
