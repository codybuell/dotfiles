--------------------------------------------------------------------------------
--                                                                            --
--  Vim Tmux Runner                                                           --
--                                                                            --
--  https://github.com/christoomey/vim-tmux-runner                            --
--                                                                            --
--------------------------------------------------------------------------------

if vim.fn.exists(':VtrAttachToPane') then

  ----------------------
  --  Configurations  --
  ----------------------

  -- for languages with syntactic whitespace, appends new line to lines
  -- sent needed for closing out contexts in python for example
  vim.g.VtrAppendNewline = 1

  -- don't strip whitespace, needed for python
  vim.g.VtrStripLeadingWhitespace = 0

  -- don't clear empty lines, needed for python
  vim.g.VtrClearEmptyLines = 0

  -- language overrides
  vim.g.vtr_filetype_runner_overrides = {
    python = 'python3 {file}',
  }

  -- don't send clear command before executing, want to easily compare output
  vim.g.VtrClearBeforeSend = 0

  -- clear sequence to send <C-c> clear <CR>
  -- (insert mode -> ctrl-v -> desired ctrl sequence)
  vim.g.VtrClearSequence = "clear"

  ----------------
  --  Mappings  --
  ----------------

  vim.keymap.set('n', '<Leader>ra', ':VtrAttachToPane<CR>', {remap = false})
  vim.keymap.set('n', '<Leader>rf', ':VtrSendFile<CR>', {remap = false})
  vim.keymap.set('n', '<Leader>rl', ':VtrSendLinesToRunner<CR>', {remap = false})
  vim.keymap.set('n', '<Leader>re', ':VtrSendCommandToRunner<CR>', {remap = false})
  vim.keymap.set('n', '<Leader>rr', ':VtrFlushCommand<CR>', {remap = false})
  vim.keymap.set('n', '<Leader>rc', ':VtrClearRunner<CR>', {remap = false})

end
