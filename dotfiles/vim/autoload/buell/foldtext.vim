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
    if &signcolumn =~ 'auto'
      redir =>a |exe "sil sign place buffer=".bufnr('')|redir end
      let signlist=split(a, '\n')
      let l:signColumn=(len(signlist) > 2 ? 2 : 0)
    elseif &signcolumn !~ 'no'
      let l:signColumn=(&signcolumn == 'yes') ? 2 : 0
    endif

    " check if numbercolumn is showing
    if &nu || &rnu
      let l:ncw = max([strlen(line('$')) + 1, &numberwidth])
    else
      let l:ncw = 0
    endif
    " define the available width for foldbar
    let w = winwidth(0) - &foldcolumn - l:ncw - l:signColumn
    let foldSize = 1 + v:foldend - v:foldstart
    let foldSizeStr = " " . foldSize . " lines "
    let foldLevelStr = repeat(" ", indent(line))
    let lineCount = line("$")
    let foldPercentage = printf("[%.1f%%] ", (foldSize*1.0)/lineCount*100)
    let foldColonCount = printf("%.0f", round(((foldSize*1.0)/lineCount) * 15))
    let foldSizeSparkline = "[" . repeat(":", foldColonCount) . repeat(".", 15 - foldColonCount) . "] "
    let expansionString = repeat(".", w - strwidth(foldSizeStr.line.foldLevelStr.foldSizeSparkline))
    return foldLevelStr . line . expansionString . foldSizeStr . foldSizeSparkline
endfunction
