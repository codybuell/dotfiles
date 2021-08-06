---------------------
--  configuration  --
---------------------

local blacklist = {
  '.*noreply.*'
}

---------------
--  helpers  --
---------------

local function split(s, sep)
  local fields = {}

  local lsep = sep or " "
  local pattern = string.format("([^%s]+)", lsep)
  string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)

  return fields
end

local function get_contacts(_)
  -- init some variables
  local contacts_email = {}
  local contacts_name  = {}
  local first = true

  -- query lbdbq and loop through lines
  local lbdbq = io.popen("lbdbq .")
  for contact in lbdbq:lines() do
    -- skip the header
    if first then
      first = false
      goto continue
    end

    -- split lbdbq line output by tab
    local fields = split(contact, '\t')

    -- lowercase email to handle duplicates
    local email   = string.lower(fields[1])
    local name    = fields[2]
    local mstring = "'" .. name .. "' <" .. email .. ">"

    -- check if email is in our blacklist
    for _,val in ipairs(blacklist) do
      if email:match(val) then
        goto continue
      end
    end

    -- append to table indexed by email to handle duplicates
    contacts_email[email] = {
      email = email;
      name  = name;
      meta  = fields[3];
      mstring = mstring;
    }

    -- append to table indexed by name to handle duplicates
    contacts_name[name] = {
      email = email;
      name  = name;
      meta  = fields[3];
      mstring = mstring;
    }

    ::continue::
  end

  -- close lbdbq call
  lbdbq:close()

  return contacts_email, contacts_name
end

local function build_compe_table(source, completion)
  local compe_table = {}
  for _,v in pairs(source) do
    table.insert(compe_table, {
      word = v[completion];       -- what to spit out on completion
      -- abbr = 'abbr';           -- what to show in the completion menu
      -- kind = completion;       -- metadata displayed after abbr
      -- user_data = 'user_data'; -- ??
    })
  end
  return compe_table
end

local function is_in_header()
  local line = vim.api.nvim_get_current_line()
  for _, header in pairs({ 'Bcc:', 'Cc:', 'From:', 'Reply-To:', 'To:' }) do
    if vim.startswith(line, header) then
      return true
    end
  end
  return false
end

local function tableConcat(t1,t2)
    for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

------------------
--  query lbdb  --
------------------

-- TODO: this is executed on initial load of vim, need to implement a way of
-- re-querying if data is getting stale in long running sessions
local lbdb_email, lbdb_name = get_contacts()
local compe_names    = build_compe_table(lbdb_name, 'name')
local compe_emails   = build_compe_table(lbdb_email, 'email')
local compe_contacts = build_compe_table(lbdb_email, 'mstring')
local full_set       = tableConcat(compe_names, compe_emails)

-------------
--  compe  --
-------------

local compe  = require'compe'
local Source = {}

function Source.new()
  return setmetatable({}, {__index = Source })
end

function Source.get_metadata(_)
  return {
    menu = '[lbdb]';
    priority = 100;
    filetypes = {'markdown', 'mail'}
  }
end

function Source.determine(_, context)
  return compe.helper.determine(context)
end

function Source.complete(_, context)
  if is_in_header() then
    context.callback({
      items = compe_contacts
    })
  else
    context.callback({
      items = full_set
    })
  end
end

compe.register_source('lbdb', Source)
