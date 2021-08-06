local compe = {}

compe.setup = function()

  require'compe'.setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = 'disable',
    throttle_time = 80,
    source_timeout = 200,
    resolve_timeout = 800,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = {
      border = 'solid', -- see `:h nvim_open_win`
      winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
      max_width = 120,
      min_width = 60,
      max_height = math.floor(vim.o.lines * 0.3),
      min_height = 1,
    };
    source = {
      nvim_lsp = {
        priority = 100,
        filetypes = {'python', 'yaml', 'sh', 'css', 'dockerfile', 'go', 'gomod', 'html', 'php', 'json', 'typescript', 'vim'},
      },
      nvim_lua = {
        priority = 95,
        filetypes = {'lua'},
      },
      ultisnips = {
        priority = 90,
      },
      lbdb = {
        priority = 80,
        filetypes = {'markdown', 'mail'},
      },
      spell = {
        priority = 75,
        filetypes = {'markdown', 'mail'},
      },
      path = {
        priority = 70,
        ignored_filetypes = {'mail'},
      },
      buffer = {
        priority = 70,
      },
      emoji = false,
      luasnip = false,
      calc = false,
      vsnip = false,
    };
  }

  vim.cmd[[command! CompeEnable  call compe#setup(g:compe, 0)]]
  vim.cmd[[command! CompeDisable call compe#setup({'enabled': v:false}, 0)]]

end

return compe
