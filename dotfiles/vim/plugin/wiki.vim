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
let wiki_1.path  = '{{ NotesFolder }}'
let wiki_1.index = 'index'

" work journal
let wiki_2       = {}
let wiki_2.name  = 'work journal'
let wiki_2.path  = '{{ WorkJournal }}'
let wiki_2.index = 'index'

" personal journal
let wiki_3       = {}
let wiki_3.name  = 'personal journal'
let wiki_3.path  = '{{ PersonalJournal }}'
let wiki_3.index = 'index'

" define wiki's
let g:wiki_list = [wiki_1, wiki_2, wiki_3]

" define <plug> mapping functions (createfollowlink [only apply on markdown
" files??] else put enter back to repeat last macro?, switch wiki [open up its
" index], 

" define standard link syntax regex's
let g:mdWikiPageLink    = '\[[^]]*\]([^)]*)'                         " [title]([relative/path/]link)
let g:mdWikiSectionLink = '\[[^]]*\](#[^)]*)'                        " [title](#link)
let g:mdWikiWebURLLink  = '\[[^]]*\](http[s]\?://[^)]*\.[a-z]\{3\})' " [title](http[s]://link)
let g:mdWikiWikiLink    = '\[[^]]*\]([^:)]*:[^)]*)'                  " [title](wiki:link)
let g:mdWikiUnlinked    = '[ ]\?\zs[^ ]*\ze'                         " any block of text excluding spaces

" define wiki's dictionary
"notes: path
"journal: path
