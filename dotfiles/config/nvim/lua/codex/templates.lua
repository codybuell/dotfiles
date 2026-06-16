--------------------------------------------------------------------------------
--                                                                            --
--  Codex Templates                                                           --
--                                                                            --
--  Line-array stubs applied to freshly created notes and journal entries.    --
--  Deliberately plain buffer lines rather than snippet expansions so the     --
--  module carries no snippet engine dependency; the LuaSnip templates        --
--  remain available for manual use.                                          --
--                                                                            --
--------------------------------------------------------------------------------

local templates = {}

-- Note
--
-- Frontmatter stub for a new note.
--
-- @param title: string
-- @param tags: array of strings|nil
-- @return table: array of lines
templates.note = function(title, tags)
  local tag_line = 'tags:'
  if tags and #tags > 0 then
    tag_line = 'tags: [' .. table.concat(tags, ', ') .. ']'
  end

  return {
    '---',
    'title: ' .. title,
    tag_line,
    '---',
    '',
    '',
  }
end

-- Journal
--
-- Frontmatter stub for a journal entry.
--
-- @param year: string
-- @param month: string
-- @param day: string
-- @return table: array of lines
templates.journal = function(year, month, day)
  return {
    '---',
    'title: ' .. year .. '.' .. month .. '.' .. day,
    'tags:',
    '---',
    '',
    '',
  }
end

return templates
