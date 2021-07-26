local compe = require'compe'
local Source = {}

function Source.new()
  return setmetatable({}, {__index = Source })
end

function Source.get_metadata(self)
  return {
    priority = 10;
    menu = '[mail]';
  }
end

function Source.determine(self, context)
  return compe.helper.determine(context)
end

function Source.complete(self, context)
  local lines = {}
  local file = io.popen("lbdbq . | awk '{print $1}' | tr '[:upper:]' '[:lower:]' | uniq")
  for line in file:lines() do
    table.insert(lines, { word = line; })
  end
  file:close()
  context.callback({
    items = lines
  })
end

compe.register_source('mail', Source)
