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
  fg = pinnacle.brighten('DiffAdd', 0.35).bg,
  bg = pinnacle.bg('SignColumn'),
  -- bold = true,
  italic = true,
})

pinnacle.set('MiniDiffSignChange', {
  fg = pinnacle.brighten('DiffText', 0.35).bg,
  bg = pinnacle.bg('SignColumn'),
  -- bold = true,
  italic = true,
})

pinnacle.set('MiniDiffSignDelete', {
  fg = pinnacle.brighten('DiffDelete', 0.35).bg,
  bg = pinnacle.bg('SignColumn'),
  -- bold = true,
  italic = true,
})

-- overlay highlights for code background, only change the background
-- toggled visibility with :lua MiniDiff.toggle_overlay() (mapped to <Leader>gd)
pinnacle.set('MiniDiffOverAdd', {
  bg = pinnacle.bg('DiffAdd'),
})

pinnacle.set('MiniDiffOverChange', {
  fg = pinnacle.bg('Search'),
  bg = pinnacle.bg('DiffText'),
})

pinnacle.set('MiniDiffOverContext', {
  bg = pinnacle.bg('DiffText'),
})

pinnacle.set('MiniDiffOverDelete', {
  bg = pinnacle.bg('DiffDelete'),
})

----------------
--  Mappings  --
----------------

vim.keymap.set('n', '<Leader>gd', ':lua MiniDiff.toggle_overlay()<CR>', {remap = false, silent = true})
