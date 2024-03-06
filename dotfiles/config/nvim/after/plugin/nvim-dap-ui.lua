local dap = require("dap")
local dapui = require("dapui")

dapui.setup({
  icons = { expanded = "↔", collapsed = "-", current_frame = "→" },
  controls = {
    icons = {
      pause = "⏸",
      play = "▷",
      step_into = "↓",
      step_over = "↷",
      step_out = "↑",
      step_back = "↶",
      run_last = "↻",
      terminate = "□",
      disconnect = "⏻"
    }
  }
})

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

vim.keymap.set("n", "<leader>dx", '<CMD>lua require("dapui").close()<CR>', {})
