local dap = require("dap")
-- local pinnacle = require("wincent.pinnacle")

vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint, {})
vim.keymap.set("n", "<leader>dc", dap.continue, {})

-- vim.api.nvim_set_hl(0, "blue",   { fg = "#3d59a1", bg = pinnacle.bg("LineNr")})
-- vim.api.nvim_set_hl(0, "green",  { fg = "#9ece6a", bg = pinnacle.bg("LineNr")})
-- vim.api.nvim_set_hl(0, "yellow", { fg = "#FFFF00", bg = pinnacle.bg("LineNr")})
-- vim.api.nvim_set_hl(0, "orange", { fg = "#f09000", bg = pinnacle.bg("LineNr")})

vim.fn.sign_define('DapBreakpoint',          { text='•', texthl='DiagnosticSignInfo',   linehl='DapBreakpoint', numhl='DapBreakpoint' })
vim.fn.sign_define('DapBreakpointCondition', { text='•', texthl='DiagnosticSignInfo',   linehl='DapBreakpoint', numhl='DapBreakpoint' })
vim.fn.sign_define('DapBreakpointRejected',  { text='•', texthl='DiagnosticSignWarn', linehl='DapBreakpoint', numhl='DapBreakpoint' })
vim.fn.sign_define('DapStopped',             { text='→', texthl='DiagnosticSignError',  linehl='DapBreakpoint', numhl='DapBreakpoint' })
vim.fn.sign_define('DapLogPoint',            { text='•', texthl='FoldColumn', linehl='DapBreakpoint', numhl='DapBreakpoint' })


