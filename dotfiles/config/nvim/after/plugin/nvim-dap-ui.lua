--------------------------------------------------------------------------------
--                                                                            --
--  DAP UI                                                                    --
--                                                                            --
--  https://github.com/rcarriga/nvim-dap-ui                                   --
--                                                                            --
--------------------------------------------------------------------------------

local has_dap, dap = pcall(require, 'dap')
local has_dapui, dapui = pcall(require, 'dapui')
if not has_dap or not has_dapui then
  return
end

vim.defer_fn(function()

  ---------------------
  --  Configuration  --
  ---------------------

  local config = {
    icons = {
      expanded      = "↔",
      collapsed     = "-",
      current_frame = "→",
    },
    controls = {
      icons = {
        pause       = "⏸",
        play        = "▷",
        step_into   = "↓",
        step_over   = "↷",
        step_out    = "↑",
        step_back   = "↶",
        run_last    = "↻",
        terminate   = "□",
        disconnect  = "⏻",
      }
    }
  }

  -------------
  --  Setup  --
  -------------

  dapui.setup(config)

  dap.listeners.before.attach.dapui_config = function()
    dapui.open()
  end
  dap.listeners.before.launch.dapui_config = function()
    dapui.open()
  end
  -- dap.listeners.before.event_terminated.dapui_config = function()
  --   dapui.close()
  -- end
  -- dap.listeners.before.event_exited.dapui_config = function()
  --   dapui.close()
  -- end

  ----------------
  --  Mappings  --
  ----------------

  vim.keymap.set("n", "<localleader>o", '<CMD>lua require("dapui").open()<CR>', {})
  vim.keymap.set("n", "<localleader>x", '<CMD>lua require("dapui").close()<CR>', {})

  --------------
  --  Colors  --
  --------------

  -- local pinnacle = require('wincent.pinnacle')

  -- vim.cmd("highlight clear WinBar")
  -- vim.cmd("highlight! link WinBar Status2")
  -- vim.cmd("highlight clear WinBarNC")
  -- vim.cmd("highlight! link WinBarNC Status2")
  -- pinnacle.set('DapUIPlayPause', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIPlayPause')})
  -- pinnacle.set('DapUIPlayPauseNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIPlayPauseNC')})
  -- pinnacle.set('DapUIStepInto', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepInto')})
  -- pinnacle.set('DapUIStepIntoNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepIntoNC')})
  -- pinnacle.set('DapUIStepOver', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepOver')})
  -- pinnacle.set('DapUIStepOverNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepOverNC')})
  -- pinnacle.set('DapUIStepOut', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepOut')})
  -- pinnacle.set('DapUIStepOutNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepOutNC')})
  -- pinnacle.set('DapUIStepBack', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepBack')})
  -- pinnacle.set('DapUIStepBackNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStepBackNC')})
  -- pinnacle.set('DapUIRestart', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIRestart')})
  -- pinnacle.set('DapUIRestartNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIRestartNC')})
  -- pinnacle.set('DapUIStop', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStop')})
  -- pinnacle.set('DapUIStopNC', {bg = pinnacle.bg('Status2'), fg = pinnacle.fg('DapUIStopNC')})

end, 100)
