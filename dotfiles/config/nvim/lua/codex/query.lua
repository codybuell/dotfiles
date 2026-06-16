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
-- Tokenize a query string. Bare '#' or '*' (still being typed) are ignored.
-- Backslash-escaped spaces ('weed\ thoughts') keep a token together; tag
-- tokens additionally normalize internal spaces to hyphens to match the
-- index ('#weed\ thoughts' == '#weed-thoughts').
--
-- @param input: string
-- @return table: { plain = {}, tags = {}, content = {} }
query.parse = function(input)
  local parsed = { plain = {}, tags = {}, content = {} }

  -- hide escaped spaces from the tokenizer, restore them per token
  input = input:gsub('\\ ', '\0')

  for token in input:gmatch('%S+') do
    token = token:gsub('%z', ' ')
    local prefix, rest = token:sub(1, 1), token:sub(2)
    if prefix == '#' then
      if rest ~= '' then
        table.insert(parsed.tags, rest:gsub('%s+', '-'):lower())
      end
    elseif prefix == '*' then
      if rest ~= '' then
        table.insert(parsed.content, rest)
      end
    else
      table.insert(parsed.plain, token)
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
