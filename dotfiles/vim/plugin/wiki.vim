" define wiki's (notes, minutes, codex, etc)




" define standard link syntax regex's
let g:wikiPageLink    = '\[[^]]*\]([^)]*)'             " [title](link)
let g:wikiSectionLink = '\[[^]]*\](#[^)]*)'            " [title](#link)
let g:wikiWebURLLink  = '\[[^]]*\](http[s]?://[^)]*)'  " [title](http[s]://link)
let g:wikiWikiLink    = '\[[^]]*\]([^:)]*:[^)]*)'      " [title](wiki:link)

" detect if buffer is in one of the defined wikis, if so make filetype
" markdown.wiki

" local function mappings if in a wiki buffer
" create / follow link ctrl + l
" open wiki index leader w, leader w N for wiki number


" fold / conceal links
