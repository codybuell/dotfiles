dofile(os.getenv('HOME') .. '/.imapfilter/common.lua')

local me = '{{ ProjEmailUsername }}'
local password = get_pass('{{ ProjEmailKeychain }}', '{{ ProjEmailHost }}')

function connect()
  return IMAP {
    server = '{{ ProjEmailHost }}',
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

  -- Define our mailboxes
  proj    = connect()
  inbox   = proj.INBOX
  spam    = proj['[Gmail]/Spam']
  allmail = proj['[Gmail]/All Mail']
  deals   = proj['Deals']
  finance = proj['Fianances']

  -- List mailboxes and folders
  --mailboxes, folders = proj:list_all()
  --for _, m in ipairs(mailboxes) do print(m) end
  --for _, f in ipairs(folders) do print(f) end

  --
  -- Helpers
  --

  movetofolder = (function(description, folder, matcher)
    messages = matcher()
    print_status(messages, description .. ' -> move to folder')
    messages:move_messages(folder)
  end)

  archive = (function(description, matcher)
    messages = matcher()
    print_status(messages, description .. ' -> archive')
    messages:move_messages(allmail)
  end)

  archive_and_mark_read = (function(description, matcher)
    messages = matcher()
    print_status(messages, description .. ' -> archive & mark read')
    messages:mark_seen()
    messages:move_messages(allmail)
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

--  -- mark all spam as read
--  new_spam = spam:is_unseen()
--  print_status(new_spam, 'unread spam -> mark as read')
--  new_spam:mark_seen()
--
--  -- all 'deals'
--  movetofolder('deals', deals, (function()
--    results = inbox:contain_from('HomeDepotCustomerCare@email.homedepot.com') +
--              inbox:contain_from('miniaturemarket@bm5150.com') +
--              inbox:contain_from('email@zaxbysemailclub.com')
--    return results
--  end))
--
--  -- all finance related messages
--  movetofolder('finance', finance, (function()
--    results = inbox:contain_from('noreply@robinhood.com') +
--              inbox:contain_from('no.reply.alerts@chase.com') +
--              inbox:contain_from('service@personalcapital.com') +
--              inbox:contain_from('email@enews.nasafcu.com')
--    return results
--  end))

--  messages =
--    inbox:contain_from('info@reprorights.org') +
--    inbox:contain_from('members@nrdcaction.org')
--  print_status(messages, '* -> Lists')
--  messages:move_messages(proj.Lists)

--  messages = (
--    inbox:contain_from('Lambda-Legal@lambdalegal.org') +
--    inbox:contain_from('givewell.org') +
--    inbox:contain_from('info@ppnorcal.org') +
--    inbox:contain_from('no-reply@thetrevorproject.org') +
--    inbox:contain_from('pponline@ppfa.org')
--  ):match_field('X-campaignid', '.')
--  print_status(messages, 'Campaigns -> Lists')
--  messages:move_messages(proj.Lists)

--  messages = inbox:contain_field('X-GitHub-Sender', 'wincent')
--  messages = messages + github_related(messages)
--  print_status(messages, 'GitHub own activity -> archive & mark read')
--  messages:mark_seen()
--  messages:delete_messages() -- Archive

  archive_and_mark_read('github personal activity', (function()
    own = inbox:match_field('X-GitHub-Sender', '{{ GitUsername }}')
    return own + github_related(own)
  end))

--  archive_and_mark_read('old daily deals', (function()
--    results = inbox
--      :is_older(0)
--      :contain_from('newsletters@audible.com')
--    return results
--  end))

--  messages = inbox
--    :contain_from('root@masochist.unixhosts.net')
--    :contain_subject('cron.daily')
--  print_status(messages, 'Cron -> Cron')
--  messages:move_messages(proj.Cron)

--  messages = inbox:contain_from('logwatch@masochist.unixhosts.net')
--  print_status(messages, 'Logwatch -> Logwatch')
--  messages:move_messages(proj.Logwatch)

--  messages = Set {}
--  all = inbox:select_all()
--  for i, address in ipairs(RECRUITERS) do
--    messages = messages + all:match_from(address)
--  end
--  print_status(messages, '* -> Recruiting')
--  messages:move_messages(proj.Recruiting)
end

if os.getenv('ONCE') then
  print 'ONCE is set: running once.'
  run_and_log_time(run)
else
  print 'Looping, to run once set ONCE.'
  forever(run, 60)
end
