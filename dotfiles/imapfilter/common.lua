dofile(os.getenv('HOME') .. '/.imapfilter/util.lua')

options.limit = 50

--
-- Shared helpers (reference globals `inbox` and `allmail` set by each account's run())
--

function movetofolder(description, folder, matcher)
  local messages = matcher()
  print_status(messages, description .. ' -> move to folder')
  messages:move_messages(folder)
end

function movetofolder_and_mark_read(description, folder, matcher)
  local messages = matcher()
  print_status(messages, description .. ' -> move to folder & mark read')
  messages:mark_seen()
  messages:move_messages(folder)
end

function archive(description, matcher)
  local messages = matcher()
  print_status(messages, description .. ' -> archive')
  messages:move_messages(allmail)
end

function archive_and_mark_read(description, matcher)
  local messages = matcher()
  print_status(messages, description .. ' -> archive & mark read')
  messages:mark_seen()
  messages:move_messages(allmail)
end

function flag(description, matcher)
  local messages = matcher()
  print_status(messages, description .. ' -> Important')
  messages:mark_flagged()
end

--
-- Shared collectors (reference global `inbox` set by each account's run())
--

function github()
  return inbox:contain_from('notifications@github.com')
end

function github_related(messages)
  local results = Set {}
  for _, message in ipairs(messages) do
    local mbox, uid = table.unpack(message)
    local m = mbox[uid]
    local parent_date = parse_internal_date(m:fetch_date())
    local pull_id = string.gsub(
      mbox[uid]:fetch_field('In-Reply-To'),
      'In%-Reply%-To: ',
      ''
    )
    local all_github = github()
    local related = all_github:match_field('In-Reply-To', pull_id) +
      all_github:match_field('Message-ID', pull_id)

    for _, rel_message in ipairs(related) do
      local rel_mbox, rel_uid = table.unpack(rel_message)
      local rel_m = rel_mbox[rel_uid]
      local date = parse_internal_date(rel_m:fetch_date())
      if date <= parent_date then
        table.insert(results, rel_message)
      end
    end
  end
  return results
end
