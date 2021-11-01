local nvim_cmp = {}
local cmp = require'cmp'

nvim_cmp.setup = function()

  cmp.setup({
    mapping = {
      ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      -- ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      -- ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      -- ['<C-o>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      -- ['<C-y>'] = cmp.config.disable,
      -- ['<CR>'] = cmp.mapping.confirm({
      --   behavior = cmp.ConfirmBehavior.Replace,
      --   select = true,
      -- }),
    },
    sources = {
      {
        name = 'emoji',
        insert = true
      },
      {
        name = 'buffer',
        get_bufnrs = function()            -- complete from all buffers
          return vim.api.nvim_list_bufs()
        end
      },
      {
        name = 'ultisnips'
      },
      {
        name = 'path'
      },
      {
        name = 'nvim_lsp'
      },
      {
        name = 'lbdb'
      }
    };
    snippet = {
      expand = function(args)
        vim.fn["UltiSnips#Anon"](args.body)
      end,
    },
  })

    -- Use buffer source for `/`.
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':'.
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

end

return nvim_cmp
