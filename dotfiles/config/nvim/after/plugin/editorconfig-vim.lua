--------------------------------------------------------------------------------
--                                                                            --
--  EditorConfig                                                              --
--                                                                            --
--  https://github.com/editorconfig/editorconfig-vim                          --
--                                                                            --
--------------------------------------------------------------------------------

if not vim.fn.exists(':EditorConfigReload') then
  return
end

--------------------
--  Autocommands  --
--------------------

-- local augroup = buell.util.augroup
-- local autocmd = buell.util.autocmd

-- augroup('BuellEditorConfig', function()
--   -- Disable EditorConfig for special buffers and unnamed buffers
--   autocmd('BufNew,BufEnter', '*', function(ev)
--     local bt = vim.bo[ev.buf].buftype
--     local name = vim.api.nvim_buf_get_name(ev.buf)
--     if bt ~= '' or name == '' then
--       vim.b[ev.buf].EditorConfig_disable = 1
--     end
--   end)
-- end)

vim.api.nvim_create_augroup('EditorConfigGuards', { clear = true })
vim.api.nvim_create_autocmd({ 'BufNew', 'BufEnter' }, {
  group = 'EditorConfigGuards',
  callback = function(ev)
    local bt = vim.bo[ev.buf].buftype
    local name = vim.api.nvim_buf_get_name(ev.buf)
    if bt ~= '' or name == '' then
      vim.b[ev.buf].EditorConfig_disable = 1
    end
  end,
})
