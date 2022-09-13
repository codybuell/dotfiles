local create_entry = function (wiki)
  if wiki == 'journal' then
    -- handle counts passed to call
    local date = os.time()
    if vim.v.count then
      date = date + (vim.v.count * 24 * 60 * 60)
    end

    -- set vars we need
    local year  = os.date('%Y', date)
    local month = os.date('%m', date)
    local day   = os.date('%d', date)
    local path  = '{{ Journal }}' .. '/' .. os.date('%Y') .. '/' .. os.date('%m')
    local file  = year .. '.' .. month .. '.' .. day .. '.md'

    -- make directory if needed
    buell.util.create_directories(path)

    -- edit the file
    vim.cmd('edit ' .. path .. '/' .. file)
  elseif wiki == 'note' or wiki == 'codex' then
    -- set prompt and path
    local prompt
    local path
    if wiki == 'note' then
      prompt = 'Note name: '
      path   = '{{ Notes }}'
    elseif wiki == 'codex' then
      prompt = 'Codex name: '
      path   = '{{ Codex }}'
    end

    -- prompt for note name
    vim.fn.inputsave()
    local name = vim.fn.input(prompt)
    vim.fn.inputrestore()

    -- append .md if needed
    if name ~= '' then
      -- append an extension if needed
      if not name:match('%.[%C%X]') then
        name = name .. '.md'
      end

      -- open the file
      vim.cmd('edit ' .. path .. '/' .. name)
    end
  end
end

return create_entry
