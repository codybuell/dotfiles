local ls = require"luasnip"
local s = ls.snippet
local sn = ls.snippet_node
-- local isn = ls.indent_snippet_node
-- local t = ls.text_node
-- local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
local d = ls.dynamic_node
-- local r = ls.restore_node
-- local events = require("luasnip.util.events")
-- local ai = require("luasnip.nodes.absolute_indexer")
-- local fmt = require("luasnip.extras.fmt").fmt
-- local m = require("luasnip.extras").m
-- local lambda = require("luasnip.extras").l
-- local postfix = require("luasnip.extras.postfix").postfix

-----------------------------
--  Dynamic Box Functions  --
-----------------------------

local function svelte_box_snippet()
  return s("box", d(1, function(_, _, _)
    local c_str = buell.sniputils.svelte_comment_style()
    return sn(nil, buell.sniputils.box(c_str).nodes)
  end, {}))
end

local function svelte_bbox_snippet()
  return s("bbox", d(1, function(_, _, _)
    local c_str = buell.sniputils.svelte_comment_style()
    return sn(nil, buell.sniputils.bbox(c_str).nodes)
  end, {}))
end

-----------------
--   Snippets  --
-----------------

return {
  svelte_box_snippet(),
  svelte_bbox_snippet(),
}
