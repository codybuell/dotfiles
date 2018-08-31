""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Custom Fold Text                                                             "
"                                                                              "
" Define custom text for folds. See plugin/autocommands.vim.                   "
"                                                                              "
" @return string                                                               "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#foldtext#CustomFoldText() abort
    " get first non-blank line
    let fs = v:foldstart
    while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
    endwhile
    if fs > v:foldend
        let line = getline(v:foldstart) . " "
    else
        let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g') . " "
    endif
    " check if signs are showing
    redir =>a |exe "sil sign place buffer=".bufnr('')|redir end
    let signlist=split(a, '\n')
    " check if numbercolumn is showing
    if &nu
      let ncw = &numberwidth
    else
      let ncw = 0
    endif
    " define the available width for foldbar
    let w = winwidth(0) - &foldcolumn - ncw - (len(signlist) > 2 ? 2 : 0)
    let foldSize = 1 + v:foldend - v:foldstart
    let foldSizeStr = " " . foldSize . " lines "
    let foldLevelStr = repeat(" ", indent(line))
    let lineCount = line("$")
    let foldPercentage = printf("[%.1f", (foldSize*1.0)/lineCount*100) . "%] "
    let expansionString = repeat(".", w - strwidth(foldSizeStr.line.foldLevelStr.foldPercentage))
    return foldLevelStr . line . expansionString . foldSizeStr . foldPercentage
endfunction
