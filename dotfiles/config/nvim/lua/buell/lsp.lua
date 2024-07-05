local lsp = {}

local lspconfig  = require('lspconfig')
local lsp_status = require('lsp-status')

--------------------------------------------------------------------------------
--                                                                             --
--  Helpers                                                                    --
--                                                                             --
---------------------------------------------------------------------------------

-- Go Imports
--
-- Called as needed to update imports for go as well as run code formatting.
-- Note that goimports has all the functionality of gofmt plus it will
-- automatically update imports, so bonus.
lsp.go_imports = function(wait_ms)
  -- handle setting go imports
  local params = vim.lsp.util.make_range_params()
  params.context = {only = {"source.organizeImports"}}
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end

  -- run formatting sync (gofmt)
  vim.lsp.buf.format({async = false})
end

---------------------------------------------------------------------------------
--                                                                             --
--  Overrides                                                                  --
--                                                                             --
---------------------------------------------------------------------------------

-- pull down capabilities so we can extend them
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- add cmp capabilities
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- add lsp-status capabilities
capabilities = vim.tbl_extend('keep', capabilities or {}, lsp_status.capabilities)

-- add snippet capabilities
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- configure sign column signs (hl groups defined in after/plugin/color.lua)
vim.fn.sign_define("DiagnosticSignError", {text = "×", texthl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn", {text = "‼", texthl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignInfo", {text = "i", texthl = "DiagnosticSignInfo"})
vim.fn.sign_define("DiagnosticSignHint", {text = "⚐", texthl = "DiagnosticSignHint"})

-- On Attach
--
-- Called when intialising a language server. Used to apply ad-hoc configurations
-- wanted only when an LSP server is in use.
local on_attach = function(client, bufnr)
  -- register lsp-status client for messages and setup autocommands for updates
  lsp_status.on_attach(client)

  -- lsp normal mode mappings
  local mappings = {
    ['K']          = '<cmd>lua vim.lsp.buf.hover()<CR>',
    ['gA']         = '<cmd>lua vim.lsp.buf.code_action()<CR>',
    ['gr']         = '<cmd>lua vim.lsp.buf.references()<CR>',
    ['gd']         = '<cmd>lua vim.lsp.buf.declaration()<CR>',
    ['gD']         = '<cmd>lua vim.lsp.buf.implementation()<CR>',
    ['<c-]>']      = '<cmd>lua vim.lsp.buf.definition()<CR>',
    ['<leader>]']  = '<cmd>lua vim.lsp.buf.type_definition()<CR>',
    ['<leader>e']  = '<cmd>lua vim.diagnostic.open_float(0, {scope = "line", border = "rounded"})<CR>',
    ['<leader>f']  = '<cmd>lua vim.lsp.buf.formatting_sync(nil, 1000)<CR>',
    ['<leader>rn'] = '<cmd>lua vim.lsp.buf.rename()<CR>',
    [']g']         = '<cmd>lua vim.diagnostic.goto_next({float = {scope = "line", border = "rounded"}})<CR>',
    ['[g']         = '<cmd>lua vim.diagnostic.goto_prev({float = {scope = "line", border = "rounded"}})<CR>',
  }
  for lhs, rhs in pairs(mappings) do
    buell.util.nnoremap(lhs, rhs)
  end

  -- lsp insert mode mappings
  vim.api.nvim_buf_set_keymap(0, 'i', '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', {noremap = true, silent = true})

  -- language specific autocommands
  -- local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

  buell.util.augroup('BuellLSP', function()
    vim.api.nvim_command("autocmd BufWritePre *.go lua buell.lsp.go_imports(1000)")
    vim.api.nvim_create_autocmd('DiagnosticChanged', {
      callback = function(args)
        -- local diagnostics = args.data.diagnostics
        -- vim.print(diagnostics)
        vim.diagnostic.setloclist({open=false,severity_limit=vim.diagnostic.severity.INFO})
      end
    })
  end)
end

-- On Exit
--
-- Called when closing out a language server.
local on_exit = function()
end

---------------------------------------------------------------------------------
--                                                                             --
--  Handlers                                                                   --
--                                                                             --
---------------------------------------------------------------------------------

-- register the lsp_status progress handler
lsp_status.register_progress()

-- diagnostics handler overrides
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    -- broadly disable virtual text diagnostics
    virtual_text = false,
  }
)

-- hover handler overrides
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "rounded"
 }
)

-- signature help handler overrides
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = "rounded"
  }
)

---------------------------------------------------------------------------------
--                                                                             --
--  Server Configurations                                                      --
--                                                                             --
---------------------------------------------------------------------------------

