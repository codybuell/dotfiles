--------------------------------------------------------------------------------
--                                                                            --
--  Mini.Extra                                                                --
--                                                                            --
--  Additions for:                                                            --
--    - mini.pick                                                             --
--    - mini.ai                                                               --
--    - mini.hipatterns                                                       --
--                                                                            --
--  https://github.com/echasnovski/mini.nvim/blob/main/readmes/mini-extra.md  --
--                                                                            --
--------------------------------------------------------------------------------

local has_miniextra, miniextra = pcall(require, 'mini.extra')
if has_miniextra then

  -------------
  --  Setup  --
  -------------

  miniextra.setup()

end
