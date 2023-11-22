local label = function(n)
  local buflist = vim.fn.tabpagebuflist(n)
  local winnr = vim.fn.tabpagewinnr(n)
  return n .. ': ' .. vim.fn.pathshorten(vim.fn.fnamemodify(vim.fn.bufname(buflist[winnr]), ':~:.'))
end

return label
