vim.g.indent_blankline_filetype_exclude = {
  -- defaults
  'lspinfo',
  'packer',
  'checkhealth',
  'help',
  '',

  -- additions
  'gitcommit',
  'markdown',
}

require('indent_blankline').setup({
  space_char_blankline = ' ',
})
