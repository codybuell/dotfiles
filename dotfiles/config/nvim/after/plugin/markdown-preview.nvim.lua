--------------------------------------------------------------------------------
--                                                                            --
--  Markdown Preview                                                          --
--                                                                            --
--  https://github.com/selimacerbas/mdkite.nvim                               --
--                                                                            --
--  Pure Lua rewrite (not the iamcco node app); depends on kitehost.nvim.     --
--  Commands: :MdKite [start|stop|refresh|toggle]                             --
--                                                                            --
--------------------------------------------------------------------------------

---------------------
--  Configuration  --
---------------------

require('mdkite').setup({
  instance_mode = 'takeover',  -- one preview follows the active buffer
  port          = 0,           -- auto-assign
  host          = '127.0.0.1',
  open_browser  = true,
  default_theme = 'dark',
  debounce_ms   = 300,
  scroll_sync   = false,       -- carried over from mkdp disable_sync_scroll
  allow_raw_html = true,
})
