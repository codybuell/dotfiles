local helpers = {}

helpers.nnoremap = function (lhs, rhs)
  vim.api.nvim_buf_set_keymap(0, 'n', lhs, rhs, {noremap = true, silent = true})
end

helpers.augroup = function (group, fn)
  vim.api.nvim_command("augroup " .. group)
  vim.api.nvim_command("autocmd!")
  fn()
  vim.api.nvim_command("augroup END")
end

helpers.check_command_t = function()
  for _, winnr in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buffer   = vim.api.nvim_win_get_buf(winnr)
    local filetype = vim.api.nvim_buf_get_option(buffer, 'filetype')
    if filetype == 'command-t' then
      vim.api.nvim_win_set_option(winnr, 'signcolumn', 'no')
      vim.api.nvim_win_set_option(winnr, 'nu', false)
      vim.api.nvim_win_set_option(winnr, 'rnu', false)
    end
  end
end

return helpers
