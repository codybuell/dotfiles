" configurations and functions to compliment vim-wiki by plasticboy

" define standard link syntax regex's
let g:mdWikiPageLink    = '\[[^]]*\]([^)]*)'            " [title](link)   ? need to add support for .txt ??
let g:mdWikiSectionLink = '\[[^]]*\](#[^)]*)'           " [title](#link)
let g:mdWikiWebURLLink  = '\[[^]]*\](http[s]?://[^)]*)' " [title](http[s]://link)
let g:mdWikiWikiLink    = '\[[^]]*\]([^:)]*:[^)]*)'     " [title](wiki:link)

" mapping for parsing text under cursor
"   if not a link =>
"      if web => make a link
"      if #link => make a link
"      if plain string => append .txt to link
"   if is a link =>
"      if web => open web browser?
"      if a #link => go to location in current buffer
"      if a .txt link => `ge`
