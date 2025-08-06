--------------------------------------------------------------------------------
--                                                                            --
--  Mini.AI                                                                   --
--                                                                            --
--  https://github.com/echasnovski/mini.diff                                  --
--                                                                            --
--------------------------------------------------------------------------------

local has_miniai, miniai = pcall(require, 'mini.ai')
if not has_miniai then
  return
end

-------------
--  Setup  --
-------------

miniai.setup()
