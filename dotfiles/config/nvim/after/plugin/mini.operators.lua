--------------------------------------------------------------------------------
--                                                                            --
--  Mini.Operators                                                            --
--                                                                            --
--  https://github.com/echasnovski/mini.diff                                  --
--                                                                            --
--------------------------------------------------------------------------------

local has_minioperators, minioperators = pcall(require, 'mini.operators')
if not has_minioperators then
  return
end

-------------
--  Setup  --
-------------

minioperators.setup()
