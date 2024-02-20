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

  -----------------
  --  templates  --
  -----------------

  s({
    trig = "fm",
    name = "Frontmatter",
    dscr = "Yaml metadata format for markdown"
  },
  {
    t({"---",
    "title: "}), i(1, "note_title"), t({"",
    "date: "}), f(buell.sniputils.date, {}), t({"",
    "categories: ["}), i(2, ""), t({"]",
    "lastmod: "}), f(buell.sniputils.date, {}), t({"",
    "tags: ["}), i(3), t({"]",
    "---", ""}),
    i(0)
  }),

  s({
    trig = "j",
    name = "Journal Template",
    dscr = "Generic journal template"
  },
  {
    t({"---",
    "title: "}), f(buell.sniputils.date, {}), t({"",
    "tags: ",
    "---", "", ""}),
    i(0)
  }),

  s({
    trig = "n",
    name = "Note Template",
    dscr = "Generic note template"
  },
  {
    t({"---",
    "title: "}), i(1, 'title'), t({"",
    "tags: "}), i(2), t({"",
    "---", "", ""}),
    t({"__See also:__","  - ", "",""}),
    t({"__Quick reference:__","  - ","",""}),
    f(function(args) local underline = string.gsub(args[1][1], ".", "="); return {args[1][1],underline} end, {1}),
    t({"","",""}),
    i(0)
  }),

  s({
    trig = "1:1",
    name = "1:1 Template",
    dscr = "Generic one on one template"
  },
  {
    t({"1:1 "}), i(1, 'person'),
    t({"","----"}),
    f(function(args) local underline = string.gsub(args[1][1], ".", "-"); return {underline} end, {1}),
    t({"","",""}),
    t({"__Accomplishments:__", "  - "}),
    i(2),
    t({"", "","__Questions/Needs:__", "  - "}),
    i(3),
    t({"", "","__Priorities:__", "  - "}),
    i(0),
  }),

  ----------------
  --  elements  --
  ----------------

  s({
    trig = "t",
    name = "Todo",
    dscr = "Todo brackets",
  },
  {
    t({"[ ] "}),
  }),

  s({
    trig = "td",
    name = "Todo",
    dscr = "Todo list item",
  },
  {
    t({"- [ ] "}),
  }),

  s({
    trig = "a",
    name = "Link",
    dscr = "Markdown link [txt](url)"
  },
  {
    t('['),
    d(1, function(_, snip, _, _)
      return sn(1, i(1, snip.env.TM_SELECTED_TEXT[1] or "txt"))
    end, {}, {}),
    t(']('),
    d(2, function(_, snip, _, _)
      return sn(1, i(1, snip.env.TM_SELECTED_TEXT[1] or "url"))
    end, {}, {}),
    t(')'),
    i(0),
  }),

  s({
    trig = "h1",
    name = "H1",
    dscr = "Header 1",
  },
  {
    i(1, 'title'), t({"", ""}),
    f(function(args) return string.gsub(args[1][1], ".", "=") end, {1}),
  }),

  s({
    trig = "h2",
    name = "H2",
    dscr = "Header 2",
  },
  {
    i(1, 'title'), t({"", ""}),
    f(function(args) return string.gsub(args[1][1], ".", "-") end, {1}),
  }),

  s({
    trig = "h3",
    name = "H3",
    dscr = "Header 3",
  },
  {
    t({"### "}), i(1, 'title'),
  }),

  s({
    trig = "i",
    name = "Italics",
    dscr = "Italics",
  },
  {
    t({"_"}), i(1, 'title'), t({"_"}),
  }),

  s({
    trig = "b",
    name = "Bold",
    dscr = "Bold",
  },
  {
    t({"__"}), i(1, 'title'), t({"__"}),
  }),

  s({
    trig = "bi",
    name = "Bold Italics",
    dscr = "Bold Italics",
  },
  {
    t({"___"}), i(1, 'title'), t({"___"}),
  }),

  -- bq  block quote
  -- cb  code block
  -- td  todo
  -- t   task check box
  -- img image link
  -- as  link to section
  -- ap  link to page
  -- ar  link w/ reference
  -- af  link w/ footnote
  -- `   inline code

}
