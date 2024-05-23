require('copilot').setup({
  panel = {
    enabled = false,             -- using copilot-cmp instead
  },
  suggestion = {
    enabled = false,             -- using copilot-cmp instead
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
