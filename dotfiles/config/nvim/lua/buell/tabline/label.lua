local label = function(n, trim)
  local buflist = vim.fn.tabpagebuflist(n)
  local winnr   = vim.fn.tabpagewinnr(n)

  local full_title = vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.bufname(buflist[winnr]), ':t'))

  if trim == 0 then
    return n .. ': ' .. full_title
  else
    return n .. ': ' .. full_title:sub(0, #full_title - trim - 1) .. '…'
  end
  ------------------------------------
  -- VERSION THAT INCLUDES FILEPATH --
  ------------------------------------
  -- local buflist = vim.fn.tabpagebuflist(n)
  -- local winnr   = vim.fn.tabpagewinnr(n)

  -- local full_title = vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.bufname(buflist[winnr]), ':~:.'))

  -- if trim == 0 then
  --   return n .. ': ' .. full_title
  -- end

  -- local filename = vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.bufname(buflist[winnr]), ':t'))
  -- local filepath = full_title:sub(0, #full_title - #filename)

  -- if trim <= #filepath then
  --   filepath = '…' .. filepath:sub(trim + 2)
  -- else
  --   trim = trim - #filepath
  --   filepath = ''
  --   filename = filename:sub(0, #filename - trim - 2) .. '…'
  -- end

  -- return n .. ': ' .. filepath .. filename
end

return label
