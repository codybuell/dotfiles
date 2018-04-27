""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Vim-Markdown Configurations                                                  "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:vim_markdown_folding_level             = 6     " fold many levels down
let g:vim_markdown_folding_style_pythonic    = 1     " fold on headers not below
let g:vim_markdown_override_foldtext         = 0     " don't override fold text
let g:vim_markdown_new_list_item_indent      = 0     " don't auto indent sub-lists
let g:vim_markdown_no_extensions_in_markdown = 1     " dont req ext on links
" set to whatever the current file's ext is (md or txt)
let g:vim_markdown_auto_extension_ext        = 'txt' " use txt rather than md for auto links
"let g:vim_markdown_fold_on_headings         = 1     " fold on, not below, headings
let g:vim_markdown_edit_url_in               = 'tab' " tab, vsplit, hsplit, current
