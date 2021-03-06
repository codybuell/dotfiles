""""""""""""""
"            "
"   Tagbar   "
"            "
""""""""""""""

" bail if tagbar is not installed
if !buell#helpers#PluginExists('tagbar')
  finish
endif

" match nerdtree styles
let g:tagbar_position = 'leftabove vertical'
let g:tagbar_width = 40

" don't show the help text at the top
let g:tagbar_compact = 1

" sort tags by order of appearance rather than alphabetically
let g:tagbar_sort = 0

" also use tab to toggle tagbar folds
let g:tagbar_map_togglefold = ["o","za","<Tab>"]

" tweak highlighting so it's less glaring
highlight clear TagbarHighlight
highlight! link TagbarHighlight Type
highlight clear TagbarAccessPrivate
highlight! link TagbarAccessPrivate WarningMsg

" add support for additional languaguse (assuming use of exuberant-ctags)
" test out to see if universal ctags will do the trick without these settings

" ultisnips support
let g:tagbar_type_snippets = {
\   'ctagstype' : 'snippets',
\   'kinds' : [
  \   's:snippets',
\   ]
\ }

" markdown support (requires markdown2ctags)
let g:tagbar_type_markdown = {
\   'ctagstype': 'markdown',
\   'ctagsbin' : '{{ CONFGDIR }}/submodules/markdown2ctags/markdown2ctags.py',
\   'ctagsargs' : '-f - --sort=yes',
\   'kinds' : [
      \ 's:sections',
      \ 'i:images'
\   ],
\   'sro' : '|',
\   'kind2scope' : {
      \ 's' : 'section',
\   },
\   'sort': 0,
\ }

" css support
let g:tagbar_type_css = {
\   'ctagstype' : 'Css',
\   'kinds'     : [
\     'c:classes',
\     's:selectors',
\     'i:identities'
\   ]
\ }

" go support (requires gotags)
let g:tagbar_type_go = {
\ 'ctagstype' : 'go',
\ 'kinds'     : [
\   'p:package',
\   'i:imports:1',
\   'c:constants',
\   'v:variables',
\   't:types',
\   'n:interfaces',
\   'w:fields',
\   'e:embedded',
\   'm:methods',
\   'r:constructor',
\   'f:functions'
\ ],
\ 'sro' : '.',
\ 'kind2scope' : {
\   't' : 'ctype',
\   'n' : 'ntype'
\ },
\ 'scope2kind' : {
\   'ctype' : 't',
\   'ntype' : 'n'
\ },
\ 'ctagsbin'  : 'gotags',
\ 'ctagsargs' : '-sort -silent'
\ }
