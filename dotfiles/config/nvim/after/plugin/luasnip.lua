local luasnip = require("luasnip")
local snip_lua = require("luasnip.loaders.from_lua")
-- local snip_vscode = require("luasnip.loaders.from_vscode")
local snip_snipmate = require("luasnip.loaders.from_snipmate")

-- mappings are handled / defined in `after/plugin/nvim-cmp.lua`

-- configuration
luasnip.config.set_config({
  -- set events that update active nodes
  update_events="InsertLeave,TextChangedI",
  -- set events to handle exiting from snippets
  region_check_events = "CursorMoved",
  -- set events to check if snippet was delete and remove from history
  delete_check_events = "TextChanged,InsertLeave",
  -- make visual selection then hit tab to use it in a snippet
  store_selection_keys = "<Tab>",
  -- use nvim-treesitter to get the filetype (enables sub filetypes eg codeblock
  -- within mardown document)
  ft_func = require("luasnip.extras.filetype_functions").from_cursor
})

-- load luasnip snippets
snip_lua.lazy_load({ paths = "./snippets/luasnip" })
-- snip_vscode.lazy_load({ paths = "./snippets/vscode" })
snip_snipmate.lazy_load({ paths = "./snippets/snipmate" })
