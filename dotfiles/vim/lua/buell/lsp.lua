local lsp = {}

local lsp_status  = require('lsp-status')
local lspconfig   = require('lspconfig')
local helpers     = require('buell.helpers')
local diagnostics = require('lsp-status/diagnostics')
local messages    = require('lsp-status/messaging').messages

--------------------------------------------------------------------------------
--                                                                            --
--  configuration                                                             --
--                                                                            --
--------------------------------------------------------------------------------

local config = {
  indicator_separator = ' ',
  indicator_errors = '×',
  indicator_warnings = '‼',
  indicator_info = 'ℹ',
  indicator_hint = '☝',
  indicator_ok = '●',
  status_symbol = '◎',
  spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
}

local aliases = {
  pyls_ms = 'MPLS',
}

lsp_status.register_progress()

--------------------------------------------------------------------------------
--                                                                            --
--  sort                                                                      --
--                                                                            --
--------------------------------------------------------------------------------

-- Synchronously organise (Go) imports. Taken from
-- https://github.com/neovim/nvim-lsp/issues/115#issuecomment-654427197.
function go_organize_imports_sync(timeout_ms)
  local context = { source = { organizeImports = true } }
  vim.validate { context = { context, 't', true } }
  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/callbacks.lua) for how to do this properly.
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
  if not result then return end
  local actions = result[1].result
  if not actions then return end
  local action = actions[1]

  -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
  -- is a CodeAction, it can have either an edit, a command or both. Edits
  -- should be executed first.
  if action.edit or type(action.command) == "table" then
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == "table" then
      vim.lsp.buf.execute_command(action.command)
    end
  else
    vim.lsp.buf.execute_command(action)
  end
end

--------------------------------------------------------------------------------
--                                                                            --
--  on_attach                                                                 --
--                                                                            --
--------------------------------------------------------------------------------

local on_attach = function(client, bufnr)
  -- set variable for statusbar
  --vim.api.nvim_set_var('lsp_attached', true)

  -- call lsp-status on_attach as well
  lsp_status.on_attach(client)

  -- source omnicompletion from lsp
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- configure diagnostic handler
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      -- Disable virtual_text
      virtual_text = false,
    }
  )

  -- lsp mappings
  local mappings = {
    ['<c-]>']     = '<cmd>lua vim.lsp.buf.definition()<CR>',
    ['K']         = '<cmd>lua vim.lsp.buf.hover()<CR>',
    ['<leader>d'] = '<cmd>lua vim.lsp.buf.declaration()<CR>',
    ['<leader>i'] = '<cmd>lua vim.lsp.buf.implementation()<CR>',
    -- <cmd>lua vim.lsp.buf.signature_help()<CR>
    -- <cmd>lua vim.lsp.buf.type_definition()<CR>
    -- <cmd>lua vim.lsp.buf.references()<CR>
    -- <cmd>lua vim.lsp.buf.document_symbol()<CR>
    -- <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
    -- <cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>
    -- <cmd>lua vim.lsp.diagnostic.set_loclist()<CR>
    -- <cmd>lua vim.lsp.diagnostic.get_count()<CR>
    -- buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    -- buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    -- buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
    -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    -- buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    -- buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    -- buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    -- buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    -- buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    -- buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
    -- buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    -- buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
    -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    -- nnoremap <silent> <buffer> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
    -- nnoremap <silent> <buffer> <C-]> <cmd>lua vim.lsp.buf.definition()<CR>
    -- nnoremap <silent> <buffer> K     <cmd>lua vim.lsp.buf.hover()<CR>
    -- nnoremap <silent> <buffer> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
    -- nnoremap <silent> <buffer> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
    -- nnoremap <silent> <buffer> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
    -- nnoremap <silent> <buffer> gr    <cmd>lua vim.lsp.buf.references()<CR>
    -- nnoremap <silent> <buffer> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
    -- nnoremap <silent> <buffer> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR> 
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "K",  "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "g0", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts)
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "gW", "<cmd>lua vim.lsp.buf.workspace_symbol()<CR>", opts)
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "pd", "<cmd>lua lsp_peek_definition()<CR>", opts)
    ---- TODO: Try out github.com/RishabhRD/nvim-lsputils for more stylish code
    ---- actions. Example: https://github.com/ahmedelgabri/dotfiles/commit/546dfc37cd9ef110664286eb50ece4713108a511.
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "ga", '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
    --vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  }

  for lhs, rhs in pairs(mappings) do
    helpers.nnoremap(lhs, rhs)
  end

  -- make sure the sign column is turned on
  vim.api.nvim_win_set_option(0, 'signcolumn', 'yes')

  -- reduce updatetime from 4 to 2 seconds
  vim.api.nvim_set_option('updatetime', 2000)

  helpers.augroup('BuellLSPAutocmds', function()
      -- use a popup to show diagnostics instead of virtualtext
      vim.api.nvim_command('autocmd CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics({show_header=false})')
      -- populate the loclist when errors are present
      vim.api.nvim_command('au User LspDiagnosticsChanged lua vim.lsp.diagnostic.set_loclist({open_loclist=false, severity_limit="Warning"})')
      if client.resolved_capabilities.document_formatting then
        if vim.api.nvim_buf_get_option(bufnr, "filetype") == "go" then
          vim.api.nvim_command("autocmd InsertLeave <buffer> lua go_organize_imports_sync(1000)")
        end
        vim.api.nvim_command("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)")
      end
      if client.resolved_capabilities.document_highlight then
        vim.api.nvim_command("autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()")
        vim.api.nvim_command("autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()")
        vim.api.nvim_command("autocmd CursorMoved <buffer> lua vim.lsp.util.buf_clear_references()")
      end
    end
  )
