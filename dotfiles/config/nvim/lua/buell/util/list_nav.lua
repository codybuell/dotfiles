-- List Navigation
--
-- Intelligently navigate the quickfix and location lists. Jump to the first or
-- last item if wrapping or entering into it for the first time.
--
-- @param direction: string, 'next' or 'prev'
-- @param object: string, what we want to jump between 'items', 'file', 'list'
--        item - line within the list
--        file - next or previos file in the list, ie skips multiple items if in same file
--        list - navigate histories of quickfix ald location lists
-- @return nil
local list_nav = function (direction, object)
  -- determine which window is open, if none see if loclist has entries, else assume quickfix even if closed
  local list
  if vim.fn.get(vim.fn.getloclist(0, {winid=0}), 'winid', 0) ~= 0 then
    -- the location window is open
    list = 'l'
  elseif vim.fn.get(vim.fn.getqflist({winid=0}), 'winid', 0) ~= 0 then
    -- the quickfix window is open
    list = 'c'
  elseif #vim.fn.getloclist(0, {winid=0}) ~= 0 then
    -- both windows are closed but the loclist has entries
    list = 'l'
  else
    -- both windows are closed and no entries in the loclist, assume quickfix
    list = 'c'
  end

  if object == 'item' or object == 'file' then
    -- build the desired command
    local command
    if object == 'item' then
      command = list .. direction
    elseif object == 'file' then
      command = list .. direction:sub(1,1) .. 'file'
    end

    -- run the expected command and catch any error
    local ok, result = pcall(
      vim.cmd,
      command
    )

    -- handle wrapping and empty lists
    if not ok and result:match('.*E553:.*$') then
      if direction == 'prev' then
        print('Wrapping to the bottom')
        vim.cmd(list .. 'last')
      elseif direction == 'next' then
        print('Wrapping to the top')
        vim.cmd(list .. 'first')
      end
    elseif not ok and result:match('.*E42:.*$') then
      if list == 'c' then
        print('No items found in the quickfix list')
      else
        print('No items found in the location list')
      end
    end
  elseif object == 'list' then
    local command
    if direction == 'next' then
      command = list .. 'newer'
    elseif direction == 'prev' then
      command = list .. 'older'
    end

    -- TODO: dry this up with other command runs and error code handlings
    local ok, result = pcall(
      vim.cmd,
      command
    )
  end
end

return list_nav
