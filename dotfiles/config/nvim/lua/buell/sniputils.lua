local ls = require"luasnip"
local s = ls.snippet
local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
-- local c = ls.choice_node
local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
-- local fmt = require("luasnip.extras.fmt").fmt
-- local m = require("luasnip.extras").m
-- local lambda = require("luasnip.extras").l
-- local postfix = require("luasnip.extras.postfix").postfix
-- local ts_utils = require'nvim-treesitter.ts_utils'

local sniputils = {}

-----------------
--  utilities  --
-----------------

sniputils.date = function() return {os.date('%Y-%m-%d')} end

sniputils.date_input = function(args, snip, old_state, fmt)
  fmt = fmt or "%Y-%m-%d"
  return sn(nil, i(1, os.date(fmt)))
end

sniputils.bash = function(_, snip, user_args)
  local command = snip.env.TM_SELECTED_TEXT[1] or user_args
  local file = io.popen(command, "r")
  local res = {}
  if file then
    for line in file:lines() do
      table.insert(res, line)
    end
  end
  return res
end

function sniputils.svelte_comment_style()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, 'svelte')
  if not ok or not parser then return "<!--" end
  local tree = parser:parse()[1]
  local root = tree:root()
  local node = root:named_descendant_for_range(row, col, row, col)
  while node do
    local type = node:type()
    if type == "script_element" then
      return "//"
    elseif type == "style_element" then
      return "/*"
    end
    node = node:parent()
  end
  return "<!--"
end

-----------------------
--  common snippets  --
-----------------------

sniputils.box = function(c_str)
  local c_fill
  local c_end

  -- handle comments that require two chars eg lua, go, cpp...
  if string.len(c_str) > 1 then
    c_fill = string.sub(c_str, -1)
    c_end  = string.reverse(c_str)
  else
    c_fill = c_str
    c_end  = c_str
  end

  return s("box", {
    f(function(args) return c_str .. string.rep(c_fill, 2) .. string.gsub(args[1][1], ".", c_fill) .. string.rep(c_fill, 2) .. c_end end, {1}),
    t({"", c_str .. "  "}), i(1, "title"), t({"  " .. c_end, "" }),
    f(function(args) return c_str .. string.rep(c_fill, 2) .. string.gsub(args[1][1], ".", c_fill) .. string.rep(c_fill, 2) .. c_end end, {1}),
    t({"", ""}),
    i(0),
  })
end

sniputils.bbox = function(c_str)
  local c_fill
  local c_end

  -- handle comments that require two chars eg lua, go, cpp...
  if string.len(c_str) > 1 then
    c_fill = string.sub(c_str, -1)
    c_end  = string.reverse(c_str)
  else
    c_fill = c_str
    c_end  = c_str .. c_str
    c_str  = c_str .. c_str
  end

  return s("bbox", {
    f(function() return c_str .. string.rep(c_fill, 76) .. c_end end),
    t({"", c_str}),
    f(function() return string.rep(" ", 76) end),
    t({c_end, c_str .. "  "}),
    i(1, "title"),
    f(function(args, _)
        local length = 74 - string.len(args[1][1])
        return string.rep(" ", length)
      end, {1}),
    t({c_end, c_str}),
    f(function() return string.rep(" ", 76) end),
    t({c_end, ""}),
    f(function() return c_str .. string.rep(c_fill, 76) .. c_end end),
    t({"", ""}),
    i(0),
  })
end

sniputils.f = function()
  return s({
    trig = "f",
    name = "generic func",
    dscr = "Generic function syntax / wrap in function call",
  }, {
    i(1, "f"),t("("),
    d(2, function(_, snip, _, _)
      return sn(1, i(1, snip.env.TM_SELECTED_TEXT[1] or ""))
    end, {}, {}),
    t(')'),
  })
end

sniputils.p = function(lhs, rhs)
  return s({
    trig = "p",
    name = "print",
    dscr = "Print to standard out, non-quoted.",
  }, {
    t({lhs}),
    d(1, function(_, snip, _, _)
      return sn(1, i(1, snip.env.TM_SELECTED_TEXT[1] or "var"))
    end, {}, {}),
    t({rhs}),
  })
end

sniputils.pq = function(lhs, rhs)
  return s({
    trig = "pq",
    name = "print quoted",
    dscr = "Print to standard out, quoted.",
  }, {
    t({lhs}),
    d(1, function(_, snip, _, _)
      return sn(1, i(1, snip.env.TM_SELECTED_TEXT[1] or "var"))
    end, {}, {}),
    t({rhs}),
  })
end

sniputils.po = function(lhs, rhs)
  return s({
    trig = "po",
    name = "print object",
    dscr = "Print object to standard out.",
  }, {
    t({lhs}),
    d(1, function(_, snip, _, _)
      return sn(1, i(1, snip.env.TM_SELECTED_TEXT[1] or "object"))
    end, {}, {}),
    t({rhs}),
  })
end

sniputils.shebang = function(c_str, shebang)
  return s({
    trig = "#!",
    name = "shebang",
    dscr = "Shebang + header for script details and usage.",
  }, {
    t({c_str .. "!" .. shebang, ""}),
    t({c_str, ""}),
    t({c_str .. " "}), i(1, "Name"), t({"", ""}),
    t({c_str, ""}),
    t({c_str .. " "}), i(2, "Description"), t({"", ""}),
    t({c_str, ""}),
    t({c_str .. " Author(s): "}), i(3, "Cody Buell"), t({"", ""}),
    t({c_str, ""}),
    t({c_str .. " Requisite: "}), i(4, ""), t({"", ""}),
    t({c_str, ""}),
    t({c_str .. " Usage: "}), i(5, ""), t({"", ""}),
  })
end

return sniputils
