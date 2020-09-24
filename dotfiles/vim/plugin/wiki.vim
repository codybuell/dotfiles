""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Wiki Plugin Variables                                                        "
"                                                                              "
" Functionality depends on vim-markdown plugin by plasticboy.                  "
"                                                                              "
" related files:                                                               "
"    autoload/wiki.vim                                                         "
"    ftplugin/markdown.vim                                                     "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" notes
let wiki_1       = {}
let wiki_1.name  = 'notes'
let wiki_1.path  = '{{ Notes }}'

" work journal
let wiki_2       = {}
let wiki_2.name  = 'wj'
let wiki_2.path  = '{{ WorkJournal }}'

" personal journal
let wiki_3       = {}
let wiki_3.name  = 'pj'
let wiki_3.path  = '{{ PersonalJournal }}'

" define wiki's
let g:wiki_list = [wiki_1, wiki_2, wiki_3]

" define <plug> mapping functions (createfollowlink [only apply on markdown
" files??] else put enter back to repeat last macro?, switch wiki [open up its
" index], 

" define standard link syntax regex's
let g:mdWikiPageLink    = '\[[^]]*\]([^)]*)'             " [title]([relative/path/]link)
let g:mdWikiSectionLink = '\[[^]]*\](#[^)]*)'            " [title](#link)
let g:mdWikiWebURLLink  = '\[[^]]*\](http[s]\?://[^)]*)' " [title](http[s]://link)
let g:mdWikiWikiLink    = '\[[^]]*\]([^:)]*:[^)]*)'      " [title](wiki:link)
let g:mdWikiUnlinked    = '[ ]\?\zs[^ ]*\ze'             " any block of text excluding spaces

" define wiki's dictionary
"notes: path
"journal: path
