local augroup = buell.util.augroup
local autocmd = buell.util.autocmd

if vim.g.started_by_firenvim == true then
  -- drop the statusbar
  vim.o.laststatus = 0

  -- tweak special characters
  vim.opt.listchars      = {
    eol                  = '¬',
    nbsp                 = '⦸',                                  -- CIRCLED REVERSE SOLIDUS (U+29B8, UTF-8: E2 A6 B8)
    extends              = '»',                                  -- RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00BB, UTF-8: C2 BB)
    precedes             = '«',                                  -- LEFT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00AB, UTF-8: C2 AB)
    tab                  = '▷⋯',                                 -- WHITE RIGHT-POINTING TRIANGLE (U+25B7, UTF-8: E2 96 B7) + MIDLINE HORIZONTAL ELLIPSIS (U+22EF, UTF-8: E2 8B AF)
    trail                = '•',                                  -- BULLET (U+2022, UTF-8: E2 80 A2)
  }

  -- configurations, global and site specific, manually launch with shortcut
  -- set in chrome://extensions/shortcuts or about://addons in firefox, use
  -- firenvim instead of the standard vim command line, simplifies interface
  vim.g.firenvim_config = {
    globalSettings = {
      alt = "all"
    },
    localSettings = {
      [".*"] = {
        cmdline  = "neovim",
        content  = "text",
        priority = 0,
        selector = "textarea",
        takeover = "never"       -- always, empty, never, nonempty, once
      }
    }
  }

  -- handle color setup
  augroup('BuellFireNVIM', function()
    autocmd('ColorScheme', '*', function()
      buell.color.update()
    end)
  end)
end
