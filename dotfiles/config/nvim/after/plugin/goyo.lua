--------------------------------------------------------------------------------
--                                                                            --
--  GOYO                                                                      --
--                                                                            --
--  https://github.com/junegunn/goyo.vim                                      --
--                                                                            --
--------------------------------------------------------------------------------

----------------------
--  Configurations  --
----------------------

-- width of text (default: 80)
vim.g.goyo_width = 160

-- height of text (default: 85%)
vim.g.goyo_height = '85%'

-- show line numbers (default: 0)
vim.g.goyo_linenr = 0

---------------
--  Helpers  --
---------------

local goyo_enter = function ()
  vim.cmd("silent !tmux set status off")
  vim.cmd("silent !tmux list-panes -F '\\#F' | grep -q Z || tmux resize-pane -Z")
  vim.opt.statusline = ''
  vim.opt.laststatus = 0
  vim.opt.showmode   = false
  vim.opt.showcmd    = false
  vim.opt.scrolloff  = 999
  vim.cmd("Limelight")
  require('cmp').setup.buffer { enabled = false }
  vim.wo.statusline = "%!luaeval('buell.statusline.wordcountprogress()')"
end

local goyo_leave = function ()
  vim.cmd("silent !tmux set status on")
  vim.cmd("silent !tmux list-panes -F '\\#F' | grep -q Z && tmux resize-pane -Z")
  vim.opt.laststatus = 2
  vim.opt.showmode   = true
  vim.opt.showcmd    = false
  vim.opt.scrolloff      = 4
  vim.cmd("Limelight!")
  require('cmp').setup.buffer { enabled = true }
  buell.color.update()
  buell.statusline.update()
end

--------------------
--  Autocommands  --
--------------------

local augroup = buell.util.augroup
local autocmd = buell.util.autocmd

augroup('BuellGoyo', function()
  -- manually calling in buell#helpers#CycleViews to avoid artifacting
  -- autocmd! User GoyoEnter nested call <SID>goyo_enter()
  -- autocmd! User GoyoLeave nested call <SID>goyo_leave()
  autocmd('User', 'GoyoEnter', goyo_enter, {bang=true})
  autocmd('User', 'GoyoLeave', goyo_leave, {bang=true})
  -- on window resize, if goyo is active, do <c-w>= to resize the window
  -- autocmd! VimResized * if exists('#goyo') | exe "normal \<c-w>=" | endif
  autocmd('VimResized', '*', function()
    if vim.fn.exists('#goyo') then
      vim.cmd("normal \\<c-w>=")
    end
  end, {bang=true})
end)
