"""""""""""""""""""""
"                   "
"   todo-comments   "
"                   "
"""""""""""""""""""""

" bail if nvim-cmp is not installed
if !buell#helpers#PluginExists('todo-comments.nvim')
  finish
endif

lua require'buell.todo'.setup()
