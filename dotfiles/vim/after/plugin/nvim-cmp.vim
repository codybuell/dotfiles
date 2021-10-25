""""""""""""""""
"              "
"   nvim-cmp   "
"              "
""""""""""""""""

" bail if nvim-cmp is not installed
if !buell#helpers#PluginExists('nvim-cmp')
  finish
endif

lua require'buell.nvim_cmp'.setup()
