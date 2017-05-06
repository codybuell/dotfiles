""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Tabline Configurations                                                       "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("+showtabline")
  " function to generate tab line by looping through open pages
  function! BuellTabLine() abort
    " prep for building the tabline
    let p = tabline#gutterpadding()                       " start with gutter padding
    let t = tabpagenr()                                   " get the current tab page number
    let lo = p
    let me = p
    let sh = p
    let sc = p

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

      " build full sized tabbar
      let lo .= '%' . tab . 'T'                            " set the tab page number (for mouse clicks)
      let lo .= (tab == t ? '%#ErrorMsg#' : '%#TabLine#')  " set hlgroup if active else default to TabLine hlgroup
      let lo .= ' ' . tab . ': '                           " tab number folled by a colon, i.e. 1:
      let lo .= pathshorten(tabpath . '/' . tabname)       " print the filename with abbreviated path
      let lo .= (bufmod ? ' +' : '')                       " mark tab as modified if necessary
      let lo .= ' '                                        " add a space
      let lo .= '%*'                                       " reset colors

      " build mid sized tabbar
      let me .= '%' . tab . 'T'                            " set the tab page number (for mouse clicks)
      let me .= (tab == t ? '%#ErrorMsg#' : '%#TabLine#')  " set hlgroup if active else default to TabLine hlgroup
      let me .= ' ' . tab . ': '                           " tab number folled by a colon, i.e. 1:
      if tab == t                                          " if we are on the curren tab then...
        let me .= pathshorten(tabpath . '/' . tabname)     " print the filename with abbreviated path
      else
        let me .= tabname
      endif
      let me .= (bufmod ? ' +' : '')                       " mark tab as modified if necessary
      let me .= ' '                                        " add a space
      let me .= '%*'                                       " reset colors

      " build compact tabbar
      let sh .= '%' . tab . 'T'                            " set the tab page number (for mouse clicks)
      let sh .= (tab == t ? '%#ErrorMsg#' : '%#TabLine#')  " set hlgroup if active else default to TabLine hlgroup
      let sh .= ' ' . tab . ': '                           " tab number folled by a colon, i.e. 1:
      if tab == t                                          " if we are on the curren tab then...
        let sh .= tabname
      else
        let sh .= strpart(tabname,0,4) . '...'
      endif
      let sh .= (bufmod ? ' +' : '')                       " mark tab as modified if necessary
      let sh .= ' '                                        " add a space
      let sh .= '%*'                                       " reset colors

      " build sub compact tabbar
      let sc .= '%' . tab . 'T'                            " set the tab page number (for mouse clicks)
      let sc .= (tab == t ? '%#ErrorMsg#' : '%#TabLine#')  " set hlgroup if active else default to TabLine hlgroup
      let sc .= ' ' . tab . ': '                           " tab number folled by a colon, i.e. 1:
      if tab == t                                          " if we are on the curren tab then...
        let sc .= tabname
      else
        let sc .= strpart(tabname,0,2) . '...'
      endif
      let sc .= (bufmod ? ' +' : '')                       " mark tab as modified if necessary
      let sc .= ' '                                        " add a space
      let sc .= '%*'                                       " reset colors
    endfor

    " tab bar ending
    let en  = '%T%#TabLineFill#%='
    let en .= (tabpagenr('$') > 1 ? '%999XX' : 'X')

    " get length of various tab bars and window
    let lengthfull    = len(lo) - 61
    let lengthmid     = len(me) - 61
    let lengthcompact = len(sh) - 61

    " determine tabbar to use
    if lengthfull < winwidth(0)
      let tabbar = lo . en
    elseif lengthmid < winwidth(0)
      let tabbar = me . en
    elseif lengthcompact < winwidth(0)
      let tabbar = sh . en
    else
      let tabbar = sc . en
    endif

    return tabbar
  endfunction

  set stal=1                                              " show tabline 0=never 1=if 2 or more 2=always
  set tabline=%!BuellTabLine()                            " use our custom tabline function
endif
