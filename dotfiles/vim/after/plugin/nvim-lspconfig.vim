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
let g:diagnostic_virtual_text_prefix = '◂'
let g:diagnostic_trimmed_virtual_text = '100'
let g:space_before_virtual_text = 2
let g:diagnostic_show_sign = 1
let g:diagnostic_sign_priority = 20

lua << END
  require'lspconfig'.bashls.setup{on_attach=require'diagnostic'.on_attach}
  require'lspconfig'.cssls.setup{on_attach=require'diagnostic'.on_attach}
  require'lspconfig'.dockerls.setup{on_attach=require'diagnostic'.on_attach}
  require'lspconfig'.gopls.setup{on_attach=require'diagnostic'.on_attach}
  require'lspconfig'.html.setup{on_attach=require'diagnostic'.on_attach}
  require'lspconfig'.intelephense.setup{on_attach=require'diagnostic'.on_attach}
  require'lspconfig'.jsonls.setup{
      on_attach = require'diagnostic'.on_attach,
      filetypes = {
        "json",
        "jsonc"
      }
    }
  require'lspconfig'.pyls.setup{on_attach=require'diagnostic'.on_attach}
  require'lspconfig'.tsserver.setup{on_attach=require'diagnostic'.on_attach}
  require'lspconfig'.vimls.setup{on_attach=require'diagnostic'.on_attach}
  require'lspconfig'.yamlls.setup{on_attach=require'diagnostic'.on_attach}

  -- Override hover winhighlight.
  local method = 'textDocument/hover'
  local hover = vim.lsp.callbacks[method]
  vim.lsp.callbacks[method] = function (_, method, result)
     hover(_, method, result)

     for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
       if pcall(function ()
         vim.api.nvim_win_get_var(winnr, 'textDocument/hover')
       end) then
         vim.api.nvim_win_set_option(winnr, 'winhighlight', 'Normal:Visual,NormalNC:Visual')
         break
       else
         -- Not a hover window.
       end
     end
  end
END

function! s:Bind()
  try
    if nvim_win_get_var(0, 'textDocument/hover')
      nnoremap <buffer> <silent> K :call nvim_win_close(0, v:true)<CR>
      nnoremap <buffer> <silent> <Esc> :call nvim_win_close(0, v:true)<CR>

      setlocal nocursorline

      " I believe this is supposed to happen automatically because I can see
      " this in lsp/util.lua:
      "
      "     api.nvim_buf_set_option(floating_bufnr, 'modifiable', false)
      "
      " but it doesn't seem to be working.
      setlocal nomodifiable
    endif
  catch /./
    " Not a hover window.
  endtry
endfunction

function! s:ConfigureBuffer()
    nnoremap <buffer> <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
    nnoremap <buffer> <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
    " nnoremap <buffer> <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
    " nnoremap <buffer> <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
    " nnoremap <buffer> <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
    " nnoremap <buffer> <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
    " nnoremap <buffer> <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
    " nnoremap <buffer> <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
    " nnoremap <buffer> <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>

    if exists('+signcolumn')
      setlocal signcolumn=yes
    endif
endfunction

function! s:SetUpLspHighlights()
  if !buell#helpers#PluginExists('pinnacle')
    return
  endif

  execute 'highlight LspDiagnosticsError ' . pinnacle#decorate('bold,italic', 'ModeMsg')
  execute 'highlight LspDiagnosticsErrorSign ' . pinnacle#highlight({
        \   'bg': pinnacle#extract_bg('ColorColumn'),
        \   'fg': pinnacle#extract_fg('ErrorMsg')
        \ })

  execute 'highlight LspDiagnosticsWarning ' . pinnacle#decorate('bold,italic', 'Type')
  execute 'highlight LspDiagnosticsWarningSign ' . pinnacle#highlight({
        \   'bg': pinnacle#extract_bg('ColorColumn'),
        \   'fg': pinnacle#extract_bg('Substitute')
        \ })

  execute 'highlight LspDiagnosticsInformation ' . pinnacle#decorate('bold,italic', 'Type')
  execute 'highlight LspDiagnosticsInformationSign ' . pinnacle#highlight({
        \   'bg': pinnacle#extract_bg('ColorColumn'),
        \   'fg': pinnacle#extract_fg('Normal')
        \ })

  execute 'highlight LspDiagnosticsHint ' . pinnacle#decorate('bold,italic', 'Type')
  execute 'highlight LspDiagnosticsHintSign ' . pinnacle#highlight({
        \   'bg': pinnacle#extract_bg('ColorColumn'),
        \   'fg': pinnacle#extract_fg('Type')
        \ })

endfunction

sign define LspDiagnosticsErrorSign text=×
sign define LspDiagnosticsWarningSign text=‼
sign define LspDiagnosticsInformationSign text=ℹ
sign define LspDiagnosticsHintSign text=☝

if has('autocmd')
  augroup BuellLanguageClientAutocmds
    autocmd!
    autocmd WinEnter * call s:Bind()
    autocmd FileType sh,bash,css,sass,scss,docker,go,html,php,json,python,javascript,typescript,vim,yaml  call s:ConfigureBuffer()
    autocmd ColorScheme * call s:SetUpLspHighlights()
  augroup END
endif
