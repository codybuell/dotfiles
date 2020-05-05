"""""""""""""""
"             "
"   Vim-LSP   "
"             "
"""""""""""""""

" - [ ] test json and yaml schema support
" - [ ] learn how to get info about type of item under cursor, function info, etc
"       - setup mappings for them or have them auto displayed
"       - configure them so they have syntax highlighting, and are type set well
" - [ ] lsp completion does not appear unless the buffer has been saved
" - [ ] adjust how quickly errors show up in real time... virtual text can be
"       distsacting when popping in and out as you type
" - [ ] show indication that a langserver is running in the statusline lhs
" - [ ] build out mappings in on_lsp_buffer_enabled function
" - [ ] on info popup, add some syntax highlighting, completeopt / cot preview
" - [ ] figure out how to and create section for blacklisting some linting validations
" - [ ] read up on vim-go again, see if it is still needed
" - [ ] see if highlighting was compiled in to your nvim, test lsp_highlights_enabled
" - [ ] configure other language servers
"      - lua         https://github.com/prabirshrestha/vim-lsp/wiki/Servers-Lua
"      - c/c++       https://github.com/prabirshrestha/vim-lsp/wiki/Servers-Clangd
"      - terraform
"      - markdown??
"      - other js server?? https://github.com/prabirshrestha/vim-lsp/wiki/Servers-JavaScript
"      - other go server?? https://github.com/prabirshrestha/vim-lsp/wiki/Servers-Go

let g:lsp_diagnostics_enabled = 1           " turn on language warnings, errors, etc
let g:lsp_diagnostics_echo_cursor = 1       " enable echo under cursor when in normal mode
let g:lsp_fold_enabled = 1                  " set to 0 to disable folding globally

" signs configurations
" ℓ ℒ ℘ ⨂ ● ○ ✘ ⨯ × x 𐆒 𐆓 ✗ ⚠ ☞ ☝ ⚐ ⚑ ⁇ ⁈ ‼
let g:lsp_signs_enabled = 1                 " enable signs
let g:lsp_signs_error = {'text': '×'}       " LspErrorText & LspErrorHighlight color groups, links to Error group
let g:lsp_signs_warning = {'text': '‼'}     " LspWarningText & LspWarningHighlight color groups, links to Todo group
let g:lsp_signs_information = {'text': '⚑'} " LspInformationText & LspInformationHighlight color groups, links to Normal group
let g:lsp_signs_hint = {'text': '☝'}        " LspHitText & LspHintHighlight color groups, links to Normal group

" virtual text for providing inline diagnostic messages
let g:lsp_virtual_text_enabled = 1
let g:lsp_virtual_text_prefix = " ◂◂ "

let g:lsp_textprop_enabled = 1

" in document, in line highlighting
let g:lsp_highlights_enabled = 0
let g:lsp_highlight_references_enabled = 1

""""""""""""""""""
"  highlighting  "
""""""""""""""""""

" set signs coloring
highlight link LspErrorText DiffDelete
highlight link LspErrorVirtual MoreMsg
"highlight link LspErrorHighlight Search
highlight LspWarningText ctermfg=3 ctermbg=18 gui=bold guifg=#f0c674 guibg=#282a2e
highlight link LspWarningVirtual MoreMsg
"highlight link LspWarningHighlight Search
highlight link LspInformationText DiffAdd
highlight link LspInformationVirtual MoreMsg
"highlight link LspInformationHighlight Search
highlight link LspHintText DiffChange
highlight link LspHintVirtual MoreMsg
"highlight link LspHintHighlight Search


" highlight instances of the word under the cursor
"highlight lspReference ctermfg=red guifg=red ctermbg=green guibg=green

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                            "
"  language servers                                                          "
"                                                                            "
"     node-ipc: ??                                                           "
"        stdio: generally using this method / variant of binary / flag       "
"       socket: use tcp port to connect to running server                    "
"                                                                            "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""
"  css/less/sass  "
"""""""""""""""""""

" npm install -g vscode-css-languageserver-bin
if executable('css-languageserver')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'css-languageserver',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'css-languageserver --stdio']},
        \ 'whitelist': ['css', 'less', 'sass'],
        \ })
endif

""""""""""
"  bash  "
""""""""""

" npm -g install bash-language-server
if executable('bash-language-server')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'bash-language-server',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'bash-language-server start']},
        \ 'whitelist': ['sh'],
        \ })
endif

"""""""""""""""""""""""""""
"  javascript/typescript  "
"""""""""""""""""""""""""""

" npm -g install javascript-typescript-langserver
if executable('javascript-typescript-stdio')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'javascript-typescript-stdio',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'javascript-typescript-stdio']},
        \ 'whitelist': ['javascript','typescript'],
        \ })
endif

""""""""""
"  json  "
""""""""""

