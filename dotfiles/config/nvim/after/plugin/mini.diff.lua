--------------------------------------------------------------------------------
--                                                                            --
--  Mini.Diff                                                                 --
--                                                                            --
--  https://github.com/echasnovski/mini.diff                                  --
--                                                                            --
--------------------------------------------------------------------------------

local has_minidiff, minidiff = pcall(require, 'mini.diff')
if has_minidiff then

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

end
