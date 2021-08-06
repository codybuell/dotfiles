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
  indicator_info = 'i',
  indicator_hint = '☝',
  indicator_ok = ' ',
  status_symbol = 'ℒ ',
  spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
  current_function = false,
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

function go_imports_on_save()
  vim.api.nvim_command("silent! !goimports -w %")
  vim.api.nvim_command("e!")
end

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
  --vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- lsp mappings
  local mappings = {
    ['K']          = '<cmd>lua vim.lsp.buf.hover()<CR>',
    ['gA']         = '<cmd>lua vim.lsp.buf.code_action()<CR>',
    ['gr']         = '<cmd>lua vim.lsp.buf.references()<CR>',
    ['gd']         = '<cmd>lua vim.lsp.buf.declaration()<CR>',
    ['gD']         = '<cmd>lua vim.lsp.buf.implementation()<CR>',
    ['<c-]>']      = '<cmd>lua vim.lsp.buf.definition()<CR>',
    ['<leader>]']  = '<cmd>lua vim.lsp.buf.type_definition()<CR>',
    ['<leader>e']  = '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({show_header=true, border="solid"})<CR>',
    ['<leader>f']  = '<cmd>lua vim.lsp.buf.formatting_sync(nil, 1000)<CR>',
    ['<leader>rn'] = '<cmd>lua vim.lsp.buf.rename()<CR>',
    [']g']         = '<cmd>lua vim.lsp.diagnostic.goto_next({popup_opts={show_header=true, border="solid"}})<CR>',
    ['[g']         = '<cmd>lua vim.lsp.diagnostic.goto_prev({popup_opts={show_header=true, border="solid"}})<CR>',
  }

  for lhs, rhs in pairs(mappings) do
    helpers.nnoremap(lhs, rhs)
  end

  vim.api.nvim_buf_set_keymap(0, 'i', '<c-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', {noremap = true, silent = true})
  vim.lsp.util.close_preview_autocmd = function(events, winnr)
      -- I prefer to keep the preview (especially for signature_help) open while typing in insert mode
      events = vim.tbl_filter(function(v) return v ~= 'CursorMovedI' and v ~= 'BufLeave' end, events)
      vim.api.nvim_command("autocmd "..table.concat(events, ',').." <buffer> ++once lua pcall(vim.api.nvim_win_close, "..winnr..", true)")
    end

  -- make sure the sign column is turned on
  vim.api.nvim_win_set_option(0, 'signcolumn', 'yes')

  -- reduce updatetime from 4 to 2 seconds
  vim.api.nvim_set_option('updatetime', 2000)

  helpers.augroup('BuellLSPAutocmds', function()
      -- use a popup to show diagnostics instead of virtualtext
      --vim.api.nvim_command('autocmd CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics({show_header=true})')
      -- populate the loclist when errors are present
      -- vim.api.nvim_command('au User LspDiagnosticsChanged silent! lua vim.lsp.diagnostic.set_loclist({open_loclist=false, severity_limit="Warning"})')
      if client.resolved_capabilities.document_formatting then
        if vim.api.nvim_buf_get_option(bufnr, "filetype") == "go" then
          -- vim.api.nvim_command("autocmd InsertLeave <buffer> lua go_organize_imports_sync(1000)")
          vim.api.nvim_command("autocmd BufWritePost <buffer> lua go_imports_on_save()")
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

  ----------------------------------
  --  tweak hl groups for hovers  --
  ----------------------------------

  -- this is not ideal as it applies everywhere, but it's only firing on
  -- hover handler calls, the groups are somewhat obscure, and were
  -- likely not working on any markdown files at the same time...
  local hi_groups = {
    [1] = "mkdLineBreak",
    [2] = "goSpaceError",
  }
  for _,val in ipairs(hi_groups) do
    vim.cmd('hi link ' .. val .. ' None')
  end

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
    capabilities = lsp_status.capabilities,
    settings = {
      gopls = {
        staticcheck = true,
        analyses = {
          -- full list: https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
          unusedparams = true,
          shadow = false,
        }
      }
    }
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
    capabilities = lsp_status.capabilities,
    settings = {
      pyls = {
        plugins = {
          pycodestyle = {
            maxLineLength = 200,
            ignore = {
              "E221",    -- multiple spaces before operator
              "E241",    -- multiple spaces after :
              "E266",    -- too many leading ‘#’ for block comment
              "W503",    -- line break occurs before binary operator (deprecated)
            }
          }
        }
      }
    }
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
    capabilities = lsp_status.capabilities,
    settings = {
      yaml = {
        schemaStore = {
          enable = true
        },
        schemas = {
          ["http://schema.cloudtamer.io/v1/jumpstart-framework.json"] = 'frameworks/*.yml',
          ["http://schema.cloudtamer.io/v1/jumpstart-cc-aws.json"] = 'compliance-checks/cloud-custodian/aws/*.yml',
          ["http://schema.cloudtamer.io/v1/jumpstart-cc-azure.json"] = 'compliance-checks/cloud-custodian/azure/*.yml',
          ["http://schema.cloudtamer.io/v1/jumpstart-cc-cost-savings.json"] = 'cost-savings/*/cloud-custodian/*/*.yml'
        }
      }
    }
  }

  lspconfig.efm.setup{
  init_options = {documentFormatting = true},
    filetypes = {"sh"},
    settings = {
      rootMarkers = {".git/"},
      languages = {
          sh = {
            {lintCommand = 'shellcheck -f gcc -x', lintSource = 'shellcheck', lintFormats= {'%f:%l:%c: %trror: %m', '%f:%l:%c: %tarning: %m', '%f:%l:%c: %tote: %m'}}
          }
      }
    }
  }


  -- https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
  local cmd = vim.fn.expand(
      '~/Repos/github.com/sumneko/lua-language-server/bin/macOS/lua-language-server'
  )
  local main = vim.fn.expand('~/Repos/github.com/sumneko/lua-language-server/main.lua')
  if vim.fn.executable(cmd) == 1 then
    lspconfig.sumneko_lua.setup{
      cmd = {cmd, '-E', main},
      on_attach = on_attach,
      settings = {
        Lua = {
          diagnostics = {
            enable = true,
            globals = {'vim'},
          },
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = {
              [vim.fn.expand('$VIMRUNTIME/lua')] = true,
              [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
            },
          },
          filetypes = {'lua'},
          runtime = {
            path = vim.split(package.path, ';'),
            version = 'LuaJIT',
          },
        }
      },
    }
  end

  -------------------------
  --  handler overrides  --
  -------------------------

  -- configure diagnostic handler
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      -- broadly disable virtual text diagnostics
      virtual_text = false,
    }
  )

  -- extend hover handler
  local method = 'textDocument/hover'
  local hover = vim.lsp.handlers[method]
  vim.lsp.handlers[method] = function (_, method, result)
    -- run the original hover handler method
    hover(_, method, result)

    -- loop through windows to identify hover floating window
    for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if pcall(function ()
        vim.api.nvim_win_get_var(winnr, 'textDocument/hover')
      end) then
        local hover_winnr = vim.api.nvim_win_get_number(winnr)
        --local curr_winnr  = vim.api.nvim_win_get_number(0)
        -- couple of options here to clean up shitty syntax in hover menus:
        --  - use set option call below to set winhighlight
        --  - set Pmenu hi group which affects all popup menus, preview and floating windows
        --  - make :syntax clear [offender]
        -- vim.api.nvim_win_set_option(winnr, 'winhighlight', 'Normal:Visual,NormalNC:Visual')
        -- TODO: want to not focus on the hover window... no option via windo, may need to caputre og wn and pipe cmd back
        --vim.cmd(hover_winnr .. ',' .. hover_winnr .. 'windo syntax clear mkdLineBreak goSpaceError')

        --vim.cmd(curr_winnr .. 'wincmd w')
        -- TODO: test buf enter autocmd to remove syntax by calling a func? how to id the buf?
        break
      else
        -- not a hover window
        -- hacky shit to stop the parent buffers background changing color
        -- vim.cmd('hi Normal guibg=none')
      end
    end
  end

  -- configure border for documentation hover / popup
  vim.lsp.handlers["textDocument/hover"] =
    vim.lsp.with(
    vim.lsp.handlers.hover,
    {
      border = "solid",
    }
    )

  -- configure border for signature help
  vim.lsp.handlers["textDocument/signatureHelp"] =
    vim.lsp.with(
    vim.lsp.handlers.signature_help,
    {
      border = "solid",
    }
)

