local ls = require"luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local fmt = require("luasnip.extras.fmt").fmt
local m = require("luasnip.extras").m
local lambda = require("luasnip.extras").l
local postfix = require("luasnip.extras.postfix").postfix

----------------
--  Snippets  --
----------------

return {
  -- examples
  s("novel", {
    t("It was a dark and stormy night on "),
    d(1, buell.sniputils.date_input, {}, { user_args = { "%A, %B %d of %Y" } }),
    t(" and the clocks were striking thirteen."),
  }),
  -- /examples

  -- inject output of bash command into doc, type command, visually select, hit
  -- tab, type !, then expand snippet, the original text will be replaced with
  -- the commands output
  s("!", f(buell.sniputils.bash, {}, { user_args = { ":" } })),

  buell.sniputils.box("#"),
  buell.sniputils.bbox("#"),

  s({
    trig = "date",
    name = "Date",
    dscr = "Date in the form of YYYY.MM.DD",
  }, {
    --f(buell.sniputils.date, {}),
    d(1, buell.sniputils.date_input, {}, {user_args = {"%Y.%m.%d"}}),
  }),

  s({
    trig = "time",
    name = "Time",
    dscr = "Current time in the form of hh:mm",
  }, {
    d(1, buell.sniputils.date_input, {}, {user_args = {"%H:%M"}}),
  }),
}
