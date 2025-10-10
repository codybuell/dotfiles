-- Underline
--
-- Underlines text with the provided character.
--   :Underline      gives underlining like --------------- (default)
--   :Underline =    gives underlining like ===============
--   :Underline -=   gives underlining like -=-=-=-=-=-=-=-
--   :Underline ~+-  gives underlining like ~+-~+-~+-~+-~+-
--
-- @param nil
-- @return nil

M = {}

-- Store the last used character for repeatability
local last_chars = nil

-- Public function to clear cache (for insert mode mapping)
function M.clear_cache()
  last_chars = nil
end

-- Main function - sets up operatorfunc and clears cache
function M.prompt()
  last_chars = nil  -- Clear cache so we prompt again
  vim.go.operatorfunc = "v:lua.require'buell.util.underline'.callback"
  return "g@l"
end

-- Callback function - does the actual work
function M.callback()
  local chars

  -- Prompt if no cached character
  if not last_chars then
    vim.fn.inputsave()
    chars = vim.fn.input('Underline Character: ')
    vim.fn.inputrestore()
    if chars == '' then
      chars = '-'
    end
    last_chars = chars  -- Cache for dot-repeat
  else
    chars = last_chars  -- Use cached character
  end

  -- Always recalculate based on CURRENT line
  local cur_line  = vim.api.nvim_get_current_line()
  local columns   = vim.fn.virtcol('$')
  local pattern   = string.rep(chars, (columns / chars:len()) + 1):sub(1, columns - 1)
  local _, leading_spaces = cur_line:find('^%s+')
  local uline
  if leading_spaces then
    uline = cur_line:sub(1, leading_spaces) .. pattern:sub(1, pattern:len() - leading_spaces)
  else
    uline = pattern
  end

  -- Insert underline and blank line
  local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, current_line_num, current_line_num, false, {uline, ''})
  vim.api.nvim_win_set_cursor(0, {current_line_num + 2, 0})
end

return M
