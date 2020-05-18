""""""""""""""
"            "
"   Vim-Go   "
"            "
""""""""""""""

" bail if vim-go is not installed
if !buell#helpers#PluginExists('vim-go')
  finish
endif

" open terminal in horizontal split
let g:go_term_mode = "split"

" auto add imports
let g:go_fmt_command = "goimports"

" show type info of word under cursor
let g:go_auto_type_info = 1

" use our own snippets
let g:go_snippet_engine = ""

" dont show location list for go_fmt failures
let g:go_fmt_fail_silently = 1

" enable highlight groups
let g:go_highlight_build_constraints = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_operators = 1
let g:go_highlight_structs = 1
let g:go_highlight_types = 1

" quick mapping for go run
" au FileType go nmap <leader>gr <Plug>(go-run-tab)
au FileType go nmap <leader>gr <Plug>(go-run-split)
" au FileType go nmap <leader>gr <Plug>(go-run-vertical)
