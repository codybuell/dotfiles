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

function! MarkdownFoldHeadersFrontmatter()
  let line  = getline(v:lnum)
  let lines = getline(v:lnum-1, v:lnum+1)

  " determine if frontmatter exist in the doc
  if getline(1) == '---'
    let frontmatter = 1
  else
    let frontmatter = 0
  endif

  " if we're on line 1 and frontmatter was found start fold
  if (v:lnum == 1) && (frontmatter == 1)
    return ">1"
  endif

  " if frontmatter found determine if we're within it
  if frontmatter == 1
    " find the closing frontmatter ---
    let origPos = getpos('.')
    let ok = cursor(1, 1)
    let frontmatterEnd = search('---', '', line("w$"))

    " return cursor to the original position
    let ok = cursor(origPos[1], origPos[2])

    " if fm closure is found and it's below our position keep fold level
    if frontmatterEnd > 0 && frontmatterEnd > v:lnum
      return "="
    " if we're on the fm closure indicate the end of the fold
    elseif frontmatterEnd == v:lnum
      return "<1"
    " if the fm closure was just above us start a no fold section
    elseif frontmatterEnd == (v:lnum - 1)
      return "0"
    endif
  endif

  " h2 fold
  if lines[1] =~ '^## .*$' && lines[0] =~ '^\s*$' && lines[2] =~ '^\s*$'
    " begin a fold of level two here
    return ">1"

  " h3 fold
  elseif lines[1] =~ '^### .*$' && lines[0] =~ '^\s*$' && lines[2] =~ '^\s*$'
    " begin a fold of level three here
    return ">2"

  " h2 fold with underscores (2 or more dashes for underscores)
  elseif lines[1] != '' && lines[2] =~ '^---*$' && getline(v:lnum+2) == ''
    return ">1"

  " ensure h1 headers are not folded
  elseif lines =~ '^# .*$' || (lines[1] != '' && lines[2] =~ '^===*$')
    return "0"

  elseif foldlevel(v:lnum-1) != "-1"
    return foldlevel(v:lnum-1)
  endif

  return "="

endfunction

"""""""""""
"  Setup  "
"""""""""""

setlocal foldmethod=expr
let &l:foldexpr = 'MarkdownFoldHeadersFrontmatter()'
" let &l:foldexpr = "%!luaeval('buell.markdown.markdown_fold_level()')"

""""""""""""""
"  Teardown  "
""""""""""""""

if !exists("b:undo_ftplugin") | let b:undo_ftplugin = '' | endif
let b:undo_ftplugin .= '
  \ | setlocal foldmethod< foldtext< foldexpr<
  \ '
