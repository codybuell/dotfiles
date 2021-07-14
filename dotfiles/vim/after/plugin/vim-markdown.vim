""""""""""""""""""""
"                  "
"   Vim Markdown   "
"                  "
""""""""""""""""""""

" bail if vim-markdown is not installed
if !buell#helpers#PluginExists('vim-markdown')
  finish
endif

" see ftplugin/markdown.vim
" see plugins/autocommands.vim for setting foldmethod

let g:vim_markdown_folding_disabled          = 0     " enable folding
let g:vim_markdown_folding_level             = 2     " fold level+ to close by default
let g:vim_markdown_folding_style_pythonic    = 1     " fold on headers not below
let g:vim_markdown_auto_insert_bullets       = 0     " don't auto fill bullet points
let g:vim_markdown_new_list_item_indent      = 0     " don't auto indent sub-lists
let g:vim_markdown_override_foldtext         = 0     " don't override fold text
let g:vim_markdown_no_extensions_in_markdown = 1     " dont req ext on links
let g:vim_markdown_autowrite                 = 0     " auto save buffer when following link
let g:vim_markdown_edit_url_in               = 'tab' " tab, vsplit, hsplit, current
let g:vim_markdown_auto_extension_ext        = 'txt' " use txt rather than md for auto links
let g:vim_markdown_conceal_code_blocks       = 1     " conceal code fences ```lang\n...```
let g:vim_markdown_no_default_key_mappings   = 1     " disable default key mappings
let g:vim_markdown_emphasis_multiline        = 0     " better support for emphasis
