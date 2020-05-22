" in quickfix / location list buffers use l/r arrows to navigate histories
nnoremap <silent> <buffer> <Left>  :<C-U>call buell#quickfixed#older()<CR>
nnoremap <silent> <buffer> <Right> :<C-U>call buell#quickfixed#newer()<CR>
