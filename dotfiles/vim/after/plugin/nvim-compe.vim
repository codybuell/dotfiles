""""""""""""""""""
"                "
"   nvim-compe   "
"                "
""""""""""""""""""

" bail if deoplete is not installed
if !buell#helpers#PluginExists('nvim-compe')
  finish
endif

lua require'buell.compe'.setup()

"inoremap   <silent><expr><C-y>       compe#complete()       " conflicts with ultisnips completion mapping
inoremap    <silent><expr><CR>        compe#confirm('<CR>')
inoremap    <expr><Tab>               pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap    <expr><S-Tab>             pumvisible() ? "\<C-p>" : "\<S-Tab>"

highlight def link CompeDocumentation NormalFloat
