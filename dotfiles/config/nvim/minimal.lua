--------------------------------------------------------------------------------
--                                                                            --
--  Minimal Nvim                                                              --
--                                                                            --
--  Minimal, always-fresh Neovim config for rapid testing and debugging.      --
--                                                                            --
--  Usage:                                                                    --
--    nvim --clean -u ~/.config/nvim/minimal.lua                              --
--    :Lazy to see plugins information, nav with arrows, enter or more        --
--                                                                            --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--                                                                            --
--  Environment Setup                                                         --
--                                                                            --
--------------------------------------------------------------------------------

-- Set the environment variable for CodeCompanion
-- NOTE: Set the config path to enable the copilot adapter to work. It will
-- search the following paths for a token:
--  - "$CODECOMPANION_TOKEN_PATH/github-copilot/hosts.json"
--  - "$CODECOMPANION_TOKEN_PATH/github-copilot/apps.json"
vim.env["CODECOMPANION_TOKEN_PATH"] = vim.fn.expand("~/.config")

-- Set the path for lazy.nvim
-- NOTE: this will create a `.repro` directory in the current working directory!
vim.env.LAZY_STDPATH = ".repro"

--------------------------------------------------------------------------------
--                                                                            --
--  Plugin Configuration                                                      --
--                                                                            --
--------------------------------------------------------------------------------

---------------------
--  CodeCompanion  --
---------------------

local cc_dependencies = {
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { 'echasnovski/mini.pick', version = false },
  { "nvim-lua/plenary.nvim" },
  {
    "saghen/blink.cmp",
    lazy = false,
    version = "*",
    opts = {
      keymap = {
        preset = "enter",
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
      },
      sources = {
        default = { "lsp", "path", "buffer", "codecompanion" },
      },
      cmdline = {
        sources = { "cmdline" },
      },
    },
  },
  -- Test with nvim-cmp
  -- { "hrsh7th/nvim-cmp" },
}

local cc_options = {
  strategies = {
    chat = {
      adapter = "copilot",
      slash_commands = {
        ["help"] = {
          opts = {
            provider = "mini_pick",
          },
        },
      },
    },
    inline = { adapter = "copilot" },
  },
  display = {
    action_palette = {
      width = 95,
      height = 10,
      prompt = "Prompt ",                   -- prompt used for interactive LLM calls
      provider = "mini_pick",               -- default|telescope|mini_pick
      opts = {
        show_default_actions = true,        -- show the default actions in the action palette?
        show_default_prompt_library = true, -- show the default prompt library in the action palette?
      },
    },
  },
  opts = {
    log_level = "DEBUG",
  }
}

local local_codecompanion = {
  {
    "codecompanion.nvim",
    dev          = true,
    dependencies = cc_dependencies,
    opts         = cc_options,
  },
}

local upstream_codecompanion = {
  {
    "olimorris/codecompanion.nvim",
    dependencies = cc_dependencies,
    opts         = cc_options,
  },
}

local github_codecompanion = {
  {
    "codybuell/codecompanion.nvim",
    dependencies = cc_dependencies,
    opts         = cc_options,
  },
}

--------------------------------------------------------------------------------
--                                                                            --
--  Bootstrap                                                                 --
--                                                                            --
--------------------------------------------------------------------------------

-- Load lazy.nvim
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

-- Define the plugins to be used
require("lazy.minit").repro({
  spec = local_codecompanion,
  dev = {
    path = "/Users/pbuell/Repos/github.com/codybuell", -- parent directory of local plugins
  },
})

--------------------------------------------------------------------------------
--                                                                            --
--  Extras                                                                    --
--                                                                            --
--------------------------------------------------------------------------------

------------------
--  Treesitter  --
------------------

local ts_status, treesitter = pcall(require, "nvim-treesitter.configs")
if ts_status then
  treesitter.setup({
    ensure_installed = { "lua", "markdown", "markdown_inline", "yaml" },
    highlight = { enable = true },
  })
end

----------------
--  Nvim CMP  --
----------------

-- Setup nvim-cmp
-- local cmp_status, cmp = pcall(require, "cmp")
-- if cmp_status then
--   cmp.setup({
--     mapping = cmp.mapping.preset.insert({
--       ["<C-b>"] = cmp.mapping.scroll_docs(-4),
--       ["<C-f>"] = cmp.mapping.scroll_docs(4),
--       ["<C-Space>"] = cmp.mapping.complete(),
--       ["<C-e>"] = cmp.mapping.abort(),
--       ["<CR>"] = cmp.mapping.confirm({ select = true }),
--       -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
--     }),
--   })
-- end
