require('copilot').setup({
  panel = {
    enabled = false,             -- using copilot-cmp instead
    auto_refresh = false,
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      open = "<M-CR>"
    },
    layout = {
      position = "bottom",       -- | top | left | right
      ratio = 0.4
    },
  },
  suggestion = {
    enabled = false,             -- using copilot-cmp instead
    auto_trigger = false,
    debounce = 75,
    keymap = {
      accept = "<M-l>",
      accept_word = "<C-o>",
      accept_line = false,
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
  },
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false,
  },
  copilot_node_command = 'node', -- Node.js version must be > 18.x
  server_opts_overrides = {},
})

-- mapping to accept one word at a time
vim.keymap.set("i", "<C-o>", function()
  require("copilot.suggestion").accept_word()
  require("copilot.suggestion").next()
end, { desc = "[copilot] accept (word) and next suggestion" })
