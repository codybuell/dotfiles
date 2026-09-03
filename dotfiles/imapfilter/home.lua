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

  local bellhop_app     = home['Bellhop-App']
  local bellhop_support = home['Bellhop-Support']
  local bellhop_team    = home['Bellhop-Team']
  local robot_admin     = home['Robot-Admin']
  local robot_contact   = home['Robot-Contact']
  local robot_support   = home['Robot-Support']
  local murdock         = home['Murdock']
  local feed            = home['Feed']

  --
  -- Rules
  --

  -- mark all spam as read
  local new_spam = spam:is_unseen()
  print_status(new_spam, 'unread spam -> mark as read')
  new_spam:mark_seen()

  -- bellhop infrastructure alerts: flag but leave in the inbox so they are
  -- impossible to miss (and so gmail still pushes phone notifications)
  flag('bellhop infra alerts', (function()
    return addressed_to('alerts@mybellhop.ai'):is_unflagged()
  end))

  -- route the remaining role addresses out of the inbox by recipient; these
  -- are work queues to be visited on purpose, not interrupts
  movetofolder('bellhop support queue', bellhop_support, (function()
    return addressed_to('support@mybellhop.ai')
  end))
  movetofolder('bellhop team mail', bellhop_team, (function()
    return addressed_to('team@mybellhop.ai')
  end))
  movetofolder('bellhop app notifications', bellhop_app, (function()
    return inbox:contain_from('noreply@mybellhop.ai')
  end))
  movetofolder('company robot admin', robot_admin, (function()
    return addressed_to('admin@companyrobot.io')
  end))
  movetofolder('company robot contact', robot_contact, (function()
    return addressed_to('contact@companyrobot.io')
  end))
  movetofolder('company robot support', robot_support, (function()
    return addressed_to('support@companyrobot.io')
  end))
  -- NOTE: cody@companyrobot.io is intentionally not routed; humans writing to
  -- a personal address belong in the inbox

  -- murdock traffic
  movetofolder('murdock', murdock, (function()
    return addressed_to('murdock@codybuell.com')
  end))

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

  -- LAST: sweep whatever bulk mail is still in the inbox into Feed. Anything
  -- with a List-Unsubscribe header is machine-generated (newsletters, deals,
  -- product notifications). Runs after all routing rules so classified mail
  -- keeps its folder; skips flagged mail so alerts are never swept.
  movetofolder('bulk mail sweep', feed, (function()
    return inbox:contain_field('List-Unsubscribe', ''):is_unflagged() - github()
  end))
end

if os.getenv('ONCE') then
  print 'ONCE is set: running once.'
  run_and_log_time(run)
else
  print 'Looping, to run once set ONCE.'
  forever(run, 60)
end