" npm -g install vscode-json-languageserver

""""""""""
"  yaml  "
""""""""""

" npm -g install yaml-language-server
if executable('yaml-language-server')
  augroup LspYaml
   autocmd!
   autocmd User lsp_setup call lsp#register_server({
       \ 'name': 'yaml-language-server',
       \ 'cmd': {server_info->['yaml-language-server', '--stdio']},
       \ 'whitelist': ['yaml', 'yaml.ansible'],
       \ 'workspace_config': {
       \   'yaml': {
       \     'validate': v:true,
       \     'hover': v:true,
       \     'completion': v:true,
       \     'customTags': [],
       \     'schemas': {},
       \     'schemaStore': { 'enable': v:true },
       \   }
       \ }
       \})
  augroup END
endif

"""""""""
"  vim  "
"""""""""

" npm install -g vim-language-server
if executable('vim-language-server')
  augroup LspVim
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
        \ 'name': 'vim-language-server',
        \ 'cmd': {server_info->['vim-language-server', '--stdio']},
        \ 'whitelist': ['vim'],
        \ 'initialization_options': {
        \   'vimruntime': $VIMRUNTIME,
        \   'runtimepath': &rtp,
        \ }})
  augroup END
endif

"""""""""
"  php  "
"""""""""

" npm -g install intelephense
if executable('intelephense')
  augroup LspPHPIntelephense
    au!
    au User lsp_setup call lsp#register_server({
        \ 'name': 'intelephense',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'intelephense --stdio']},
        \ 'whitelist': ['php'],
        \ 'initialization_options': {'storagePath': '/tmp/intelephense'},
        \ 'workspace_config': {
        \   'intelephense': {
        \     'files': {
        \       'maxSize': 1000000,
        \       'associations': ['*.php', '*.phtml'],
        \       'exclude': [],
        \     },
        \     'completion': {
        \       'insertUseDeclaration': v:true,
        \       'fullyQualifyGlobalConstantsAndFunctions': v:false,
        \       'triggerParameterHints': v:true,
        \       'maxItems': 100,
        \     },
        \     'format': {
        \       'enable': v:true
        \     },
        \   },
        \ }
        \})
  augroup END
endif

""""""""""""""
"  markdown  "
""""""""""""""

" npm -g install markdown-language-server

""""""""""
"  html  "
""""""""""

" npm install -g vscode-html-languageserver-bin
if executable('html-languageserver')
  au User lsp_setup call lsp#register_server({
    \ 'name': 'html-languageserver',
    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'html-languageserver --stdio']},
    \ 'whitelist': ['html'],
  \ })
endif

""""""""""""""""
"  dockerfile  "
""""""""""""""""

" npm install -g dockerfile-language-server-nodejs
if executable('docker-langserver')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'docker-langserver',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'docker-langserver --stdio']},
        \ 'whitelist': ['dockerfile'],
        \ })
endif

""""""""""""
"  golang  "
""""""""""""

" go get golang.org/x/tools/gopls@latest OR GO111MODULE=on go get golang.org/x/tools/gopls@latest
if executable('gopls')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls']},
        \ 'whitelist': ['go'],
        \ })
  autocmd BufWritePre *.go LspDocumentFormatSync
" autocmd FileType go nmap <buffer> gd <plug>(lsp-definition)
" autocmd FileType go nmap <buffer> ,n <plug>(lsp-next-error)
" autocmd FileType go nmap <buffer> ,p <plug>(lsp-previous-error)
endif

""""""""""""
"  python  "
""""""""""""

" pip install python-language-server
if executable('pyls')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ 'workspace_config': {'pyls': {'plugins': {'pydocstyle': {'enabled': v:false}}}}
        \ })
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                            "
"  functions and buffer bits                                                 "
"                                                                            "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" configure settings / mappings for the lsp enabled buffers
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    " we set signcolumn globally to always be on in init.vim
    " setlocal signcolumn=yes
    setlocal foldmethod=expr
      \ foldexpr=lsp#ui#vim#folding#foldexpr()
   "  \ foldtext=lsp#ui#vim#folding#foldtext()
   "nmap  <buffer>          <f2>                  <plug>(lsp-rename)
    nmap  <buffer>          K                     <plug>(lsp-definition)
    nmap  <buffer>          <Up>                  <plug>(lsp-next-error)
    nmap  <buffer>          <Down>                <plug>(lsp-previous-error)
  " LspHover
  " LspImplementation
  " LspPreviousDiagnostic cycles all of error, warning, info, hint
  " LspNextDiagnostic cycles all of error, warning, info, hint
  " LspTypeHierarchy
  " LspWorkspaceSymbol
endfunction

augroup lsp_install
  au!
  " call s:on_lsp_buffer_enabled only for languages that has the server registered.
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
