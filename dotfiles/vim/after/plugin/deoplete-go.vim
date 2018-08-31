"""""""""""""""""""
"                 "
"   Deoplete-Go   "
"                 "
"""""""""""""""""""

" path out gocode dependency
let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'

" filtering configuration of sub-sources
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']

" auto insert dot after selecting a package name
let g:deoplete#sources#go#package_dot = 1
