--------------------------------------------------------------------------------
--                                                                            --
--  NVIM-CMP                                                                  --
--                                                                            --
--  https://github.com/hrsh7th/nvim-cmp                                       --
--                                                                            --
--------------------------------------------------------------------------------

local has_cmp, cmp = pcall(require, 'cmp')
if not has_cmp then
  return
end

local rhs = buell.util.rhs
local has_luasnip, luasnip = pcall(require, 'luasnip')

---------------------
--  Configuration  --
---------------------

-- expects kitty terminal or a patched font for unicode character support
local lsp_kinds = {
  Class         = ' ',
  Color         = ' ',
  Constant      = ' ',
  Constructor   = ' ',
  Enum          = ' ',
  EnumMember    = ' ',
  Event         = ' ',
  Field         = ' ',
  File          = ' ',
  Folder        = ' ',
  Function      = ' ',
  Interface     = ' ',
  Keyword       = ' ',
  Method        = ' ',
  Module        = ' ',
  Operator      = ' ',
  Property      = ' ',
  Reference     = ' ',
  Snippet       = ' ',
  Struct        = ' ',
  Text          = ' ',
  TypeParameter = ' ',
  Unit          = ' ',
  Value         = ' ',
  Variable      = ' ',
}

-- custom sources
buell.cmp.handles.setup()        -- github handles

---------------
--  Helpers  --
---------------

-- Check if there are non-whitespace characters before the cursor.
-- local has_words_before = function()
--   if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then return false end
--   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
--   return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
-- end

local has_copilot_virtual_text = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local copilot_ns = vim.fn['copilot#NvimNs']()
  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, copilot_ns, 0, -1, { details = true })
  return #extmarks > 0
end

-- Returns the current column number.
local column = function()
  local _line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col
end

-- Returns true if the cursor is in leftmost column or at a whitespace
-- character.
local in_whitespace = function()
  local col = column()
  return col == 0 or vim.api.nvim_get_current_line():sub(col, col):match('%s')
end

local in_leading_indent = function()
  local col = column()
  local line = vim.api.nvim_get_current_line()
  local prefix = line:sub(1, col)
  return prefix:find('^%s*$')
end

local shift_width = function()
  if vim.o.softtabstop <= 0 then
    return vim.fn.shiftwidth()
  else
    return vim.o.softtabstop
  end
end

