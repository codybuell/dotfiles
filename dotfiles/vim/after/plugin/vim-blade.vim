"""""""""""""""""
"               "
"   Vim-Blade   "
"               "
"""""""""""""""""

" bail if vim-blade is not installed
if !buell#helpers#PluginExists('vim-blade')
  finish
endif

"" Define some single Blade directives. This variable is used for highlighting only.
"let g:blade_custom_directives = ['datetime', 'javascript']
"
"" Define pairs of Blade directives. This variable is used for highlighting and indentation.
"let g:blade_custom_directives_pairs = {
"      \   'markdown': 'endmarkdown',
"      \   'cache': 'endcache',
"      \ }
