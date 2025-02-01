--------------------------------------------------------------------------------
--                                                                            --
--  Limelight                                                                 --
--                                                                            --
--  https://github.com/junegunn/limelight.vim                                 --
--                                                                            --
--------------------------------------------------------------------------------

if vim.fn.exists(':Limelight') then

  ----------------------
  --  Configurations  --
  ----------------------

  -- see after/plugin/goyo.vim

  -- opacity, defaults 0.5
  vim.g.limelight_default_coefficient = 0.7

  -- number of preceding/following paragraphs to include (default: 0)
  vim.g.limelight_paragraph_span = 0

end
