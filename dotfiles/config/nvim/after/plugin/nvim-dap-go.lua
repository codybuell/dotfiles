--------------------------------------------------------------------------------
--                                                                            --
--  DAP Go                                                                    --
--                                                                            --
--  https://github.com/leoluz/nvim-dap-go                                     --
--                                                                            --
--------------------------------------------------------------------------------

local has_dapgo, dapgo = pcall(require, 'dap-go')
if has_dapgo then

  -------------
  --  Setup  --
  -------------

  dapgo.setup()

end
