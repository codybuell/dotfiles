local color = {}

local pinnacle = require('wincent.pinnacle')
local hlg      = buell.util.set_highlight

--------------------------------------------------------------------------------
--                                                                            --
--  Configuration                                                             --
--                                                                            --
--------------------------------------------------------------------------------

-- set supported terminals for setting termguicolors
local supported_terminals = {
  "xterm-256color",
  "tmux-256color",
  "xterm-kitty",
}

-- theme configuration location
local zdotdir = vim.env.ZDOTDIR or (vim.env.HOME .. '/.zsh')
local tinted_config = zdotdir .. '/colors/tinted'

--------------------------------------------------------------------------------
--                                                                            --
--  Helpers                                                                   --
--                                                                            --
--------------------------------------------------------------------------------

-- Helper function to read the theme from the tinted configuration file.
local function read_theme_file()
  local file = io.open(tinted_config, 'r')
  if file then
    local theme = file:read('*line')  -- first line contains scheme name
    file:close()
    return theme
  else
    return 'base24-tomorrow-night'    -- fallback to default theme
  end
end

-- Helper function to set up the tinted-colorscheme with the active theme.
local function setup_tinted_colorscheme(theme_name)
  require('tinted-colorscheme').setup(theme_name, {
    supports = {
      tinty = false,
      live_reload = false,
    },
    highlights = {
      telescope = true,
      telescope_borders = false,
      indentblankline = true,
      notify = true,
      cmp = true,
      illuminate = true,
      lsp_semantic = true,
      dapui = true,
    },
  })
end

-- Custom live reloading support.
local function setup_theme_watcher()
  -- Store last modification time
  local last_mtime = 0

  local function check_theme_change()
    local stat = vim.loop.fs_stat(tinted_config)
    if stat and stat.mtime.sec > last_mtime then
      last_mtime = stat.mtime.sec

      -- Read the new theme using helper
      local new_theme = read_theme_file()

      -- Only reload if theme actually changed
      if new_theme and new_theme ~= vim.g.buell_current_theme then
        print('Theme changed to: ' .. new_theme)
        color.update()
      end
    end
  end

  -- Check for changes every 1 second
  local timer = vim.loop.new_timer()
  timer:start(1000, 1000, vim.schedule_wrap(check_theme_change))

  -- Initialize last modification time
  local stat = vim.loop.fs_stat(tinted_config)
  if stat then
    last_mtime = stat.mtime.sec
  end
end

--------------------------------------------------------------------------------
--                                                                            --
--  Custom Highlights                                                         --
--                                                                            --
--------------------------------------------------------------------------------

