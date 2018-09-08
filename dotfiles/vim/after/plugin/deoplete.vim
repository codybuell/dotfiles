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

" core sources:
"   around     [~]     - from around the current cursor location
"   buffer     [B]     - from the currently open file
"   dictionary [D]     - keywords from the dictionary
"   file       [F]     - filesystem paths and files
"   member     [M]     - members of the current buffer
"   omni       [O]     - uses whatever the defined omnifunc is at the time
"   tag        [T]     - keywords from ctag files

" plugin sources:
"   ultisnips  [US]    - ultisnip snippets (ultisnips)
"   go         [Go]    - keywords from gocode server (deoplete-go)
"   syntax     [S]     - synax suggestions for multiple languages (neco-syntax)
"   vim        [vim]   - vim languague keywords (neco-vim)
"   mail       [@]     - query addresses from lbdb (repo)
"   contact    [@]     - mail but without header req and email address (repo)
"   emoji      [emoji] - :emoji: completion for md & gitcommit docs (deoplete-emoji)

" define sources, otherwise deoplete uses complete() by default :set complete?
" to see the current vim/nvim complete sources, see ops with :help 'complete'
call deoplete#custom#option('sources', {
\   '_':         ['around', 'buffer', 'file', 'ultisnips'],
\   'cpp':       ['buffer','tag'],
\   'go':        ['around', 'buffer', 'go', 'syntax', 'tag'],
\   'html':      ['around', 'buffer'],
\   'mail':      ['dictionary', 'mail'],
\   'vim':       ['around', 'buffer', 'file', 'ultisnips', 'vim'],
\   'markdown':  ['around', 'buffer', 'dictionary', 'file', 'ultisnips', 'contact', 'emoji']
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
