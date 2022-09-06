local indent_blankline = {
  -- Indent Blankline
  --
  -- For wrapping mappings related to folding and horizontal shifting so that
  -- indent-blankline.nvim can update immediately. See:
  -- https://github.com/lukas-reineke/indent-blankline.nvim/issues/118
  --
  -- @param path: string of desired path
  -- @return nil
  wrap_mapping = function(mapping)
    if vim.g.loaded_indent_blankline == 1 then
      return mapping .. ':IndentBlanklineRefresh<CR>'
    else
      return mapping
    end
  end
}

return indent_blankline
