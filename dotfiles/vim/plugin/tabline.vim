""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Tabline Configurations                                                       "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("+showtabline")

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  "                                                                         "
  "  Generate Tab Text                                                      "
  "                                                                         "
  "  @args                                                                  "
  "    l_padding (str): padding to apply to lhs of tab bar                  "
  "    abbrev_inactive (bool): show full path of inactive tabs?             "
  "    abbrev_active (bool): show full path of active tab?                  "
  "    truncate (int): truncate filename to length                          "
  "                                                                         "
  "  @return tab bar                                                        "
  "                                                                         "
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  function! BuellGenTabText(l_padding, abbrev_inactive, abbrev_active, truncate) abort

    let l:t = tabpagenr()                                        " get the current tab page number
    let l:bar = a:l_padding                                      " start our tab bar with padding
    let l:str = a:l_padding                                      " string only bar for finding size

    " for each tab window
    for i in range(tabpagenr('$'))                               " '$' returns last tab number
      " gather window metadata
      let l:tab     = i + 1                                      " start counting from 1 rather than 0
      let l:buflist = tabpagebuflist(l:tab)                      " determine how many buffers in the tab
      let l:winnr   = tabpagewinnr(l:tab)                        " determine number of the current window in the tab     
      let l:bufnr   = l:buflist[l:winnr - 1]                     " get the open buffer number
      let l:bufname = bufname(l:bufnr)                           " get the buffers name, includes relative path
      let l:bufmod  = getbufvar(l:bufnr, "&mod")                 " determine if buffer is modified
      let l:buftype = getbufvar(l:bufnr, "current_syntax")       " get the syntax of the buffer
      if l:bufname == ''                                         " get path and filename
        if l:buftype == 'qf'
          let l:tabpath = ''
          let l:tabname = '[quickfix]'
        else
          let l:tabpath = ''
          let l:tabname = '[No Name]'
        endif
      else
        if l:buftype == 'help'
          let l:tabpath = '[help]'
        else
          let l:tabpath = fnamemodify(l:bufname, ':h')
        endif
        let l:tabname = fnamemodify(l:bufname, ':t')
      endif

      " build the tab entry
      let l:bar .= (l:tab == l:t ? '%#ErrorMsg#' : '%#TabLine#') " set hlgroup if active else default to TabLine hlgroup
      let l:bar .= '%' . l:tab . 'T'                             " set the tab page number (for mouse clicks)
      let l:bar .= ' ' . l:tab . ': '                            " tab number followed by a colon, i.e. 1:
      let l:str .= ' ' . l:tab . ': '                            " tab number followed by a colon, i.e. 1:
      if a:truncate
        let l:bar .= strpart(l:tabname,0,a:truncate) . '…'       " truncate filename down
        let l:str .= strpart(l:tabname,0,a:truncate) . '.'       " truncate filename down, only want to count it as single space
      elseif (l:tab == l:t && a:abbrev_active) || (l:tab != l:t && a:abbrev_inactive)
        let l:bar .= l:tabname                                   " print just the filename
        let l:str .= l:tabname                                   " print just the filename
      else
        let l:bar .= pathshorten(l:tabpath . '/' . l:tabname)    " print the filename with abbreviated path
        let l:str .= pathshorten(l:tabpath . '/' . l:tabname)    " print the filename with abbreviated path
      endif
      let l:bar .= (l:bufmod ? ' +' : '')                        " mark tab as modified if necessary
      let l:str .= (l:bufmod ? ' +' : '')                        " mark tab as modified if necessary
      let l:bar .= ' '                                           " add a space
      let l:str .= ' '                                           " add a space
      let l:bar .= '%*'                                          " reset colors
    endfor

    " tab bar ending
    " let l:bar .= '%T%#TabLineFill#%='
    " let l:bar .= (tabpagenr('$') > 1 ? '%999XX' : 'X')

    " calc length of bar
    let l:bar_len = len(l:str)

    return [l:bar_len, l:bar]

  endfunction

  " function to generate tab line by looping through open pages
  function! BuellTabLine() abort

    " set vars for the current state of affairs
    let l:gutter_width = buell#statusline#gutterwidth()
    let l:p = repeat(' ', gutter_width - 1)

    " hacky solution to deal with tab line lhs padding when entering lsp popups
    if get(w:, 'textDocument/hover')
      let l:p = '        '
      return ""
    endif
    if get(w:, 'line_diagnostics')
      let l:p = '        '
      return ""
    endif

    " try full size
    let l:bar = BuellGenTabText(l:p, 0, 0, 0)
    if l:bar[0] < &columns
      return l:bar[1]
    endif

    " try abbreviate only inactive tabs
    let l:bar = BuellGenTabText(l:p, 1, 0, 0)
    if l:bar[0] < &columns
      return l:bar[1]
    endif

    " try abbreviate all tabs
    let l:bar = BuellGenTabText(l:p, 1, 1, 0)
    if l:bar[0] < &columns
      return l:bar[1]
    endif

    " start truncating names at 10 chars and go down
    let l:truncate_to = 10
    while l:bar[0] > &columns
      let l:bar = BuellGenTabText(l:p, 1, 1, l:truncate_to)
      let l:truncate_to -= 1
    endwhile
    return l:bar[1]
  endfunction

  set stal=1                                              " show tabline 0=never 1=if 2 or more 2=always
  set tabline=%!BuellTabLine()                            " use our custom tabline function
endif