lsp.init = function()

  -- Bash
  lspconfig.bashls.setup({
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = capabilities,
  })

  -- Golang
  lspconfig.gopls.setup({
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = capabilities,
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
  })

  -- JavaScript / TypeScript
  lspconfig.tsserver.setup({
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = capabilities,
    handlers = {
      ["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
        if err ~= nil then return end
        if result and result.diagnostics then
          -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
          local ignore_codes = {
            [80001] = true,     -- File is a CommonJS module; it may be converted to an ES module.
            -- [12345] = true,  -- example
          }
          -- filter out diagnostics with the ignored error codes
          local diagnostics = vim.tbl_filter(function(diagnostic)
            return not ignore_codes[diagnostic.code]
          end, result.diagnostics)
          -- update the diagnostics table to exclude the ignored diagnostics
          result.diagnostics = diagnostics
        end
        -- disable virtual text by setting it to false in the config passed to the default handler
        local updatedConfig = vim.tbl_deep_extend("force", { virtual_text = false }, config or {})
        -- call the default handler with the filtered diagnostics and updated config
        vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, updatedConfig)
      end
    },
  })

  -- Json
  lspconfig.jsonls.setup({
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = capabilities,
    filetypes = {
      "json",
      "jsonc"
    }
  })

  -- Html
  lspconfig.html.setup({
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = capabilities,
  })

  -- Lua
  lspconfig.lua_ls.setup {
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT',
        },
        diagnostics = {
          -- Get the language server to recognize the `vim` global
          globals = {
            'vim',
            'require',
            'buell',
          },
        },
        workspace = {
          -- Make the server aware of Neovim runtime files
          library = vim.api.nvim_get_runtime_file("", true),
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  }
  -- lspconfig.lua_ls.setup {
  --   on_attach = on_attach,
  --   on_exit = on_exit,
  --   capabilities = capabilities,
  --   on_init = function(client)
  --     local path = client.workspace_folders[1].name
  --     if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
  --       client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
  --         Lua = {
  --           diagnostics = {
  --             globals = { 'vim' }
  --           },
  --           runtime = {
  --             -- Tell the language server which version of Lua you're using
  --             -- (most likely LuaJIT in the case of Neovim)
  --             version = 'LuaJIT'
  --           },
  --           -- Make the server aware of Neovim runtime files
  --           workspace = {
  --             checkThirdParty = false,
  --             library = {
  --               vim.env.VIMRUNTIME
  --               -- "${3rd}/luv/library"
  --               -- "${3rd}/busted/library",
  --             }
  --             -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
  --             -- library = vim.api.nvim_get_runtime_file("", true)
  --           }
  --         }
  --       })

  --       client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  --     end
  --     return true
  --   end
  -- }

  -- Python
  lspconfig.pylsp.setup({
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = capabilities,
    settings = {
      pylsp = {
        plugins = {
          pycodestyle = {
            maxLineLength = 200,
            ignore = {
              "E221",    -- multiple spaces before operator
              "E241",    -- multiple spaces after :
              "E266",    -- too many leading `#` for block comment
              "W503",    -- line break occurs before binary operator (deprecated)
            }
          }
        }
      }
    }
  })

  -- Yaml
  lspconfig.yamlls.setup({
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = capabilities,
    settings = {
      yaml = {
        schemas = {
          ["http://schema.kion.io/v1/jumpstart-framework.json"] = 'frameworks/*.yml',
          ["http://schema.kion.io/v1/jumpstart-cc-aws.json"] = 'compliance-checks/cloud-custodian/aws/*.yml',
          ["http://schema.kion.io/v1/jumpstart-cc-azure.json"] = 'compliance-checks/cloud-custodian/azure/*.yml',
          ["http://schema.kion.io/v1/jumpstart-cc-cost-savings.json"] = 'cost-savings/*/cloud-custodian/*/*.yml',
          ["https://raw.githubusercontent.com/instrumenta/kubernetes-json-schema/master/v1.18.0-standalone-strict/all.json"] = "/*.k8s.yaml",
          -- ["https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json"] = "/*",
          ["https://s3.amazonaws.com/cfn-resource-specifications-us-east-1-prod/schemas/2.15.0/all-spec.json"] = '*-template.yml',
        },
        customTags = {
          --"TAG [type]", type defaults to scalar (a string or bool), other opts sequence (arrays) or map (objects)
          "!And scalar",
          "!And mapping",
          "!And sequence",
          "!If scalar",
          "!If mapping",
          "!If sequence",
          "!Not scalar",
          "!Not mapping",
          "!Not sequence",
          "!Equals scalar",
          "!Equals mapping",
          "!Equals sequence",
          "!Or scalar",
          "!Or mapping",
          "!Or sequence",
          "!FindInMap scalar",
          "!FindInMap mappping",
          "!FindInMap sequence",
          "!Base64 scalar",
          "!Base64 mapping",
          "!Base64 sequence",
          "!Cidr scalar",
          "!Cidr mapping",
          "!Cidr sequence",
          "!Ref scalar",
          "!Ref mapping",
          "!Ref sequence",
          "!Sub scalar",
          "!Sub mapping",
          "!Sub sequence",
          "!GetAtt scalar",
          "!GetAtt mapping",
          "!GetAtt sequence",
          "!GetAZs scalar",
          "!GetAZs mapping",
          "!GetAZs sequence",
          "!ImportValue scalar",
          "!ImportValue mapping",
          "!ImportValue sequence",
          "!Select scalar",
          "!Select mapping",
          "!Select sequence",
          "!Split scalar",
          "!Split mapping",
          "!Split sequence",
          "!Join scalar",
          "!Join mapping",
          "!Join sequence",
          "!Condition",
        }
      }
    }
  })

  -- Tailwind
  lspconfig.tailwindcss.setup({
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = capabilities,
    filetypes = {
      "aspnetcorerazor",
      "astro",
      "astro-markdown",
      "blade",
      "clojure",
      "django-html",
      "htmldjango",
      "edge",
      "eelixir",
      "elixir",
      "ejs",
      "erb",
      "eruby",
      "gohtml",
      "gohtmltmpl",
      "haml",
      "handlebars",
      "hbs",
      "html",
      "html-eex",
      "heex",
      "jade",
      "leaf",
      "liquid",
      "mdx",
      "mustache",
      "njk",
      "nunjucks",
      "php",
      "razor",
      "slim",
      "twig",
      "css",
      "less",
      "postcss",
      "sass",
      "scss",
      "stylus",
      "sugarss",
      "javascript",
      "javascriptreact",
      "reason",
      "rescript",
      "typescript",
      "typescriptreact",
      "vue",
      "svelte",
      "templ"
    },
  })

  -- Svelte
  lspconfig.svelte.setup({
    on_attach = on_attach,
    on_exit = on_exit,
    capabilities = capabilities,
  })

end

return lsp
