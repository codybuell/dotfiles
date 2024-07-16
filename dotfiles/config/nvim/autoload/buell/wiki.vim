""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Wiki Functions                                                               "
"                                                                              "
" Functionality depends on vim-markdown plugin by plasticboy.                  "
"                                                                              "
" related files:                                                               "
"    plugins/wiki.vim                                                          "
"    ftplugin/markdown.vim                                                     "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Match String at Cursor                                                       "
"                                                                              "
" Returns back the regex match at the current cursor position, an empty        "
" string if no match found.                                                    "
"                                                                              "
" @param {string} regex to match against                                       "
" @return {string}                                                             "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#wiki#matchStrAtCursor(regex) abort

  let l:col  = col('.') - 1                         " get cursors horiz position
  let l:line = getline('.')                         " get all text current line
  let l:ebeg = -1                                   " expression beginning
  let l:cont = match(l:line, a:regex, 0)            " get index of first regex match
  let l:len  = strwidth(l:line)                     " curent line length

  " bail if line is empty
  if l:len == 0
    return ""
  endif

  " loop through regex matches on line, see if cursor is within its bounds
  while (l:ebeg >= 0 || (0 <= l:cont) && (l:cont <= l:col))
    let l:contn = matchend(l:line, a:regex, l:cont) " get end of current match
    if (l:cont <= l:col) && (l:col < l:contn)       " if cursor is within match
      let l:ebeg = match(l:line, a:regex, l:cont)   " expression beginning
      let l:elen = l:contn - l:ebeg                 " expression length
      break                                         " exit loop
    else
      let l:cont = match(l:line, a:regex, l:contn)  " move onto next match
    endif
  endwh

  if l:ebeg >= 0
    return strpart(l:line, l:ebeg, l:elen)          " return match
  else
    return ""
  endif

endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Make Link at Cursor                                                          "
"                                                                              "
" Turn the string under the cursor into a markdown formatted link.             "
"                                                                              "
" @param {string} link                                                         "
" @return {string}                                                             "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#wiki#makeLinkAtCursor(link) abort

  " set link and trim off cruft from the link (punctuation)
  let l:link = substitute(a:link, "[,.]$", "", "")

  " set text (if url strip off the protocol?)
  let l:text = substitute(l:link, "http[s]\\?://", "", "")

  " handle text slashes
  let l:text = substitute(l:text, "/", "\\\\/", "g")

  " handle link slashes
  let l:link = substitute(l:link, "/", "\\\\/", "g")

  " lowercase the link
  let l:link = tolower(l:link)

  " match cleaned up link, get the beginning position and length so we can do an exact replacement
  let l:col  = col('.') - 1                         " get cursors horiz position
  let l:line = getline('.')                         " get all text current line
  let l:ebeg = -1                                   " expression beginning
  let l:cont = match(l:line, l:link, 0)             " get index of first regex match
  let l:ret  = col('.') + 1                         " where to return cursor after replace

  " loop through regex matches on line, see if cursor is within its bounds
  while (l:ebeg >= 0 || (0 <= l:cont) && (l:cont <= l:col))
    let l:contn = matchend(l:line, l:link, l:cont) " get end of current match
    if (l:cont <= l:col) && (l:col < l:contn)       " if cursor is within match
      let l:ebeg = match(l:line, l:link, l:cont)   " expression beginning
      let l:elen = l:contn - l:ebeg                 " expression length
      break                                         " exit loop
    else
      let l:cont = match(l:line, l:link, l:contn)  " move onto next match
    endif
  endwh

  " define start and end of string to replace
  let l:start = l:ebeg + 1
  let l:eend  = l:start + l:elen

  " perform substitution
  execute ":s/\\%" . l:start . "c.*\\%" . l:eend . "c/[" . l:text . "](" . l:link . ")/"

  " put cursor back where it was
  call cursor(0,l:ret)

endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Create or Follow a Wiki Link                                                 "
"                                                                              "
" Wrapper function to determine what to do when trying to follow a link.       "
"                                                                              "
" @return {string}                                                             "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! buell#wiki#createFollowWikiLink() abort

  " check for web url links at cursor
  let l:link = buell#wiki#matchStrAtCursor(g:mdWikiWebURLLink)
  let l:type = 'web'

  " if link is still not set check for wiki section link
  if l:link == ""
    let l:link = buell#wiki#matchStrAtCursor(g:mdWikiSectionLink)
    let l:type = 'section'
  endif

  " if link is still not set check for wiki link
  if l:link == ""
    let l:link = buell#wiki#matchStrAtCursor(g:mdWikiWikiLink)
    let l:type = 'wiki'
  endif

  " if link is still not set check for wiki file link, run before page check
  if l:link == ""
    let l:link = buell#wiki#matchStrAtCursor(g:mdWikiFileLink)
    let l:type = 'file'
  endif

  " if link is still not set check for wiki page link, run after file check
  if l:link == ""
    let l:link = buell#wiki#matchStrAtCursor(g:mdWikiPageLink)
    let l:type = 'page'
  endif

  " if link is still not set check if string is not a link
  if l:link == ""
    "let l:link = buell#wiki#matchStrAtCursor('curword')
    let l:link = buell#wiki#matchStrAtCursor(g:mdWikiUnlinked)
    let l:type = 'unlinked'
  endif

  " bail if text under cursor is blank (space / emtpy / etc)
  if l:link == ""
    return
  endif

  " execute depending on link type
  if l:type == 'page'
    execute "normal \<Plug>Markdown_EditUrlUnderCursor"
  elseif l:type == 'file'
    let l:target    = substitute(l:link, '.*(\([^)]*\).*', '\1', '')
    let l:firstchar = l:target[0:0]
    let l:pathbase  = expand('%:p:h')
    if l:firstchar =~ '[/~]'
      let l:openpath = l:target
    else
      let l:openpath = l:pathbase . "/" . l:target
    endif
    silent execute "!open " . l:openpath
  elseif l:type == 'section'
    let l:target = substitute(l:link, '.*(#\([^)]*\).*', '\1', '')
    " check for headers using underlining -'s or ='s
    let l:dashes = execute('%s/^'.l:target.'\n[=-]\+$//n', 'silent!')
    " check for headers using #'s
    let l:hashes = execute('%s/#* '.l:target.'//n', 'silent!')
    " prefer -,= over #
    if len(l:dashes)
      execute 'g/^'.l:target.'\n[=-]\+$/ norm ggn,/'
    elseif len(l:hashes)
      execute 'g/#* '.l:target.'/ norm ggn,/'
    else
      echo 'section not found in the document'
    endif
  elseif l:type == 'web'
    execute "normal \<Plug>Markdown_OpenUrlUnderCursor"
  elseif l:type == 'wiki'
    let l:target = substitute(l:link, '.*(\([^)]*\).*', '\1', '')
    let l:twiki = substitute(l:target, '\([^:]*\).*', '\1', '')
    let l:tpage = substitute(l:target, '[^:]*:\(.*\)', '\1', '')
    let l:wikipath = 'unset'
    for wiki in g:wiki_list
      if wiki['name'] == l:twiki
        let l:wikipath = wiki['path']
        break
      endif
    endfor
    if l:wikipath == 'unset'
      echom 'wiki not defined in plugins/wiki.vim'
    else
      if l:twiki == 'wj' || l:twiki == 'pj'
        let l:jrnlpath  = substitute(l:tpage, '\([0-9]\{4\}\.[0-9]\{2\}\)\.[0-9]\{2\}', '\1', '')
        let l:jrnlpath  = substitute(l:jrnlpath, '\.', '\/', '')
        let l:wikipath .= '/'.l:jrnlpath
      endif
      execute "edit " . l:wikipath . "/" . l:tpage . ".txt"
      "execute "edit " . fnameescape(l:wikipath) . "/" . l:tpage . ".txt"
    endif
  elseif l:type == 'unlinked'
    call buell#wiki#makeLinkAtCursor(l:link)
  endif

endfunction
