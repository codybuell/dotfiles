dofile(os.getenv('HOME') .. '/.imapfilter/common.lua')

local me = '{{ ClientEmailUsername }}'
local password = get_pass('{{ ClientEmailKeychain }}', '{{ ClientEmailHost }}')

function connect()
  return IMAP {
    server = '{{ ClientEmailHost }}',
    port = 993,
    username = me,
    password = password,
    ssl = 'auto',
  }
end

function run()

  -- NOTE: Beware the use of contain_field when talking to an MS server; it is
  -- totally unreliable, so must use the slower match_field match_from() or
  -- match_to() methods. See:
  --
  -- - https://github.com/lefcha/imapfilter/issues/14
  -- - https://github.com/lefcha/imapfilter/issues/33

  client = connect()
  inbox  = client.Inbox:select_all()

  -- list mailboxes and folders
--  mailboxes, folders = client:list_all()
--  for _, m in ipairs(mailboxes) do print(m) end
--  for _, f in ipairs(folders) do print(f) end

  --
  -- Helpers
  --

  archive = (function(description, matcher, destination)
    messages = matcher()
    print_status(messages, description .. ' -> archive')
    messages:move_messages(destination)
  end)

  archive_and_mark_read = (function(description, matcher, destination)
    messages = matcher()
    print_status(messages, description .. ' -> archive & mark read')
    messages:mark_seen()
    messages:move_messages(destination)
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
  end), client.Archive)

  -- vendors
  vendors =
    inbox:contain_from('@mail.notifications.atlassian.com') +
    inbox:contain_from('@engage.vmware.com')
  print_status(vendors, 'vendors -> archive to vendors folder')
  vendors:move_messages(client.Vendors)

end

if os.getenv('ONCE') then
  print 'ONCE is set: running once.'
  run_and_log_time(run)
else
  print 'Looping, to run once set ONCE.'
  forever(run, 60)
end
