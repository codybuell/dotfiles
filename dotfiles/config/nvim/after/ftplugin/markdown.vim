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
    let prevline = getline(v:lnum-1)
    let thisline = getline(v:lnum)
    let nextline = getline(v:lnum+1)

    # Fenced Code Blocks
    if thisline =~ '^\s*```.\+$'
        " start of a fenced block
        return "a1"
    elseif thisline =~ '^\s*```\s*$'
        " end of a fenced block
        return "s1"
    endif

    # Headers
    if thisline =~ '^# ' && prevline =~ '^\s*$' && nextline =~ '^\s*$'
        " begin a fold of level one here
        return ">1"
    elseif thisline =~ '^## ' && prevline =~ '^\s*$' && nextline =~ '^\s*$'
        " begin a fold of level two here
        return ">2"
    elseif thisline =~ '^### ' && prevline =~ '^\s*$' && nextline =~ '^\s*$'
        " begin a fold of level three here
        return ">3"
    elseif thisline != '' && nextline =~ '^===*'
        " elseif the next line starts with at least two ==
        return ">1"
    elseif thisline != '' && nextline =~ '^---*'
        " elseif the line ends with at least two --
        return ">2"
    elseif foldlevel(v:lnum-1) != "-1"
        return foldlevel(v:lnum-1)
    else
        return "="
    endif
endfunction

"""""""""""
"  Setup  "
"""""""""""

setlocal foldmethod=expr
let &l:foldexpr = 'MarkdownFoldLevel()'

""""""""""""""
"  Teardown  "
""""""""""""""

if !exists("b:undo_ftplugin") | let b:undo_ftplugin = '' | endif
let b:undo_ftplugin .= '
  \ | setlocal foldmethod< foldtext< foldexpr<
  \ '
