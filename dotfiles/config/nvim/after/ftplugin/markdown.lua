vim.opt_local.conceallevel = 1    -- conceal markdown syntax on markdown buffers
vim.opt_local.tabstop      = 2    -- spaces per tab
vim.opt_local.shiftwidth   = 2    -- spaces per tab

-- list wrap indentation to match where text starts after the list marker
vim.opt_local.formatlistpat = '^\\s*-\\s\\[.\\]\\s*\\|^\\s*\\d\\+\\.\\s\\+\\|^\\s*[-*+]\\s\\+\\|^\\[^\\ze[^\\]]\\+\\]:\\&^.\\{4\\}'
vim.opt_local.breakindent = true
vim.opt_local.breakindentopt = "list:-1,shift:0,sbr"

-- set custom folding for markdown
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.buell.fold.markdown()"

-- ensure b:undo_ftplugin exists and initialize if necessary
if vim.b.undo_ftplugin == nil then
  vim.b.undo_ftplugin = ''
end

-- append commands to reset fold options when the file type plugin is cleared
vim.b.undo_ftplugin = vim.b.undo_ftplugin .. ' | setlocal foldmethod< foldtext< foldexpr<'
