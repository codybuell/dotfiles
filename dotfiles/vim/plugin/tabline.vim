""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Tabline Configurations                                                       "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("+showtabline")
  function MyTabLine()
    let s = ''
    let t = tabpagenr()
    let i = 1
    while i <= tabpagenr('$')
      let buflist = tabpagebuflist(i)
      let winnr = tabpagewinnr(i)
      let s .= '%' . i . 'T'
      let s .= (i == t ? '%1*' : '%2*')
      let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
      "let s .= i . ')'       " 1)
      let s .= ' '
      let s .= i . ': '       " 1:
      let file = bufname(buflist[winnr - 1])
      let file = fnamemodify(file, ':p:t')
      if file == ''
        let file = '[ no name ]'
      endif
      let s .= file
      let s .= ' '
      let s .= '%*'
      let i = i + 1
    endwhile
    let s .= '%T%#TabLineFill#%='
    let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
    return s
  endfunction
  "set stal=1                   " show tabline 0=never 1=if 2 or more 2=always
  "set tabline=%!MyTabLine()    " override tabline with custom function
endif
