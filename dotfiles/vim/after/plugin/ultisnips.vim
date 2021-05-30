"""""""""""""""""
"               "
"   Ultisnips   "
"               "
"""""""""""""""""

" bail if ultisnips is not installed
if !buell#helpers#PluginExists('ultisnips')
  finish
endif

" see after/plugin/deoplete.vim for tab mappings
" see init.vim for jump mappings

" when editing ultisnips, open in a vertical split
let g:UltiSnipsEditSplit = "vertical"

" define private snippets location (cannot be */snippets)
let UltiSnipsSnippetsDir = "~/.vim/snippits"

" folders to _load_ snippets from (searches runtimepath for matches)
let UltiSnipsSnippetDirectories = ['snippits']

" use google styled docstrings
let g:ultisnips_python_style = "google"

" quick navigation to edit ultisnips
nnoremap                    <localleader>u    :UltiSnipsEdit<CR>

" exit snippet as soon as you leave insert mode (if you are still mid snippet,
" not reached $0, then change tabs, vim will freeze, this is a (workaround))
" https://github.com/SirVer/ultisnips/issues/1017
au InsertLeave * silent! exec "UltiSnips_Manager._current_snippet_is_done()"
