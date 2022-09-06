---------------------------------------------------------------------------------
--                                                                             --
--  Lua Configuration Entrypoint                                               --
--                                                                             --
---------------------------------------------------------------------------------

-- alias autoload
local autoload = require'buell.autoload'

-- autoload this config
local buell = autoload('buell')

-- make it globally available
_G.buell = buell

return buell
