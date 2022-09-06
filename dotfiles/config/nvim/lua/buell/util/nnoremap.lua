-- Normal Mode Non-Recursive Mapping
--
-- Creates mappings of provided lhs rhs.
--
-- @param lhs: target of the map
-- @param rhs: action of map
-- @return nil
local nnoremap = function(lhs, rhs)
    vim.api.nvim_buf_set_keymap(0, 'n', lhs, rhs, {noremap = true, silent = true})
end

return nnoremap
