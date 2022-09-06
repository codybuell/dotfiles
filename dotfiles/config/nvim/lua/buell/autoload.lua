-- Provides a lazy autoload mechanism similar to Vimscript's autoload mechanism.
-- Taken from Greg Hurell: https://github.com/wincent/wincent
--
-- Examples:
--
--    " Vimscript - looks for function named `buell#foo#bar#baz()` in
--    " autoload/buell/foo/bar.vim):
--
--    call buell#foo#bar#baz()
--
--    -- Lua - lazy-loads these files in sequence before calling
--    -- `buell.foo.bar.baz()`:
--    --
--    --    1. lua/buell/foo.lua (or lua/buell/foo/init.lua)
--    --    2. lua/buell/foo/bar.lua (or lua/buell/foo/bar/init.lua)
--    --    3. lua/buell/foo/bar/baz.lua (or lua/buell/foo/bar/baz/init.lua)
--
--    local buell = require'buell'
--    buell.foo.bar.baz()
--
--    -- Note that because `require'buell'` appears at the top of the top-level
--    -- init.lua, the previous example can be written as:
--
--    buell.foo.bar.baz()
--
local autoload = function(base)
  local storage = {}
  local mt = {
    __index = function(_, key)
      if storage[key] == nil then
        storage[key] = require(base .. '.' .. key)
      end
      return storage[key]
    end
  }

  return setmetatable({}, mt)
end

return autoload
