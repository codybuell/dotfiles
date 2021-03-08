""""""""""""""""""""""""
"                      "
"   Markdown Preview   "
"                      "
""""""""""""""""""""""""

" bail if nerdtree is not installed
if !buell#helpers#PluginExists('markdown-preview.nvim')
  finish
endif

" stylesheet to force light mode
let g:mkdp_markdown_css = '{{ CONFGDIR }}/assets/github.css'
let g:mkdp_highlight_css = '{{ CONFGDIR }}/assets/github.css'

" wrapper to install, needs to be improved on
function BuellInstallMarkdownPreview()
  call mkdp#util#install()
  sleep 5
  quit
endfunction