end

--------------------------------------------------------------------------------
--                                                                            --
--  on_exit                                                                   --
--                                                                            --
--------------------------------------------------------------------------------

local on_exit = function()
  -- set variable for statusbar
  --vim.api.nvim_set_var('lsp_attached', false)
end

--------------------------------------------------------------------------------
--                                                                            --
--  setup                                                                     --
--                                                                            --
--------------------------------------------------------------------------------

-- setup lsp 
lsp.setup = function()

  ------------------------
  --  language servers  --
  ------------------------
  
  lspconfig.bashls.setup{
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = lsp_status.capabilities
  }

  lspconfig.cssls.setup{
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = lsp_status.capabilities
  }

  lspconfig.dockerls.setup{
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = lsp_status.capabilities
  }

  lspconfig.gopls.setup{
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = lsp_status.capabilities
  }

  lspconfig.html.setup{
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = lsp_status.capabilities
  }

  lspconfig.intelephense.setup{
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = lsp_status.capabilities
  }

  lspconfig.jsonls.setup{
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = lsp_status.capabilities,
    filetypes = {
      "json",
      "jsonc"
    }
  }

  lspconfig.pyls.setup{
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = lsp_status.capabilities
  }

  lspconfig.tsserver.setup{
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = lsp_status.capabilities
  }

  lspconfig.vimls.setup{
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = lsp_status.capabilities
  }

  lspconfig.yamlls.setup{
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = lsp_status.capabilities
  }

  -----------------------------
  --  override winhighlight  --
  -----------------------------

  local method = 'textDocument/hover'
  local hover = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function (_, method, result)
     hover(_, method, result)
     for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
       if pcall(function ()
         vim.api.nvim_win_get_var(winnr, 'textDocument/hover')
       end) then
         vim.api.nvim_win_set_option(winnr, 'winhighlight', 'Normal:Visual,NormalNC:Visual')
         break
       else
         -- not a hover window
       end
     end
  end
  
end

---------------------------------------------------------------------------------
--                                                                             --
--  bindings                                                                    --
--                                                                             --
---------------------------------------------------------------------------------

lsp.bind = function ()
  pcall(function ()
    -- bind keys to close floating/hover window/buffer
    if vim.api.nvim_win_get_var(0, 'textDocument/hover') then
      helpers.nnoremap('K', ':call nvim_win_close(0, v:true)<CR>')
      helpers.nnoremap('<Esc>', ':call nvim_win_close(0, v:true)<CR>')
      vim.api.nvim_win_set_option(0, 'cursorline', false)
    end
  end)
end

--------------------------------------------------------------------------------
--                                                                            --
--  highlighting                                                              --
--                                                                            --
--------------------------------------------------------------------------------

