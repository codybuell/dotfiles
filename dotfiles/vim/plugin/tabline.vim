""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Tabline Configurations                                                       "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("+showtabline")
  " function to generate tab line by looping through open pages
  function! BuellTabLine() abort
    " prep for building the tabline
    let s = tabline#gutterpadding()                       " start with gutter padding
    let t = tabpagenr()                                   " get the current tab page number

    " loop through each tab page
    for i in range(tabpagenr('$'))                        " '$' returns last tab number
      let tab     = i + 1                                 " start counting from 1 rather than 0
      let buflist = tabpagebuflist(tab)                   " determine how many buffers in the tab
      let winnr   = tabpagewinnr(tab)                     " determine number of the current window in the tab
      let bufnr   = buflist[winnr - 1]                    " get the open buffer number
      let bufname = bufname(bufnr)                        " get the buffers name, includes relative path
      let bufmod  = getbufvar(bufnr, "&mod")              " determine if buffer is modified
      if bufname == ''
        let tabpath = ''
        let tabname = '[ no name ]'
      else
        let tabpath = fnamemodify(bufname, ':h')
        let tabname = fnamemodify(bufname, ':t')
      endif

      let s .= '%' . tab . 'T'                            " set the tab page number (for mouse clicks)
      let s .= (tab == t ? '%#ErrorMsg#' : '%#TabLine#')  " set hlgroup if active else default to TabLine hlgroup
      let s .= ' ' . tab . ': '                           " tab number folled by a colon, i.e. 1:
      let s .= pathshorten(tabpath . '/' . tabname)       " print the filename with abbreviated path
      let s .= ' '                                        " add a space
      let s .= '%*'                                       " reset colors
    endfor

    " append onto the end of the tabs
    let s .= '%T%#TabLineFill#%='
    let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
    return s
  endfunction

  set stal=1                                              " show tabline 0=never 1=if 2 or more 2=always
  set tabline=%!BuellTabLine()                            " use our custom tabline function
endif
