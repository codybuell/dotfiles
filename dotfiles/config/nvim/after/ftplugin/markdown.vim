" TODO: - port to lua

" handle list wrap indentation, this works if set here, does not work if set
" in the equivalent lua config, may be because this file exists?
setlocal formatlistpat=^\\s*-\\s\\[.]\\s*\\\|^\\s*\\d\\+\\.\\s\\+\\\|^\\s*[-*+]\\s\\+\\\|^\\[^\\ze[^\\]]\\+\\]:\\&^.\\{4\\}
setlocal breakindent
setlocal breakindentopt=list:-1,shift:2,sbr

""""""""""""""""""""""
"  Fold Expressions  "
""""""""""""""""""""""

function! MarkdownFoldLevel()
    let lines = getline(v:lnum-1, v:lnum+1)

    " " Fenced Code Blocks
    " if lines[1] =~ '^\s*```.\+$'
    "     " start of a fenced block
    "     return "a1"
    " elseif lines[1] =~ '^\s*```\s*$'
    "     " end of a fenced block
    "     return "s1"
    " endif

    " Headers (fold h2 on)
    if lines[1] =~ '^## .*$' && lines[0] =~ '^\s*$' && lines[2] =~ '^\s*$'
        " begin a fold of level two here
        return ">1"
    elseif lines[1] =~ '^### .*$' && lines[0] =~ '^\s*$' && lines[2] =~ '^\s*$'
        " begin a fold of level three here
        return ">2"
    elseif lines[1] != '' && lines[2] =~ '^---*$'
        " elseif the line ends with at least two --
        return ">1"
    elseif foldlevel(v:lnum-1) != "-1"
        return foldlevel(v:lnum-1)
    " this as an absolute last resort! without the above condition this func
    " gets recursively called some 66K times vs 1K times... 3 sec vs 0.03 sec
    " save time difference
    else
        return "="
    endif
endfunction

"""""""""""
"  Setup  "
"""""""""""

setlocal foldmethod=expr
let &l:foldexpr = 'MarkdownFoldLevel()'
" let &l:foldexpr = "%!luaeval('buell.markdown.markdown_fold_level()')"

""""""""""""""
"  Teardown  "
""""""""""""""

if !exists("b:undo_ftplugin") | let b:undo_ftplugin = '' | endif
let b:undo_ftplugin .= '
  \ | setlocal foldmethod< foldtext< foldexpr<
  \ '
