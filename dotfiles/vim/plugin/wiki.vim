" configurations and functions to compliment vim-wiki by plasticboy

" define standard link syntax regex's
let g:mdWikiPageLink    = '\[[^]]*\]([^)]*)'                         " [title](link)   ? need to add support for .txt ??
let g:mdWikiSectionLink = '\[[^]]*\](#[^)]*)'                        " [title](#link)
let g:mdWikiWebURLLink  = '\[[^]]*\](http[s]\?://[^)]*\.[a-z]\{3\})' " [title](http[s]://link)
let g:mdWikiWikiLink    = '\[[^]]*\]([^:)]*:[^)]*)'                  " [title](wiki:link)
let g:mdWikiUnlinked    = '[ ]\?\zs[^ ]*\ze'                         " any block of text excluding spaces
