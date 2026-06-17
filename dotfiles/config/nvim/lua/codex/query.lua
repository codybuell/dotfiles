--------------------------------------------------------------------------------
--                                                                            --
--  Codex Query                                                               --
--                                                                            --
--  Parses chooser input into token classes and filters/ranks index records.  --
--                                                                            --
--  Syntax (whitespace separated, all tokens AND together):                   --
--    plain   fuzzy match against 'rel-path  title' via matchfuzzypos         --
--    #tag    frontmatter tag/category, prefix matched                        --
--    *term   file content match, resolved externally via ripgrep             --
--                                                                            --
--------------------------------------------------------------------------------

local query = {}

-- Parse
--
-- Tokenize a query string into plain, tag (#), and content (*) tokens.
-- Bare '#' or '*' (still being typed) are ignored.
--
-- Multi-word tokens are supported two ways:
--   backslash-escape:  *is\ this\ the\ path\ of\ love
--   double-quote:      *"is this the path of love"
--
-- Tag tokens normalize internal spaces to hyphens to match the index
-- (#weed\ thoughts == #weed-thoughts).
--
-- @param input: string
-- @return table: { plain = {}, tags = {}, content = {} }
query.parse = function(input)
  local parsed = { plain = {}, tags = {}, content = {} }

  local i = 1
  local len = #input
  while i <= len do
    -- skip whitespace
    while i <= len and input:sub(i, i):match('%s') do i = i + 1 end
    if i > len then break end

    -- detect prefix
    local char = input:sub(i, i)
    local prefix = ''
    if char == '#' or char == '*' then
      prefix = char
      i = i + 1
      if i > len then break end
      char = input:sub(i, i)
    end

    -- read the token body
    local token = ''
    if char == '"' then
      -- quoted: read until closing quote or end of input
      i = i + 1
      while i <= len do
        char = input:sub(i, i)
        if char == '"' then
          i = i + 1
          break
        end
        token = token .. char
        i = i + 1
      end
    else
      -- unquoted: read until whitespace, honoring backslash-escaped spaces
      while i <= len do
        char = input:sub(i, i)
        if char == '\\' and i + 1 <= len and input:sub(i + 1, i + 1) == ' ' then
          token = token .. ' '
          i = i + 2
        elseif char:match('%s') then
          break
        else
          token = token .. char
          i = i + 1
        end
      end
    end

    -- classify and store
    if token ~= '' then
      if prefix == '#' then
        table.insert(parsed.tags, token:gsub('%s+', '-'):lower())
      elseif prefix == '*' then
        table.insert(parsed.content, token)
      else
        table.insert(parsed.plain, token)
      end
    end
  end

  return parsed
end

-- Filter
--
-- Filter and rank records against a parsed query.
--
-- @param records: array of index records
-- @param parsed: table from query.parse
-- @param content_paths: table|nil, set of paths matching content tokens; nil
--        while results are pending (treated as empty when content tokens
--        exist)
-- @return table: array of { record, score, positions } sorted best-first;
--         positions index into 'rel_no_ext .. "  " .. title'
query.filter = function(records, parsed, content_paths)
  -- tag and content filters
  local candidates = {}
  for _, record in ipairs(records) do
    local keep = true

    for _, tag in ipairs(parsed.tags) do
      local matched = false
      for record_tag in pairs(record.tags) do
        if vim.startswith(record_tag, tag) then
          matched = true
          break
        end
      end
      if not matched then
        keep = false
        break
      end
    end

    if keep and #parsed.content > 0 then
      keep = content_paths ~= nil and content_paths[record.path] == true
    end

    if keep then
      -- haystack doubles as the list display line; tags are included both so
      -- plain tokens can fuzzy-match them and so they are visible in the list
      local rel_no_ext = record.rel:gsub('%.[^.]+$', '')
      local tag_list = {}
      for record_tag in pairs(record.tags) do
        table.insert(tag_list, '#' .. record_tag)
      end
      table.sort(tag_list)
      local tag_str = #tag_list > 0 and ('  ' .. table.concat(tag_list, ' ')) or ''

      -- omit titles that are just a reformatted filename (e.g. journal
      -- entries: file 2026.05.03, title 2026-05-03)
      local title_str = ''
      if record.title:gsub('%W', ''):lower() ~= record.name:gsub('%W', ''):lower() then
        title_str = '  ' .. record.title
      end

      table.insert(candidates, {
        record    = record,
        haystack  = rel_no_ext .. title_str .. tag_str,
        score     = 0,
        positions = {},
      })
    end
  end

  -- plain tokens: fold matchfuzzypos over survivors, AND semantics
  if #parsed.plain > 0 then
    for _, token in ipairs(parsed.plain) do
      if #candidates == 0 then
        break
      end

      local items = {}
      for i, candidate in ipairs(candidates) do
        table.insert(items, { haystack = candidate.haystack, idx = i })
      end

      local matched, positions, scores = unpack(vim.fn.matchfuzzypos(items, token, { key = 'haystack' }))

      local survivors = {}
      for k, item in ipairs(matched) do
        local candidate = candidates[item.idx]
        candidate.score = candidate.score + scores[k]
        vim.list_extend(candidate.positions, positions[k])
        table.insert(survivors, candidate)
      end
      candidates = survivors
    end

    table.sort(candidates, function(a, b)
      if a.score ~= b.score then
        return a.score > b.score
      end
      return a.record.mtime > b.record.mtime
    end)
  else
    -- no plain tokens, most recently modified first
    table.sort(candidates, function(a, b)
      return a.record.mtime > b.record.mtime
    end)
  end

  return candidates
end

return query