local function custom_highlights()
  ------------------
  --  Statusline  --
  ------------------

  -- Define custom highlight groups for statusline
  pinnacle.set("StatusLineArrowRight", pinnacle.italicize('StatusLine'))
  pinnacle.set("StatusLineMiddle", pinnacle.dump('StatusLine'))
  pinnacle.set("StatusLineMiddleBold", pinnacle.embolden('StatusLine'))
  pinnacle.set("StatusLineArrowLeft", {
    fg = pinnacle.fg('Error'),
    bg = pinnacle.bg('Visual'),
  })
  pinnacle.set("StatusLineRight", {
    fg = pinnacle.fg("Cursor"),
    bg = pinnacle.fg("StatusLineMiddleBold"),
  })
  pinnacle.set("StatusLineMiddleAccent", {
    fg = pinnacle.fg("Cursor"),
    bg = pinnacle.fg("StatusLineMiddleBold"),
    bold = true,
    italic = true,
  })
  pinnacle.set("StatusLineLeft", {
    fg = pinnacle.fg('Normal'),
    bg = pinnacle.fg('Error'),
    bold = true,
  })

  -- define statusline no color
  pinnacle.link('StatusLineNC', 'StatusLineArrowRight')

  --------------------
  --  Left Columns  --
  --------------------

  local cursorline_bg = pinnacle.bg('CursorLine') -- Same as current line

  -- Line numbers
  pinnacle.set('LineNr', {
    fg = pinnacle.darken('Normal', 0.4).fg,
    bg = cursorline_bg
  })

  -- Current line number
  pinnacle.set('CursorLineNr', {
    fg = pinnacle.fg('Normal'),
    bg = cursorline_bg,
    bold = true
  })

  -- Sign column (LSP signs, git signs, etc.)
  pinnacle.set('SignColumn', {
    bg = cursorline_bg
  })

  -- Fold column
  pinnacle.set('FoldColumn', {
    fg = pinnacle.darken('Normal', 0.3).fg,
    bg = cursorline_bg
  })

  ----------------
  --  Comments  --
  ----------------

  local comment_style = {
    fg = pinnacle.brighten('Comment', 0.15).fg,
    bg = pinnacle.bg('Comment'),
    italic = true,
  }

  -- Standard comment group
  pinnacle.set('Comment', comment_style)

  -- Treesitter comment groups
  pinnacle.set('@comment', comment_style)
  pinnacle.set('@comment.line', comment_style)
  pinnacle.set('@comment.block', comment_style)
  pinnacle.set('@comment.documentation', comment_style)

  ---------------
  --  tabline  --
  ---------------

  pinnacle.link('TabLineSel', 'ErrorMsg')

  -------------
  --  Diffs  --
  -------------

  -- Only set background colors for diff highlights
  -- TODO: Look into not having to hardcode colors here.
  pinnacle.set('DiffAdd', {
    fg = 'None',
    bg = '#222f22',
  })
  pinnacle.set('DiffDelete', {
    fg = 'None',
    bg = '#2f2222',
  })
  pinnacle.set('DiffChange', {
    fg = 'None',
    bg = '#1b2d4a',
  })
  pinnacle.set('DiffText', {
    fg = '#f0c674',
    bg = '#1b2d4a',
    bold = true,
  })

  -------------
  ----  lsp  --
  -------------

  ---- error
  --pinnacle.set('DiagnosticVirtualTextError', pinnacle.decorate('bold,italic', 'ModeMsg'))
  --pinnacle.set('DiagnosticFloatingError', {fg = pinnacle.fg('ErrorMsg')})
  --pinnacle.set('DiagnosticSignError', {bg = pinnacle.bg('ColorColumn'), fg = pinnacle.fg('ErrorMsg')})

  ---- warning
  --pinnacle.set('DiagnosticVirtualTextWarning', pinnacle.decorate('bold,italic', 'Type'))
  --pinnacle.set('DiagnosticFloatingWarning', {fg = pinnacle.bg('Substitute')})
  --pinnacle.set('DiagnosticSignWarn', {bg = pinnacle.bg('ColorColumn'), fg = pinnacle.bg('Substitute')})

  ---- information
  --pinnacle.set('DiagnosticVirtualTextInformation', pinnacle.decorate('bold,italic', 'Type'))
  --pinnacle.set('DiagnosticFloatingInformation', {fg = pinnacle.fg('Normal')})
  --pinnacle.set('DiagnosticSignInfo', {bg = pinnacle.bg('ColorColumn'), fg = pinnacle.fg('Conceal')})

  ---- hint
  --pinnacle.set('DiagnosticVirtualTextHint', pinnacle.decorate('bold,italic', 'Type'))
  --pinnacle.set('DiagnosticFloatingHint', {fg = pinnacle.fg('Type')})
  --pinnacle.set('DiagnosticSignHint', {bg = pinnacle.bg('ColorColumn'), fg = pinnacle.fg('Type')})

  ---- document_highlight
  --pinnacle.set('LspReferenceText', {fg = pinnacle.fg('Type')})
  --pinnacle.set('LspReferenceRead', {fg = pinnacle.fg('Type')})
  --pinnacle.set('LspReferenceWrite', {fg = pinnacle.fg('Type')})

  ---------------------
  --  Miscellaneous  --
  ---------------------

  -- parentheses match is rough by default
  pinnacle.set('MatchParen', {
    fg = pinnacle.bg('CurSearch'),
    bg = 'None',
    bold = true,
  })

  -- indent blankline because it's linking to Whitespace hl group before it is being set here
  -- IblScope -> the active indent line
  -- IblIndent -> the inactive intend lines
  -- IblWhitespace -> the unwanted whitespace characters in the indent lines
  pinnacle.set('IblScope', pinnacle.brighten('NonText', 0.10))
  pinnacle.set('IblIndent', { fg = pinnacle.darken('Normal', 0.60).fg })
  pinnacle.set('IblWhitespace', { fg = pinnacle.darken('Normal', 0.50).fg })

  -- -- listchar overrides to make them more subtle :h listchar for mapping to characters
  -- pinnacle.set('SpecialKey', { fg = pinnacle.darken('Normal', 0.55).fg })
  -- pinnacle.set('NonText', { fg = pinnacle.darken('Normal', 0.55).fg })
  -- pinnacle.set('Whitespace', { fg = pinnacle.darken('Normal', 0.55).fg })

  -- -- make floating windows match pmenu
  -- vim.cmd("highlight! link NormalFloat Pmenu")
  -- pinnacle.set('FloatBorder', {bg = pinnacle.bg('Pmenu'), fg = pinnacle.darken('Normal', 0.3).fg})

  -- -- make popup menu show current line selection
  -- pinnacle.set('PmenuSel', {
  --   bg = pinnacle.bg('Error'),
  --   fg = pinnacle.fg('CursorLine'),
  --   bold = true,
  -- })

  -- -- make use of lsp hl group for signature help active param
  -- pinnacle.set('LspSignatureActiveParameter', pinnacle.decorate('bold,italic', 'WarningMsg'))

  -- used by nvim-cmp and others that want a darker border around popup menus
  pinnacle.link('PmenuDarker', 'FloatBorder')

end

--------------------------------------------------------------------------------
--                                                                            --
--  Color Update                                                              --
--                                                                            --
--------------------------------------------------------------------------------

color.update = function()
  ------------------------------------
  --  Set Terminal Support & Theme  --
  ------------------------------------

  -- Conditionally set termguicolors
  if buell.util.has_value(supported_terminals, vim.env.TERM) then
    vim.opt.termguicolors = true
  else
    vim.opt.termguicolors = false
  end

  -- Determine active tinted shell theme using helper
  local active_theme = read_theme_file()

  -- Set the active theme for tinted-colorscheme using helper
  setup_tinted_colorscheme(active_theme)

  -- Store current theme for comparison
  vim.g.buell_current_theme = active_theme

  -- Call custom highlights function
  custom_highlights()


end

--------------------------------------------------------------------------------
--                                                                            --
--  Theme Watcher                                                             --
--                                                                            --
--------------------------------------------------------------------------------


-- Set up the theme watcher when the module loads
setup_theme_watcher()

return color
