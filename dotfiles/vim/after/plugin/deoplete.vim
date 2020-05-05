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
"   around     [A]     - from around the current cursor location
"   buffer     [B]     - from the current buffer, all other buffers in current tab, and open buffers with same filetype
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
"   lsp        [lsp]   - vim-lsp language server support (deoplete-vim-lsp)

" define sources, otherwise deoplete uses complete() by default :set complete?
" to see the current vim/nvim complete sources, see ops with :help 'complete'
call deoplete#custom#option('sources', {
\   '_':          ['lsp','around', 'buffer', 'member', 'file', 'ultisnips'],
\   'cpp':        ['buffer', 'member', 'ultisnips', 'tag'],
\   'go':         ['lsp', 'around', 'buffer', 'member', 'go', 'syntax', 'ultisnips', 'tag'],
\   'html':       ['lsp', 'around', 'buffer', 'member', 'ultisnips'],
\   'mail':       ['dictionary', 'mail', 'ultisnips'],
\   'vim':        ['lsp', 'around', 'buffer', 'member', 'file', 'ultisnips', 'vim'],
\   'markdown':   ['around', 'buffer', 'member', 'dictionary', 'file', 'ultisnips', 'contact', 'emoji'],
\   'javascript': ['lsp', 'around', 'buffer', 'member', 'syntax', 'ultisnips', 'tag'],
\   'python':     ['lsp', 'around', 'buffer', 'member', 'syntax', 'ultisnips', 'tag']
\ })

" kick up the possible max number of results from 500 base
call deoplete#custom#source('contact', 'max_candidates', 2000)
call deoplete#custom#source('mail', 'max_candidates', 2000)

" get completions from any buffer regardless of matching filetype
call deoplete#custom#var('buffer', 'require_same_filetype', v:false)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                    "
"   TAB IMAPS NEED TO BE SET HERE ELSE ULTISNIPS WILL OVERWRITE IT   "
"                                                                    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

inoremap    <expr><tab>               pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap    <expr><S-Tab>             pumvisible() ? "\<C-p>" : "\<S-Tab>"

" " cycle through popup menu if visible else jump snippet tabstops if a snippet
" " is active (not yet hit tabstop $0) or send an actual tab / shift+tab
" function s:remapTabKey(action)
"   if a:action == 'snippet'
"     inoremap    <expr><tab>               pumvisible() ? "\<C-n>" : "<C-O>:call UltiSnips#JumpForwards()<CR>"
"     inoremap    <expr><S-Tab>             pumvisible() ? "\<C-p>" : "<C-O>:call UltiSnips#JumpBackwards()<CR>"
"   else
"     inoremap    <expr><tab>               pumvisible() ? "\<C-n>" : "\<Tab>"
"     inoremap    <expr><S-Tab>             pumvisible() ? "\<C-p>" : "\<S-Tab>"
"   endif
" endfunction
" 
" if has('autocmd')
"   augroup BuellAutotab
"     autocmd!
"     autocmd! User UltiSnipsEnterFirstSnippet
"     autocmd User UltiSnipsEnterFirstSnippet call s:remapTabKey('snippet')
"     autocmd! User UltiSnipsExitLastSnippet
"     autocmd User UltiSnipsExitLastSnippet call s:remapTabKey('normal')
"   augroup END
" endif
" 
" call s:remapTabKey('normal')
