--------------------------------------------------------------------------------
--                                                                            --
--  DAP Go                                                                    --
--                                                                            --
--  https://github.com/leoluz/nvim-dap-go                                     --
--                                                                            --
--------------------------------------------------------------------------------

local has_dapgo, dapgo = pcall(require, 'dap-go')
if not has_dapgo then
  return
end

vim.defer_fn(function()

  -------------
  --  Setup  --
  -------------

  dapgo.setup()

end, 100)
