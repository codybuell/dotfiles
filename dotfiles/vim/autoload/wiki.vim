""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Wiki Autoload Functions                                                      "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Match String at Cursor
"
" Returns back the regex match at the current cursor position, an empty string
" if no match found.
"
" @param {string} regex to match against
" @return {string} 
function! wiki#matchStrAtCursor(regex) abort

  let col  = col('.') - 1                            " get cursors horiz position
  let line = getline('.')                            " get all text current line
  let ebeg = -1                                      " expression beginning
  let cont = match(line, a:regex, 0)                 " get index of first regex match

  " loop through regex matches on line, see if cursor is within its bounds
  while (ebeg >= 0 || (0 <= cont) && (cont <= col))
    let contn = matchend(line, a:regex, cont)        " get end of current match
    if (cont <= col) && (col < contn)                " if cursor is within match
      let ebeg = match(line, a:regex, cont)          " expression beginning
      let elen = contn - ebeg                        " expression length
      break                                          " exit loop
    else
      let cont = match(line, a:regex, contn)         " move onto next match
    endif
  endwh

  if ebeg >= 0
    return strpart(line, ebeg, elen)                 " return match
  else
    return ""
  endif

endfunction


function! wiki#makeLinkAtCursor() abort

endfunction

" Create or Follow a Wiki Link
function! wiki#CreateFollowWikiLink() abort

  " check for links at cursor
  let link = wiki#matchStrAtCursor(g:wikiPageLink)
  let type = 'page'

  if lnk == ""
    let link = wiki#matchStrAtCursor(g:wikiSectionLink)
    let type = 'section'
  endif

  if lnk == ""
    let link = wiki#matchStrAtCursor(g:wikiWebURLLink)
    let type = 'web'
  endif

  if lnk == ""
    let link = wiki#matchStrAtCursor(g:wikiWikiLink)
    let type = 'wiki'
  endif

  " if text is a link follow it
  if link != ""

    " get the target
    let target = substitute(link, '.*(\([^)]*\).*', '\1', '')

    if type == 'page'
      execute "edit " . fnameescape(curwikipath) . "/" . target . ".txt"
    elseif type == 'section'

    elseif type == 'web'

    elseif type == 'wiki'
      wiki = 
      execute "edit " . fnameescape(curwikipath) . "/" . target . ".txt"
    endif

  " else make it a link in standard format
  else
  endif

endfunction

