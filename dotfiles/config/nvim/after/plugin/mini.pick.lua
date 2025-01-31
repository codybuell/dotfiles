--------------------------------------------------------------------------------
--                                                                            --
--  Mini.Pick                                                                 --
--                                                                            --
--  https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-pick.md   --
--                                                                            --
--------------------------------------------------------------------------------

local has_minipick, minipick = pcall(require, 'mini.pick')
if has_minipick then
  minipick.setup()

  ----------------
  --  Mappings  --
  ----------------

  vim.keymap.set('n', '<Leader>t', '<CMD>Pick files<CR>', { remap = true, silent = true })
  vim.keymap.set('n', '<Leader>h', '<CMD>Pick help<CR>', { remap = true, silent = true })
  vim.keymap.set('n', '<Leader>b', '<CMD>Pick buffers<CR>', { remap = true, silent = true })

  -- pick files from the current buffers directory
  vim.keymap.set('n', '<Leader>.', function()
    local buf_dir = vim.fn.expand('%:p:h')
    minipick.builtin.files({}, { source = { cwd = buf_dir } })
  end, { silent = true })

  -- pick files from notes directory
  vim.keymap.set('n', '<Leader>n', function()
    local notes_dir = vim.fn.fnamemodify('{{ Notes }}', ':p')
    minipick.builtin.files({}, { source = { cwd = notes_dir } })
  end, { silent = true })
end