-- Complement to `smart_tab()`.
--
-- When 'noexpandtab' is set (ie. hard tabs are in use), backspace:
--
--    - On the left (ie. in the indent) will delete a tab.
--    - On the right (when in trailing whitespace) will delete enough
--      spaces to get back to the previous tabstop.
--    - Everywhere else it will just delete the previous character.
--
-- For other buffers ('expandtab'), we let Neovim behave as standard and that
-- yields intuitive behavior, unless the `dedent` parameter is truthy, in
-- which case we issue <C-D> to dedent (see `:help i_CTRL-D`).
local smart_bs = function(dedent)
  local keys = nil
  if vim.o.expandtab then
    if dedent then
      keys = rhs('<C-D>')
    else
      keys = rhs('<BS>')
    end
  else
    local col = column()
    local line = vim.api.nvim_get_current_line()
    local prefix = line:sub(1, col)
    if in_leading_indent() then
      keys = rhs('<BS>')
    else
      local previous_char = prefix:sub(#prefix, #prefix)
      if previous_char ~= ' ' then
        keys = rhs('<BS>')
      else
        -- Delete enough spaces to take us back to the previous tabstop.
        --
        -- Originally I was calculating the number of <BS> to send, but
        -- Neovim has some special casing that causes one <BS> to delete
        -- multiple characters even when 'expandtab' is off (eg. if you hit
        -- <BS> after pressing <CR> on a line with trailing whitespace and
        -- Neovim inserts whitespace to match.
        --
        -- So, turn 'expandtab' on temporarily and let Neovim figure out
        -- what a single <BS> should do.
        --
        -- See `:h i_CTRL-\_CTRL-O`.
        keys = rhs('<C-\\><C-o>:set expandtab<CR><BS><C-\\><C-o>:set noexpandtab<CR>')
      end
    end
  end
  vim.api.nvim_feedkeys(keys, 'nt', true)
end

-- In buffers where 'noexpandtab' is set (ie. hard tabs are in use), <Tab>:
--
--    - Inserts a tab on the left (for indentation).
--    - Inserts spaces everywhere else (for alignment).
--
-- For other buffers (ie. where 'expandtab' applies), we use spaces everywhere.
local smart_tab = function(opts)
  local keys = nil
  if vim.o.expandtab then
    keys = '<Tab>' -- Neovim will insert spaces.
  else
    local col = column()
    local line = vim.api.nvim_get_current_line()
    local prefix = line:sub(1, col)
    local in_leading_indent = prefix:find('^%s*$')
    if in_leading_indent then
      keys = '<Tab>' -- Neovim will insert a hard tab.
    else
      -- virtcol() returns last column occupied, so if cursor is on a
      -- tab it will report `actual column + tabstop` instead of `actual
      -- column`. So, get last column of previous character instead, and
      -- add 1 to it.
      local sw = shift_width()
      local previous_char = prefix:sub(#prefix, #prefix)
      local previous_column = #prefix - #previous_char + 1
      local current_column = vim.fn.virtcol({ vim.fn.line('.'), previous_column }) + 1
      local remainder = (current_column - 1) % sw
      local move = remainder == 0 and sw or sw - remainder
      keys = (' '):rep(move)
    end
  end

  vim.api.nvim_feedkeys(rhs(keys), 'nt', true)
end

local select_next_item = function(fallback)
  if cmp.visible() then
    cmp.select_next_item()
  else
    fallback()
  end
end

local select_prev_item = function(fallback)
  if cmp.visible() then
    cmp.select_prev_item()
  else
    fallback()
  end
end

-- Until https://github.com/hrsh7th/nvim-cmp/issues/1716
-- (cmp.ConfirmBehavior.MatchSuffix) gets implemented, use this local wrapper
-- to choose between `cmp.ConfirmBehavior.Insert` and
-- `cmp.ConfirmBehavior.Replace`:
local confirm = function(entry)
  local behavior = cmp.ConfirmBehavior.Replace
  if entry then
    local completion_item = entry.completion_item
    local newText = ''
    if completion_item.textEdit then
      newText = completion_item.textEdit.newText
    elseif type(completion_item.insertText) == 'string' and completion_item.insertText ~= '' then
      newText = completion_item.insertText
    else
      newText = completion_item.word or completion_item.label or ''
    end

    -- How many characters will be different after the cursor position if we
    -- replace?
    local diff_after = math.max(0, entry.replace_range['end'].character + 1) - entry.context.cursor.col

    -- Does the text that will be replaced after the cursor match the suffix
    -- of the `newText` to be inserted? If not, we should `Insert` instead.
    if entry.context.cursor_after_line:sub(1, diff_after) ~= newText:sub(-diff_after) then
      behavior = cmp.ConfirmBehavior.Insert
    end
  end
  cmp.confirm({ select = true, behavior = behavior })
end

----------------------------------------------------------------------------------
----                                                                            --
----  General Setup                                                             --
----                                                                            --
----------------------------------------------------------------------------------

---@diagnostic disable-next-line: redundant-parameter
cmp.setup({
  experimental = {
    -- See also `toggle_ghost_text()` below.
    -- Disabling in favor of copilot virtual text for now.
    ghost_text = false,
  },

  formatting = {
    -- See: https://github.com/hrsh7th/nvim-cmp/wiki/Menu-Appearance
    format = function(entry, vim_item)
      -- Set `kind` to "$icon $kind".
      vim_item.kind = string.format('%s %s', lsp_kinds[vim_item.kind], vim_item.kind)
      vim_item.menu = ({
        buffer = '[Buffer]',
        nvim_lsp = '[LSP]',
        luasnip = '[LuaSnip]',
        nvim_lua = '[Lua]',
        latex_symbols = '[LaTeX]',
      })[entry.source.name]
      return vim_item
    end,
  },

  mapping = {
    ['<BS>'] = cmp.mapping(function(_fallback)
      smart_bs()
    end, { 'i', 's' }),

    ['<C-b>'] = cmp.mapping.scroll_docs(-4),

    -- Choose a choice using vim.ui.select (ugh);
    -- prettier would be a pop-up, but it will require a bit of config:
    -- https://github.com/L3MON4D3/LuaSnip/wiki/Misc#choicenode-popup
    -- ['<C-u>'] = require('luasnip.extras.select_choice'),

    ['<C-e>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.close()
      elseif has_luasnip and luasnip.choice_active() then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-j>'] = cmp.mapping(select_next_item),
    ['<Down>'] = cmp.mapping(select_next_item),
    ['<C-k>'] = cmp.mapping(select_prev_item),
    ['<Up>'] = cmp.mapping(select_prev_item),

    ['<C-o>'] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
       luasnip.expand_or_jump()
      elseif cmp.visible() then
        local entry = cmp.get_selected_entry()
        confirm(entry)
      elseif has_copilot_virtual_text() then
        -- accept up to and including the next white space to mimic zsh setup
        local resolved_key = vim.fn['copilot#Accept']('', '\\S*\\s*')
        vim.api.nvim_feedkeys(resolved_key, 'n', true)
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<C-y>'] = cmp.mapping(function(_fallback)
      local resolved_key = vim.fn['copilot#Accept']()
      vim.api.nvim_feedkeys(resolved_key, 'n', true)
    end),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif has_luasnip and luasnip.in_snippet() and luasnip.jumpable(-1) then
        luasnip.jump(-1)
      elseif in_leading_indent() then
        smart_bs(true) -- true means to dedent
      elseif in_whitespace() then
        smart_bs()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<Tab>'] = cmp.mapping(function(_fallback)
      if cmp.visible() then
        -- If there is only one completion candidate, use it.
        local entries = cmp.get_entries()
        if #entries == 1 then
          confirm(entries[1])
        else
          cmp.select_next_item()
        end
      elseif has_luasnip and luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      elseif in_whitespace() then
        smart_tab()
      else
        cmp.complete()
      end
    end, { 'i', 's' }),
  },

  completion = {
    completeopt = 'menu,menuone,noinsert',
  },

  snippet = {
    expand = function(args)
      if has_luasnip then
        luasnip.lsp_expand(args.body)
      end
    end,
  },

  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'nvim_lua' },
    { name = 'lbdb' },
    { name = 'nvim_lsp_signature_help' },
    {
      name = 'buffer',
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()    -- source from all buffers
        end
      },
      group_index = 2
    },
    { name = 'calc' },
    { name = 'emoji' },
    { name = 'path' },
  }),

  window = {
    completion = cmp.config.window.bordered({
      border = 'rounded',
      col_offset = -1,
      scrollbar = false,
      scrolloff = 3,
      -- Default for bordered() is 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
      -- Default for non-bordered, which we'll use here, is:
      winhighlight = 'Normal:Pmenu,FloatBorder:PmenuDarker,CursorLine:PmenuSel,Search:None',
    }),
    documentation = cmp.config.window.bordered({
      border = 'rounded',
      scrollbar = false,
      -- Default for bordered() is 'Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
      -- Default for non-bordered is 'FloatBorder:NormalFloat'
      -- Suggestion from: https://github.com/hrsh7th/nvim-cmp/issues/2042
      -- is to use 'NormalFloat:NormalFloat,FloatBorder:FloatBorder,CursorLine:Visual,Search:None'
      -- but this also seems to suffice:
      winhighlight = 'Normal:Pmenu,FloatBorder:PmenuDarker,CursorLine:PmenuSel,Search:None',
      -- winhighlight = 'CursorLine:Visual,Search:None',
    }),
  },
})

