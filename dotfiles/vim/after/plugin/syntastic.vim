""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Syntastic Plugin Configurations                                              "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" custom settings
let g:syntastic_stl_format="⚠ %w ⨉%e (%t)"    " [warning#]:[error#] (total)
let g:syntastic_always_populate_loc_list = 1  " populate locaiton list w/ errors
let g:syntastic_auto_loc_list = 2             " no auto open but do auto close
let g:syntastic_check_on_open = 1             " check syntax on opening of files
let g:syntastic_check_on_wq   = 0             " don't check on write quit

" ignore specific html errors across all variants of file types
let g:syntastic_html_tidy_ignore_errors = [
  \   '<link> property attribute "sizes"',
  \ ]

" ignore specific html errors that cannot be avoided in blade templating files
au FileType blade let g:syntastic_html_tidy_ignore_errors += [
  \  'plain text isn''t allowed in <head> elements',
  \  '<title> isn''t allowed in <body> elements',
  \  '<meta> isn''t allowed in <body> elements',
  \  '<link> isn''t allowed in <body> elements',
  \  '<base> escaping malformed URI reference',
  \  'discarding unexpected <body>',
  \  '<script> escaping malformed URI reference',
  \  '</head> isn''t allowed in <body> elements',
  \  '<div> attribute has invalid value',
  \  '<link> escaping malformed URI reference',
  \  '<svg> is not recognized!',
  \  '<line> is not recognized!',
  \  '<path> is not recognized!',
  \  '<rect> is not recognized!',
  \  '<g> is not recognized!',
  \  'discarding unexpected <svg>',
  \  'discarding unexpected </svg>',
  \  'discarding unexpected <line>',
  \  'discarding unexpected <path>',
  \  'discarding unexpected <rect>',
  \  'discarding unexpected <g>',
  \  'discarding unexpected </g>',
  \  '<a> escaping malformed URI reference',
  \ ]

" ignore specific html errors that cannot be avoided in php files
au FileType php.html let g:syntastic_html_tidy_ignore_errors += [
  \  '<link> escaping malformed URI reference',
  \  '<html> proprietary attribute "NULL"',
  \ ]

" ignore message type and regex's specific to blade templating files
au FileType blade let g:syntastic_html_tidy_quiet_messages = {
  \ "regex": '.*attribute.*has invalid value "{{.*}}"',
  \ }
