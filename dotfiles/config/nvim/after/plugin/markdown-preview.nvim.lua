--------------------------------------------------------------------------------
--                                                                            --
--  Markdown Preview                                                          --
--                                                                            --
--  https://github.com/selimacerbas/markdown-preview.nvim                     --
--                                                                            --
--  Pure Lua rewrite (not the iamcco node app); depends on live-server.nvim.  --
--  Commands: :MarkdownPreview / :MarkdownPreviewRefresh / :MarkdownPreviewStop
--                                                                            --
--------------------------------------------------------------------------------

---------------------
--  Configuration  --
---------------------

require('markdown_preview').setup({
  instance_mode = 'takeover',  -- one preview follows the active buffer
  port          = 0,           -- auto-assign
  host          = '127.0.0.1',
  open_browser  = true,
  default_theme = 'dark',
  debounce_ms   = 300,
  scroll_sync   = false,       -- carried over from mkdp disable_sync_scroll
  allow_raw_html = true,
})
