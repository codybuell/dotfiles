"""""""""""""""""
"               "
"   Limelight   "
"               "
"""""""""""""""""

" bail if limelight is not installed
if !buell#helpers#PluginExists('limelight')
  finish
endif

" see after/plugin/goyo.vim

" opacity, defaults 0.5
let g:limelight_default_coefficient = 0.7

" number of preceding/following paragraphs to include (default: 0)
let g:limelight_paragraph_span = 0