lsp.setup_highlight = function()
  local pinnacle = require'wincent.pinnacle'

  -- error
  vim.cmd('highlight LspDiagnosticsVirtualTextError ' .. pinnacle.decorate('bold,italic', 'ModeMsg'))
  vim.cmd('highlight LspDiagnosticsFloatingError ' .. pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_fg('ErrorMsg')}))
  vim.cmd('highlight LspDiagnosticsSignError ' .. pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_fg('ErrorMsg')}))

  -- warning
  vim.cmd('highlight LspDiagnosticsVirtualTextWarning ' .. pinnacle.decorate('bold,italic', 'Type'))
  vim.cmd('highlight LspDiagnosticsFloatingWarning ' .. pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_bg('Substitute')}))
  vim.cmd('highlight LspDiagnosticsSignWarning ' .. pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_bg('Substitute')}))

  -- information
  vim.cmd('highlight LspDiagnosticsVirtualTextInformation ' .. pinnacle.decorate('bold,italic', 'Type'))
  vim.cmd('highlight LspDiagnosticsFloatingInformation ' .. pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_fg('Normal')}))
  vim.cmd('highlight LspDiagnosticsSignInformation ' .. pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_fg('Normal')}))

  -- hint
  vim.cmd('highlight LspDiagnosticsVirtualTextHint ' .. pinnacle.decorate('bold,italic', 'Type'))
  vim.cmd('highlight LspDiagnosticsFloatingHint ' .. pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_fg('Type')}))
  vim.cmd('highlight LspDiagnosticsSignHint ' .. pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_fg('Type')}))

  -- document_highlight
  vim.cmd('highlight LspReferenceText ' .. pinnacle.highlight({fg = pinnacle.extract_fg('Type')}))
  vim.cmd('highlight LspReferenceRead ' .. pinnacle.highlight({fg = pinnacle.extract_fg('Type')}))
  vim.cmd('highlight LspReferenceWrite ' .. pinnacle.highlight({fg = pinnacle.extract_fg('Type')}))
end

--------------------------------------------------------------------------------
--                                                                            --
--  status                                                                    --
--                                                                            --
--------------------------------------------------------------------------------

lsp.status = function(bufnr)
  bufnr = bufnr or 0
  if #vim.lsp.buf_get_clients(bufnr) == 0 then
    return ''
  end

  local buf_diagnostics = diagnostics(bufnr)
  local buf_messages = messages()
  local only_hint = true
  local some_diagnostics = false
  local status_parts = {}
  if buf_diagnostics.errors and buf_diagnostics.errors > 0 then
    table.insert(status_parts, config.indicator_errors .. config.indicator_separator .. buf_diagnostics.errors)
    only_hint = false
    some_diagnostics = true
  end

  if buf_diagnostics.warnings and buf_diagnostics.warnings > 0 then
    table.insert(status_parts, config.indicator_warnings .. config.indicator_separator .. buf_diagnostics.warnings)
    only_hint = false
    some_diagnostics = true
  end

  if buf_diagnostics.info and buf_diagnostics.info > 0 then
    table.insert(status_parts, config.indicator_info .. config.indicator_separator .. buf_diagnostics.info)
    only_hint = false
    some_diagnostics = true
  end

  if buf_diagnostics.hints and buf_diagnostics.hints > 0 then
    table.insert(status_parts, config.indicator_hint .. config.indicator_separator .. buf_diagnostics.hints)
    some_diagnostics = true
  end

  local msgs = {}
  for _, msg in ipairs(buf_messages) do
    local name = aliases[msg.name] or msg.name
    local client_name = '[' .. name .. ']'
    local contents = ''
    if msg.progress then
      contents = msg.title
      if msg.message then
        contents = contents .. ' ' .. msg.message
      end

      if msg.percentage then
        contents = contents .. ' (' .. msg.percentage .. ')'
      end

      if msg.spinner then
        contents = config.spinner_frames[(msg.spinner % #config.spinner_frames) + 1] .. ' ' .. contents
      end
    elseif msg.status then
      contents = msg.content
      if msg.uri then
        local filename = vim.uri_to_fname(msg.uri)
        filename = vim.fn.fnamemodify(filename, ':~:.')
        local space = math.min(60, math.floor(0.6 * vim.fn.winwidth(0)))
        if #filename > space then
          filename = vim.fn.pathshorten(filename)
        end

        contents = '(' .. filename .. ') ' .. contents
      end
    else
      contents = msg.content
    end

    table.insert(msgs, client_name .. ' ' .. contents)
  end

  local base_status = vim.trim(table.concat(status_parts, ' ') .. ' ' .. table.concat(msgs, ' '))
  local symbol = config.status_symbol .. ((some_diagnostics and only_hint) and '' or ' ')
  if config.current_function then
    local current_function = vim.b.lsp_current_function
    if current_function and current_function ~= '' then
      symbol = symbol .. '(' .. current_function .. ') '
    end
  end

  if base_status ~= '' then
    return symbol .. base_status .. ' '
  end

  return symbol .. config.indicator_ok .. ' '
end

return lsp
