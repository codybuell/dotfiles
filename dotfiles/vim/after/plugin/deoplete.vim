""""""""""""""""
"              "
"   Deoplete   "
"              "
""""""""""""""""

" bail if deoplete is not installed
if !buell#helpers#PluginExists('deoplete.nvim')
  finish
endif

" sources - raw data for completion candidates
" filters - how to display candidates (order etc)

" sources:
"   around     - from around the current cursor location
"   buffer     - from the currently open file
"   dictionary - keywords from the dictionary
"   file       - filesystem paths and files
"   member     - members of the current buffer
"   omni       - uses whatever the defined omnifunc is at the time
"   tag        - keywords from ctag files
"   ultisnips  - ultisnip snippets
"   go         - keywords from gocode server
"   syntax     - synax suggestions for multiple languages
"   vim        - vim languague keywords
"   mail       - query addresses from lbdb
"   contact    - same as mail but without header req and email address
"   emoji      - :emoji: completion (markdown and gitcommit only)

" define sources, otherwise deoplete uses complete() by default :set complete?
" to see the current vim/nvim complete sources, see ops with :help 'complete'
call deoplete#custom#option('sources', {
\   '_':         ['around', 'buffer', 'file', 'ultisnips'],
\   'cpp':       ['buffer','tag'],
\   'go':        ['around', 'buffer', 'go', 'syntax', 'tag'],
\   'html':      ['around', 'buffer'],
\   'mail':      ['dictionary', 'mail'],
\   'vim':       ['around', 'buffer', 'file', 'ultisnips', 'vim'],
\   'markdown':  ['around', 'buffer', 'file', 'ultisnips', 'contact', 'emoji']
\ })

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                    "
"   TAB IMAPS NEED TO BE SET HERE ELSE ULTISNIPS WILL OVERWRITE IT   "
"                                                                    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" tab to cycle forward through popup menu if it is visible
inoremap    <expr><tab>               pumvisible() ? "\<C-n>" : "\<tab>"

" shift-tab to reverse through popup  menu if it is visible
inoremap    <expr><S-Tab>             pumvisible() ? "\<C-p>" : "\<tab>"
