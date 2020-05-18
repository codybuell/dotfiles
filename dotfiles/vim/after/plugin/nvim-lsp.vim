""""""""""""""""""""""""""""""""""
"                                "
"   nvim-lsp + diagnostic-nvim   "
"                                "
""""""""""""""""""""""""""""""""""

" bail if not nvim and nvim-lsp is not installed
if !has('nvim') && !buell#helpers#PluginExists('nvim-lsp') && !buell#helpers#PluginExists('diagnostic-nvim')
  finish
endif

" diagnostic-nvim available settings
let g:diagnostic_enable_virtual_text = 1
let g:diagnostic_virtual_text_prefix = ' ◂◂ '
let g:diagnostic_trimmed_virtual_text = '20'
let g:space_before_virtual_text = 2
let g:diagnostic_show_sign = 1
let g:diagnostic_sign_priority = 20

lua << END
  require'nvim_lsp'.bashls.setup{on_attach=require'diagnostic'.on_attach}
  require'nvim_lsp'.cssls.setup{on_attach=require'diagnostic'.on_attach}
  require'nvim_lsp'.dockerls.setup{on_attach=require'diagnostic'.on_attach}
  require'nvim_lsp'.gopls.setup{on_attach=require'diagnostic'.on_attach}
  require'nvim_lsp'.html.setup{on_attach=require'diagnostic'.on_attach}
  require'nvim_lsp'.intelephense.setup{on_attach=require'diagnostic'.on_attach}
  require'nvim_lsp'.jsonls.setup{on_attach=require'diagnostic'.on_attach}
  require'nvim_lsp'.pyls.setup{on_attach=require'diagnostic'.on_attach}
  require'nvim_lsp'.tsserver.setup{on_attach=require'diagnostic'.on_attach}
  require'nvim_lsp'.vimls.setup{on_attach=require'diagnostic'.on_attach}
  require'nvim_lsp'.yamlls.setup{on_attach=require'diagnostic'.on_attach}
END

function! s:ConfigureBuffer()
    nnoremap <buffer> <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
    nnoremap <buffer> <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
    nnoremap <buffer> <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
    nnoremap <buffer> <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
    nnoremap <buffer> <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
    nnoremap <buffer> <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
    nnoremap <buffer> <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
    nnoremap <buffer> <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
    nnoremap <buffer> <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

    if exists('+signcolumn')
      setlocal signcolumn=yes
    endif
endfunction

function! s:SetUpLspHighlights()
  if !buell#helpers#PluginExists('pinnacle')
    return
  endif

  execute 'highlight LspDiagnosticsError ' . pinnacle#decorate('italic,underline', 'ModeMsg')

  execute 'highlight LspDiagnosticsHint ' . pinnacle#decorate('bold,italic,underline', 'Type')

  execute 'highlight LspDiagnosticsHintSign ' . pinnacle#highlight({
        \   'bg': pinnacle#extract_bg('ColorColumn'),
        \   'fg': pinnacle#extract_fg('Type')
        \ })

  execute 'highlight LspDiagnosticsErrorSign ' . pinnacle#highlight({
        \   'bg': pinnacle#extract_bg('ColorColumn'),
        \   'fg': pinnacle#extract_fg('ErrorMsg')
        \ })
endfunction

sign define LspDiagnosticsErrorSign text=×
sign define LspDiagnosticsWarningSign text=‼
sign define LspDiagnosticsInformationSign text=ℹ
sign define LspDiagnosticsHintSign text=☝

if has('autocmd')
  augroup BuellLanguageClientAutocmds
    autocmd!
    autocmd FileType sh,bash,css,sass,scss,docker,go,html,php,json,python,javascript,typescript,vim,yaml  call s:ConfigureBuffer()
    autocmd ColorScheme * call s:SetUpLspHighlights()
  augroup END
endif
