local cmp = require('cmp')
local luasnip = require('luasnip')

--------------------------------------------------------------------------------
--                                                                            --
--  Custom Sources                                                            --
--                                                                            --
--------------------------------------------------------------------------------

buell.cmp.handles.setup()

--------------------------------------------------------------------------------
--                                                                            --
--  Helpers                                                                   --
--                                                                            --
--------------------------------------------------------------------------------

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

--------------------------------------------------------------------------------
--                                                                            --
--  General Setup                                                             --
--                                                                            --
--------------------------------------------------------------------------------

cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  experimental = {
    ghost_text = true,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>']     = cmp.mapping.scroll_docs(-4),
    ['<C-f>']     = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>']     = cmp.mapping.abort(),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-y>"] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif cmp.visible() then
        local entry = cmp.get_selected_entry()
        if not entry then
          -- cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          cmp.select_next_item()
          cmp.confirm()
        else
          cmp.confirm()
        end
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'lbdb' },
    { name = 'path' },
    { name = 'nvim_lsp_signature_help' },
    {
      name = 'buffer',
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()    -- source from all buffers
        end
      }
    },
    {
      name = 'emoji',
      insert = true
    },
  })
})

--------------------------------------------------------------------------------
--                                                                            --
--  FileType Specific Configurations                                          --
--                                                                            --
--------------------------------------------------------------------------------

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'handles' },
    { name = 'luasnip' },
    {
      name = 'lbdb',
      filetypes = { 'gitcommit' }
    },
    { name = 'path' },
    {
      name = 'buffer',
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()    -- source from all buffers
        end
      }
    },
    {
      name = 'emoji',
      insert = true
    },
  })
})

--------------------------------------------------------------------------------
--                                                                            --
--  Command Mode Configurations                                               --
--                                                                            --
--------------------------------------------------------------------------------

-- cmp.setup.cmdline(':', {
--   mapping = cmp.mapping.preset.cmdline(),
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   })
-- })
