--------------------------------------------------------------------------------
--                                                                            --
--  Mini.Diff                                                                 --
--                                                                            --
--  https://github.com/echasnovski/mini.diff                                  --
--                                                                            --
--------------------------------------------------------------------------------

local has_minidiff, minidiff = pcall(require, 'mini.diff')
if not has_minidiff then
  return
end

-------------
--  Setup  --
-------------

minidiff.setup()

----------------
--  Mappings  --
----------------

local augroup = require('buell.util.augroup')
local autocmd = require('buell.util.autocmd')

augroup('MiniDiffMapping', function()
  autocmd('FileType', '*', function()
    if vim.bo.filetype ~= 'codecompanion' then
      vim.keymap.set('n', '<Leader>gd', ':lua MiniDiff.toggle_overlay()<CR>', {
        buffer = true,
        remap = false,
        silent = true
      })
    end
  end)
end)
