--------------------------------------------------------------------------------
--                                                                            --
--  DAP UI                                                                    --
--                                                                            --
--  https://github.com/rcarriga/nvim-dap-ui                                   --
--                                                                            --
--------------------------------------------------------------------------------

local has_dap, dap = pcall(require, 'dap')
local has_dapui, dapui = pcall(require, 'dapui')
if has_dap and has_dapui then

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
  dap.listeners.before.event_terminated.dapui_config = function()
    dapui.close()
  end
  dap.listeners.before.event_exited.dapui_config = function()
    dapui.close()
  end

  ----------------
  --  Mappings  --
  ----------------

  vim.keymap.set("n", "<leader>dx", '<CMD>lua require("dapui").close()<CR>', {})

end
