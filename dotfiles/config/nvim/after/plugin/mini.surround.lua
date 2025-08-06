--------------------------------------------------------------------------------
--                                                                            --
--  Mini.Surround                                                             --
--                                                                            --
--  https://github.com/echasnovski/mini.diff                                  --
--                                                                            --
--  saiW-      surround the Word with -                                       --
--  Vsa_       surround the whole line with _                                 --
--  sa__       surround the whole line with _ (this is right, dot rep works)  --
--                                                                            --
--------------------------------------------------------------------------------

local has_minisurround, minisurround = pcall(require, 'mini.surround')
if not has_minisurround then
  return
end

-------------
--  Setup  --
-------------

minisurround.setup()
