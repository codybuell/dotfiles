" configurations and functions to compliment vim-markdown by plasticboy

" define wiki's (wiki name, wiki root path, wike ft extension txt or md or
" whatever, index file defaults to index.ext)

" define <plug> mapping functions (createfollowlink [only apply on markdown
" files??] else put enter back to repeat last macro?, switch wiki [open up its
" index], 

" define standard link syntax regex's
let g:mdWikiPageLink    = '\[[^]]*\]([^)]*)'                         " [title](link)   ? need to add support for .txt ??
let g:mdWikiSectionLink = '\[[^]]*\](#[^)]*)'                        " [title](#link)
let g:mdWikiWebURLLink  = '\[[^]]*\](http[s]\?://[^)]*\.[a-z]\{3\})' " [title](http[s]://link)
let g:mdWikiWikiLink    = '\[[^]]*\]([^:)]*:[^)]*)'                  " [title](wiki:link)
let g:mdWikiUnlinked    = '[ ]\?\zs[^ ]*\ze'                         " any block of text excluding spaces
