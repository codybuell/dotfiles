--------------------------------------------------------------------------------
--                                                                            --
--  Ferret                                                                    --
--                                                                            --
--  https://github.com/wincent/ferret                                         --
--                                                                            --
--------------------------------------------------------------------------------

---------------------
--  Configuration  --
---------------------

vim.g.FerretExecutableArguments = {
  --   rg = '--vimgrep --no-heading --max-columns 4096 --hidden'
  rg = '--vimgrep --no-heading --no-config --max-columns 4096 --hidden --glob !.git',
}
