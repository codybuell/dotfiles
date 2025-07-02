local ls = require"luasnip"
local s = ls.snippet
-- local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
-- local fmt = require("luasnip.extras.fmt").fmt
-- local m = require("luasnip.extras").m
-- local lambda = require("luasnip.extras").l
-- local postfix = require("luasnip.extras.postfix").postfix

-----------------
--   Snippets  --
-----------------

return {
  buell.sniputils.box("#"),
  buell.sniputils.bbox("#"),
  buell.sniputils.shebang("#", "/bin/bash"),

  -------------
  --  print  --
  -------------

  buell.sniputils.p("echo ${", "}"),
  buell.sniputils.pq('echo "', '"'),

  ----------
  --  if  --
  ----------

  s({
    trig = "if",
    name = "if",
    dscr = "If statement.",
  }, {
    t({"if [[ "}), i(1, "condition"), t({" ]]; then", "  "}), i(0, ":"), t({"", "fi"}),
  }),

  s({
    trig = "ifn",
    name = "if not",
    dscr = "If not statement.",
  }, {
    t({"if [[ !"}), i(1, "condition"), t({" ]]; then", "  "}), i(0, ":"), t({"", "fi"}),
  }),

  s({
    trig = "ifa",
    name = "if and",
    dscr = "If and if statement.",
  }, {
    t({"if [[ ("}), i(1, "condition"), t({") && ("}), i(2, "condition"), t({") ]]; then", "  "}), i(0, ":"), t({"", "fi"}),
  }),

  s({
    trig = "ifo",
    name = "if or",
    dscr = "If or if statement.",
  }, {
    t({"if [[ ("}), i(1, "condition"), t({") || ("}), i(2, "condition"), t({") ]]; then", "  "}), i(0, ":"), t({"", "fi"}),
  }),

  s({
    trig = "ife",
    name = "if else",
    dscr = "If or else statement.",
  }, {
    t({"if [[ "}), i(1, "condition"), t({" ]]; then", ""}),
    t({"  "}), i(2, ":"), t({"", ""}),
    t({"else", ""}),
    t({"  "}), i(0, ":"), t({"", "fi"}),
  }),

  s({
    trig = "ifei",
    name = "if else if",
    dscr = "If else if statement.",
  }, {
    t({"if [[ "}), i(1, "condition"), t({" ]]; then", ""}),
    t({"  "}), i(2, ":"), t({"", ""}),
    t({"elif [[ "}), i(3, "condition"), t({" ]]; then", ""}),
    t({"  "}), i(0, ":"), t({"", "fi"}),
  }),

  s({
    trig = "el",
    name = "else",
    dscr = "Else component of conditional statement.",
  }, {
    t({"else", ""}),
    t({"  "}), i(0, ":"), t({"", ""}),
  }),

  s({
    trig = "ei",
    name = "else if",
    dscr = "Else if component of conditional statement.",
  }, {
    t({"elif [[ "}), i(1, "condition"), t({" ]]; then", ""}),
    t({"  "}), i(0, ":"), t({"", ""}),
  }),
}
