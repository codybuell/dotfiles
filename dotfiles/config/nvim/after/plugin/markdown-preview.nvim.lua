--------------------------------------------------------------------------------
--                                                                            --
--  Markdown Preview                                                          --
--                                                                            --
--  https://github.com/iamcco/markdown-preview.nvim                           --
--                                                                            --
--------------------------------------------------------------------------------

---------------------
--  Configuration  --
---------------------

vim.g.mkdp_preview_options = {
  mkit = {},
  katex = {},
  uml = {},
  maid = {},
  disable_sync_scroll = 1,
  sync_scroll_type = 'middle',
  hide_yaml_meta = 1,
  sequence_diagrams = {},
  flowchart_diagrams = {},
  content_editable = false,
  disable_filename = 0,
  toc = {}
}
