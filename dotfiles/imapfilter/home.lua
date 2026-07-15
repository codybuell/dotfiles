dofile(os.getenv('HOME') .. '/.imapfilter/common.lua')

local me = '{{ HomeEmailUsername }}'
local password = get_pass('{{ HomeEmailKeychain }}', '{{ HomeEmailHost }}')

function connect()
  return IMAP {
    server = '{{ HomeEmailHost }}',
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

  local home = connect()
  inbox      = home.INBOX
  local spam = home['[Gmail]/Spam']
  allmail    = home['[Gmail]/All Mail']

  local deals     = home['Deals']
  local finance   = home['Fianances']
  local naughtweed = home['Naughtweed']

  --
  -- Rules
  --

  -- mark all spam as read
  local new_spam = spam:is_unseen()
  print_status(new_spam, 'unread spam -> mark as read')
  new_spam:mark_seen()

  -- naughtweed group mail
  movetofolder('naughtweed', naughtweed, (function()
    return inbox:contain_from('support@naughtweed.com') +
           inbox:contain_from('noreply@naughtweed.com') +
           inbox:contain_from('tester@naughtweed.com')
  end))

  -- all 'deals'
  movetofolder('deals', deals, (function()
    return inbox:contain_from('HomeDepotCustomerCare@email.homedepot.com') +
           inbox:contain_from('miniaturemarket@bm5150.com') +
           inbox:contain_from('email@zaxbysemailclub.com')
  end))

  -- all finance related messages
  movetofolder('finance', finance, (function()
    return inbox:contain_from('noreply@robinhood.com') +
           inbox:contain_from('no.reply.alerts@chase.com') +
           inbox:contain_from('service@personalcapital.com') +
           inbox:contain_from('email@enews.nasafcu.com')
  end))

  -- github personal action notifications
  archive_and_mark_read('github personal activity', (function()
    local own = inbox:match_field('X-GitHub-Sender', '{{ GitUsername }}')
    return own + github_related(own)
  end))

  -- old daily deals
  archive_and_mark_read('old daily deals', (function()
    return inbox
      :is_older(0)
      :contain_from('newsletters@audible.com')
  end))
end

if os.getenv('ONCE') then
  print 'ONCE is set: running once.'
  run_and_log_time(run)
else
  print 'Looping, to run once set ONCE.'
  forever(run, 60)
end
