local compe = {}

compe.setup = function()

  require'compe'.setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = 'enable',
    throttle_time = 80,
    source_timeout = 200,
    resolve_timeout = 800,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,
    source = {
      nvim_lsp = {
        priority = 100,
        filetypes = {'python','yaml','sh','css','dockerfile','go','gomod','html','php','json','typescript','vim'},
      },
      nvim_lua = {
        priority = 95,
        filetypes = {'lua'},
      },
      ultisnips = {
        priority = 90,
      },
      spell = {
        priority = 85,
        filetypes = {'mail','markdown'},
      },
      path = {
        priority = 80,
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
