""""""""""""""""""""
"                  "
"   Vim Markdown   "
"                  "
""""""""""""""""""""

" see ftplugin/markdown.vim
" see plugins/autocommands.vim for setting foldmethod

let g:vim_markdown_folding_disabled          = 0     " enable folding
let g:vim_markdown_folding_level             = 2     " fold level+ to close by default
let g:vim_markdown_folding_style_pythonic    = 1     " fold on headers not below
let g:vim_markdown_new_list_item_indent      = 0     " don't auto indent sub-lists
let g:vim_markdown_override_foldtext         = 0     " don't override fold text
let g:vim_markdown_no_extensions_in_markdown = 1     " dont req ext on links
let g:vim_markdown_autowrite                 = 0     " auto save buffer when following link
let g:vim_markdown_edit_url_in               = 'tab' " tab, vsplit, hsplit, current
let g:vim_markdown_auto_extension_ext        = 'txt' " use txt rather than md for auto links