end

---------------------------------------------------------------------------------
--                                                                             --
--  bindings                                                                    --
--                                                                             --
---------------------------------------------------------------------------------

lsp.bind = function ()
  pcall(function ()
    -- on entering lsp hover floating window bind keys to close
    if vim.api.nvim_win_get_var(0, 'textDocument/hover') then
      helpers.nnoremap('K', ':call nvim_win_close(0, v:true)<CR>')
      helpers.nnoremap('<Esc>', ':call nvim_win_close(0, v:true)<CR>')
      vim.api.nvim_win_set_option(0, 'cursorline', false)
    end
  end)
  pcall(function ()
    -- on entering lsp line diagnostics floating window bind keys to close
    if vim.api.nvim_win_get_var(0, 'line_diagnostics') then
      helpers.nnoremap('<leader>e', ':call nvim_win_close(0, v:true)<CR>')
      helpers.nnoremap('<Esc>', ':call nvim_win_close(0, v:true)<CR>')
      -- vim.api.nvim_win_set_option(0, 'cursorline', false)
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
  vim.cmd('highlight LspDiagnosticsFloatingError ' .. pinnacle.highlight({fg = pinnacle.extract_fg('ErrorMsg')}))
  vim.cmd('highlight LspDiagnosticsSignError ' .. pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_fg('ErrorMsg')}))

  -- warning
  vim.cmd('highlight LspDiagnosticsVirtualTextWarning ' .. pinnacle.decorate('bold,italic', 'Type'))
  vim.cmd('highlight LspDiagnosticsFloatingWarning ' .. pinnacle.highlight({fg = pinnacle.extract_bg('Substitute')}))
  vim.cmd('highlight LspDiagnosticsSignWarning ' .. pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_bg('Substitute')}))

  -- information
  vim.cmd('highlight LspDiagnosticsVirtualTextInformation ' .. pinnacle.decorate('bold,italic', 'Type'))
  vim.cmd('highlight LspDiagnosticsFloatingInformation ' .. pinnacle.highlight({fg = pinnacle.extract_fg('Normal')}))
  vim.cmd('highlight LspDiagnosticsSignInformation ' .. pinnacle.highlight({bg = pinnacle.extract_bg('ColorColumn'), fg = pinnacle.extract_fg('Conceal')}))

  -- hint
  vim.cmd('highlight LspDiagnosticsVirtualTextHint ' .. pinnacle.decorate('bold,italic', 'Type'))
  vim.cmd('highlight LspDiagnosticsFloatingHint ' .. pinnacle.highlight({fg = pinnacle.extract_fg('Type')}))
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