-- Only show ghost text at word boundaries, not inside keywords. Based on idea
-- from: https://github.com/hrsh7th/nvim-cmp/issues/2035#issuecomment-2347186210

local config = require('cmp.config')

local toggle_ghost_text = function()
  if vim.api.nvim_get_mode().mode ~= 'i' then
    return
  end

  local cursor_column = vim.fn.col('.')
  local current_line_contents = vim.fn.getline('.')
  local character_after_cursor = current_line_contents:sub(cursor_column, cursor_column)

  local should_enable_ghost_text = character_after_cursor == '' or vim.fn.match(character_after_cursor, [[\k]]) == -1

  local current = config.get().experimental.ghost_text
  if current ~= should_enable_ghost_text then
    config.set_global({
      experimental = {
        ghost_text = should_enable_ghost_text,
      },
    })
  end
end

-- vim.api.nvim_create_autocmd({ 'InsertEnter', 'CursorMovedI' }, {
--   callback = toggle_ghost_text,
-- })

--------------------------------------------------------------------------------
--                                                                            --
--  FileType Specific Configurations                                          --
--                                                                            --
--------------------------------------------------------------------------------

--cmp.setup.filetype('gitcommit', {
--  sources = cmp.config.sources({
--    { name = 'handles' },
--    { name = 'luasnip' },
--    {
--      name = 'lbdb',
--      filetypes = { 'gitcommit' }
--    },
--    { name = 'path' },
--    {
--      name = 'buffer',
--      option = {
--        get_bufnrs = function()
--          return vim.api.nvim_list_bufs()    -- source from all buffers
--        end
--      }
--    },
--    {
--      name = 'emoji',
--      insert = true
--    },
--  })
--})

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
--     {
--       name = 'cmdline',
--       option = {
--         ignore_cmds = { 'Man', '!' }
--       }
--     }
--   })
-- })
