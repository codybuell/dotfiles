require('ibl').setup({
  exclude = {
    filetypes = {
      -- defaults
      'lspinfo',
      'packer',
      'checkhealth',
      'help',
      'man',
      'gitcommit',
      '',

      -- additions
      'markdown',
    }
  },
  -- space_char_blankline = ' ',
})
