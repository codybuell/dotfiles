dofile(os.getenv('HOME') .. '/.imapfilter/common.lua')

local me = '{{ WorkEmailUsername }}'
local password = get_pass('{{ WorkEmailKeychain }}', '{{ WorkEmailHost }}')

function connect()
  return IMAP {
    server = '{{ WorkEmailHost }}',
    username = me,
    password = password,
    ssl = 'auto',
  }
end

function run()

  work = connect()
  inbox = work.INBOX

  --
  -- Helpers
  --

  archive = (function(description, matcher)
    messages = matcher()
    print_status(messages, description .. ' -> archive')
    messages:move_messages(work.Archive)
  end)

  archive_and_mark_read = (function(description, matcher)
    messages = matcher()
    print_status(messages, description .. ' -> archive & mark read')
    messages:mark_seen()
    messages:move_messages(work.Archive)
  end)

  flag = (function(description, matcher)
    messages = matcher()
    print_status(messages, description .. ' -> Important')
    messages:mark_flagged()
  end)

  --
  -- Collectors
  --

  github = (function()
    return inbox:contain_from('notifications@github.com')
  end)

  github_related = (function(messages)
    results = Set {}
    for _, message in ipairs(messages) do
      mbox, uid = table.unpack(message)
      m = mbox[uid]
      parent_date = all or parse_internal_date(m:fetch_date())
      pull_id = string.gsub(
        mbox[uid]:fetch_field('In-Reply-To'),
        'In%-Reply%-To: ',
        ''
      )
      all_github = github()
      related = all_github:match_field('In-Reply-To', pull_id) +
        all_github:match_field('Message-ID', pull_id)

      for _, message in ipairs(related) do
        mbox, uid = table.unpack(message)
        m = mbox[uid]
        date = all or parse_internal_date(m:fetch_date())
        if all or date <= parent_date then
          table.insert(results, message)
        end
      end
    end
    return results
  end)

  --
  -- Rules
  --

  -- github personal action notifications
  archive_and_mark_read('github personal activity', (function()
    own = inbox:match_field('X-GitHub-Sender', '{{ GitUsername }}')
    return own + github_related(own)
  end))

--  -- vendor advertisements
--  archive_and_mark_read('vendor advertisements', (function()
--    results = inbox:match_field('X-GitHub-Sender', '{{ GitUsername }}')
--    return results
--  end))

  -- bonusly
  archive_and_mark_read('bonusly awards', (function()
    results = inbox
      :contain_from('noreply@bonus.ly')
      :contain_subject('did something awesome')
    return results
  end))

end

if os.getenv('ONCE') then
  print 'ONCE is set: running once.'
  run_and_log_time(run)
else
  print 'Looping, to run once set ONCE.'
  forever(run, 60)
end
