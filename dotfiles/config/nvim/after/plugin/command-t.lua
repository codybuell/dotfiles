vim.g.command_t_loaded = 0     -- temp hack to prevent ruby version loading

require('wincent.commandt').setup({
  always_show_dot_files = true,
  height = 30,
  scanners = {
    git = {
      submodules = false,
      untracked = true,
    },
  },
  finders = {
    wiki = {
      command = function(directory)
        vim.g.buell_called_wiki = directory
        local len = directory:len() + 1
        if directory ~= '' and directory ~= '.' and directory ~= './' then
          directory = vim.fn.shellescape(directory)
        end
        return 'find ' .. directory .. ' -type f ! -name \\.DS_Store | sed "s/^.\\{' .. len .. '\\}//;s/^./\'&/;s/.$/&\'/" | xargs printf "%s\\0"'
      end,
      open = function(item, kind)
        local file_ext = item:match("^.+%.(.+)$")
        local external = {
          'pdf', 'png', 'jpg', 'jpeg', 'xls', 'xlsx', 'doc', 'docx',
        }
        local file = vim.g.buell_called_wiki .. '/' .. item
        if buell.util.has_value(external, file_ext) then
          vim.fn['netrw#BrowseX'](file, 0)
        else
          vim.cmd(kind .. ' ' .. file)
        end
      end,
    },
    ack = {
      command = function(directory)
        local command = 'ack -f --print0'
        if directory ~= '' and directory ~= '.' and directory ~= './' then
          directory = vim.fn.shellescape(directory)
          command = command .. ' -- ' .. directory
        end
        return command
      end,
    },
  },
})

vim.api.nvim_create_user_command('CommandTAck', function(command)
  require('wincent.commandt').finder('ack', command.args)
end, {
  complete = 'dir',
  nargs = '?',
})

vim.api.nvim_create_user_command('CommandTWiki', function(command)
  require('wincent.commandt').finder('wiki', command.args)
end, {
  complete = 'dir',
  nargs = '?',
})

-- supplement vims wildignore for command-t searches
vim.g.CommandTWildIgnore = vim.o.wildignore
  .. ',*/.git/*'
  .. ',*/.hg/*'
  .. ',*/bower_components/*'
  .. ',*/tmp/*'
  .. ',*.class'
  .. ',*/classes/*'
  .. ',*/build/*'
  .. ',*.DS_Store'
