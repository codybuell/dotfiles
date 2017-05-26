" define wiki's
let mdWiki01 = {}
let mdWiki01.path  = '{{ NotesFolder }}'                " wiki root path
let mdWiki01.index = 'index'                            " file minus ext of start page

let mdWiki02 = {}
let mdWiki02.path  = '{{ CodexFolder }}'                " wiki root path
let mdWiki02.index = 'index'                            " file minus ext of start page

let g:mdWikiList = [mdWiki01, mdWiki02]

" define standard link syntax regex's
let g:mdWikiPageLink    = '\[[^]]*\]([^)]*)'            " [title](link)
let g:mdWikiSectionLink = '\[[^]]*\](#[^)]*)'           " [title](#link)
let g:mdWikiWebURLLink  = '\[[^]]*\](http[s]?://[^)]*)' " [title](http[s]://link)
let g:mdWikiWikiLink    = '\[[^]]*\]([^:)]*:[^)]*)'     " [title](wiki:link)

" build autocommands to append mdwiki file type
for wiki in g:mdWikiList
  l:wikiPath = wiki.path . '/*'
  au BufNewFile,BufRead l:wikiPath      set ft+=.mdwiki
endfor

" detect if buffer is in one of the defined wikis, if so make filetype
" markdown.wiki

" local function mappings if in a wiki buffer
" create / follow link ctrl + l
" open wiki index leader w, leader w N for wiki number


" fold / conceal links
