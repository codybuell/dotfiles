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

" when editing ultisnips, open in a vertical split
let g:UltiSnipsEditSplit = "vertical"

" define private snippets location (cannot be */snippets)
let UltiSnipsSnippetsDir = "~/.vim/snippits"

" folders to _load_ snippets from (searches runtimepath for matches)
let UltiSnipsSnippetDirectories = ['snippits']

" quick navigation to edit ultisnips
nnoremap                    <localleader>u    :UltiSnipsEdit<CR>
