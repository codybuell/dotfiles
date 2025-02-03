--------------------------------------------------------------------------------
--                                                                            --
--  Mini.Pick                                                                 --
--                                                                            --
--  https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-pick.md   --
--                                                                            --
--------------------------------------------------------------------------------

local has_minipick, minipick = pcall(require, 'mini.pick')
if has_minipick then

  ---------------
  --  Helpers  --
  ---------------

  -- helper to center the picker window
  local function get_centered_window_config()
    local max_width  = 150
    local max_height = 60

    local editor_width  = vim.api.nvim_win_get_width(0)
    local editor_height = vim.api.nvim_win_get_height(0)
    local width         = math.min(editor_width - 50, max_width)
    local height        = math.min(editor_height - 10, max_height)
    local row           = math.floor((editor_height - height) / 2)
    local col           = math.floor((editor_width - width) / 2)

    return {
      relative = 'editor',
      row      = row,
      col      = col,
      width    = width,
      height   = height,
      anchor   = 'NW',
      style    = 'minimal'
    }
  end

  local function initialize_config()
    minipick.setup({
      window = {
        config = get_centered_window_config()
      }
    })
  end

  -------------
  --  Setup  --
  -------------

  initialize_config()

  ----------------
  --  Mappings  --
  ----------------

  vim.keymap.set('n', '<Leader>t', '<CMD>Pick files<CR>', { remap = true, silent = true })
  vim.keymap.set('n', '<Leader>T', '<CMD>Pick grep_live tool="rg"<CR>', { remap = true, silent = true })
  vim.keymap.set('n', '<Leader>h', '<CMD>Pick help<CR>', { remap = true, silent = true })
  vim.keymap.set('n', '<Leader>b', '<CMD>Pick buffers<CR>', { remap = true, silent = true })

  -- pick files from the current buffers directory
  vim.keymap.set('n', '<Leader>.', function()
    local buf_dir = vim.fn.expand('%:p:h')
    minipick.builtin.files({}, { source = { cwd = buf_dir } })
  end, { silent = true })

  -- ripgrep files from the current buffers directory
  vim.keymap.set('n', '<Leader>>', function()
    local buf_dir = vim.fn.expand('%:p:h')
    minipick.builtin.grep_live({ tool = 'rg' }, { source = { cwd = buf_dir } })
  end, { silent = true })

  -- pick files from notes directory
  vim.keymap.set('n', '<Leader>n', function()
    local notes_dir = vim.fn.fnamemodify('{{ Notes }}', ':p')
    minipick.builtin.files({}, { source = { cwd = notes_dir } })
  end, { silent = true })

  -- ripgrep files from notes directory
  vim.keymap.set('n', '<Leader>N', function()
    local notes_dir = vim.fn.fnamemodify('{{ Notes }}', ':p')
    minipick.builtin.grep_live({ tool = 'rg' }, { source = { cwd = notes_dir } })
  end, { silent = true })

  --------------
  --  Colors  --
  --------------

  local pinnacle = require('wincent.pinnacle')

  vim.cmd("highlight! link MiniPickMatchCurrent Directory")
  vim.cmd("highlight! link MiniPickBorder PmenuDarker")
  pinnacle.set('MiniPickBorderBusy', {bg = pinnacle.bg('Pmenu'), fg = pinnacle.fg('Directory')})
  pinnacle.set('MiniPickBorderText', {bg = pinnacle.bg('Pmenu'), fg = pinnacle.fg('Directory')})
  pinnacle.set('MiniPickPrompt', {bg = pinnacle.bg('Pmenu'), fg = pinnacle.fg('Directory')})

  --------------------
  --  Autocommands  --
  --------------------

  local augroup = buell.util.augroup
  local autocmd = buell.util.autocmd

  augroup('BuellMiniPick', function()
    autocmd('VimResized', '*', function()
      initialize_config()
    end)
  end)

end
