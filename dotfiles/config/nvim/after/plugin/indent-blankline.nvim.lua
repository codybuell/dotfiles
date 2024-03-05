require('ibl').setup({
  exclude = {
    filetypes = {
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
  },
  -- space_char_blankline = ' ',
})
