--------------------------------------------------------------------------------
--                                                                            --
--  Obsession                                                                 --
--                                                                            --
--  https://github.com/tpope/vim-obsession                                    --
--                                                                            --
--------------------------------------------------------------------------------

if not vim.fn.exists(':Obsession') then
  return
end

----------------
--  Mappings  --
----------------

vim.keymap.set('n', '<Localleader>ss', ':Obsession ~/.config/nvim/sessions/', {remap = false})
vim.keymap.set('n', '<Localleader>sr', function()
  local sessions_dir = vim.fn.expand('~/.config/nvim/sessions')
  local files = vim.fn.globpath(sessions_dir, '*', false, true)
  if #files == 0 then
    vim.notify('No sessions found', vim.log.levels.WARN)
    return
  end

  local items = {}
  for _, path in ipairs(files) do
    table.insert(items, vim.fn.fnamemodify(path, ':t'))
  end

  local minipick = require('mini.pick')
  -- auto-show preview: feed <Tab> which the getcharstr loop will consume
  -- as its first keypress after the picker window draws
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)

  minipick.start({
    source = {
      items   = items,
      name    = 'Sessions',
      preview = function(buf_id, item)
        local path = sessions_dir .. '/' .. item
        local ok, lines = pcall(vim.fn.readfile, path)
        if not ok then return end

        local preview = {}
        local clean = function(f)
          return vim.fn.fnamemodify(f:gsub('\\', ''), ':~:.')
        end

        -- working directory
        for _, line in ipairs(lines) do
          local dir = line:match('^cd (.+)$')
          if dir then
            table.insert(preview, '## Working directory')
            table.insert(preview, '')
            table.insert(preview, '  ' .. dir)
            table.insert(preview, '')
            break
          end
        end

        -- open tabs: each tabnext/edit pair is the active file in a tab;
        -- the first edit before any tabnext is tab 1
        local tabs = {}
        local past_tabnew = false
        for _, line in ipairs(lines) do
          if line:match('^tabnew ') then
            past_tabnew = true
          end
          if past_tabnew then
            local file = line:match('^edit (.+)$')
            if file then
              table.insert(tabs, clean(file))
            end
          end
        end

        if #tabs > 0 then
          table.insert(preview, '## Tabs (' .. #tabs .. ')')
          table.insert(preview, '')
          for i, tab in ipairs(tabs) do
            table.insert(preview, '  ' .. i .. '. ' .. tab)
          end
          table.insert(preview, '')
        end

        -- all open buffers from badd lines
        local buffers = {}
        for _, line in ipairs(lines) do
          local file = line:match('^badd %+%d+ (.+)$')
          if file then
            local cleaned = clean(file)
            if cleaned ~= '/' and not cleaned:match('^%{%{') then
              table.insert(buffers, cleaned)
            end
          end
        end

        if #buffers > 0 then
          table.insert(preview, '## Buffers (' .. #buffers .. ')')
          table.insert(preview, '')
          for _, buf in ipairs(buffers) do
            table.insert(preview, '  - ' .. buf)
          end
        end

        vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, preview)
        vim.bo[buf_id].syntax = 'markdown'
      end,
      choose  = function(item)
        if item then
          vim.schedule(function()
            vim.cmd('source ' .. vim.fn.fnameescape(sessions_dir .. '/' .. item))
          end)
        end
      end,
    },
  })
end, {remap = false})
vim.keymap.set('n', '<Localleader>sp', ':Obsession<CR>', {remap = false})
vim.keymap.set('n', '<Localleader>sn', function()
  if vim.fn.exists(':Obsession') then
    local session = buell.util.split_str(vim.v.this_session, '/')
    local sname   = session[#session] or ''
    if #sname then
      print(sname)
    end
  end
end
, {remap = false})
