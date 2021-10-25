local nvim_cmp = {}
local cmp = require'cmp'

nvim_cmp.setup = function()

  cmp.setup({
    mapping = {
      -- ['<C-d>'] = cmp.mapping.scroll_docs(-4),            -- not working
      -- ['<C-f>'] = cmp.mapping.scroll_docs(4),             -- not working
      -- ['<C-Space>'] = cmp.mapping.complete(),             -- not working
      -- ['<CR>'] = cmp.mapping.confirm({ select = true }),  -- annoying
      ['<C-e>'] = cmp.mapping.close(),
      ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' }),
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

end

return nvim_cmp
