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
local underline = function ()
  -- prompt for character, default to -
  vim.fn.inputsave()
  local chars = vim.fn.input('Underline Character: ')
  vim.fn.inputrestore()
  if chars == '' then
    chars = '-'
  end

  -- build underline string
  local uline
  local cur_line  = vim.api.nvim_get_current_line()
  local columns   = vim.fn.virtcol('$')
  local pattern   = string.rep(chars, (columns / chars:len()) + 1):sub(1, columns - 1)
  local _, leading_spaces = cur_line:find('^%s+')
  if leading_spaces then
    uline = cur_line:sub(1, leading_spaces) .. pattern:sub(1, pattern:len() - leading_spaces)
  else
    uline = pattern
  end

  -- put it in place
  vim.cmd("put = '" .. uline .. "'")
  vim.cmd(':normal o')
end

return underline
