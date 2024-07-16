""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Autoload Tabline Functions                                                   "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#tabline#gutterpadding() abort
  let l:gutterWidth=max([strlen(line('$')), &numberwidth])
  " determine if there are any placed signs in the current buffer
  redir => signlist
    silent! execute 'sign place buffer='. bufnr('%')
  redir END
  let l:signColumn=(len(signlist) > 17) ? 2 : 0
  let l:padding=repeat(' ', l:gutterWidth + &foldcolumn + l:signColumn)
  return l:padding
endfunction
