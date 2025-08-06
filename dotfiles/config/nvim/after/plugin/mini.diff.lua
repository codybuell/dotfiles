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

--------------
--  Colors  --
--------------

local pinnacle = require('wincent.pinnacle')

pinnacle.set('MiniDiffSignAdd', {
  bg = pinnacle.bg('SignColumn'),
  fg = pinnacle.fg('DiffAdd'),
  -- bold = true,
  italic = true,
})
pinnacle.set('MiniDiffSignChange', {
  bg = pinnacle.bg('SignColumn'),
  fg = pinnacle.fg('DiffText'),
  -- bold = true,
  italic = true,
})
pinnacle.set('MiniDiffSignDelete', {
  bg = pinnacle.bg('SignColumn'),
  fg = pinnacle.fg('DiffDelete'),
  -- bold = true,
  italic = true,
})

-- overlay highlights for code background, only change the background
-- toggled visibility with :lua MiniDiff.toggle_overlay()
pinnacle.set('MiniDiffOverAdd', {
  bg = pinnacle.bg('DiffAdd'),
})
pinnacle.set('MiniDiffOverChange', {
  bg = pinnacle.bg('DiffText'),
})
pinnacle.set('MiniDiffOverDelete', {
  bg = pinnacle.bg('DiffDelete'),
})

----------------
--  Mappings  --
----------------

vim.keymap.set('n', '<Leader>gd', ':lua MiniDiff.toggle_overlay()<CR>', {remap = false, silent = true})
