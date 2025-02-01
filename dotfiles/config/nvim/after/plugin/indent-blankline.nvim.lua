--------------------------------------------------------------------------------
--                                                                            --
--  Indent Blankline                                                          --
--                                                                            --
--  https://github.com/lukas-reineke/indent-blankline.nvim                    --
--                                                                            --
--------------------------------------------------------------------------------

local has_ibl, ibl = pcall(require, 'ibl')
if has_ibl then

  ---------------------
  --  Configuration  --
  ---------------------

  local config  = {
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
  }

  -----------
  -- Setup --
  -----------

  ibl.setup(config)

end
