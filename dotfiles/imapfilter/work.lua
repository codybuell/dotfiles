dofile(os.getenv('HOME') .. '/.imapfilter/common.lua')

local me = '{{ WorkEmailUsername }}'
local password = get_pass('{{ WorkEmailKeychain }}', '{{ WorkEmailHost }}')

function connect()
  return IMAP {
    server = '{{ WorkEmailHost }}',
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
  work     = connect()
  inbox    = work.INBOX
  spam     = work['[Gmail]/Spam']
  allmail  = work['[Gmail]/All Mail']
  git      = work['Git']
  jira     = work['Jira']
  meetings = work['Meetings']
  bamboo   = work['Bamboo']
  notion   = work['Notion']
  zendesk  = work['Zendesk']
  awsadmin = work['AWS Admin']
  awssupp  = work['AWS Support']
  awsmark  = work['AWS Marketing']
  awsmp    = work['AWS Marketplace']
  awspart  = work['AWS Partner']
  google   = work['Google']
  msadmin  = work['MS Admin']
  mssupp   = work['MS Support']
  msmark   = work['MS Marketing']
  bonusly  = work['Bonusly']
  employee = work['Past Employees']
  netdata  = work['Netdata']
  security = work['Security']
  grnhouse = work['Greenhouse']
  escrow   = work['Code Escrow']
  kion     = work['Kion']

  -- List mailboxes and folders
  --mailboxes, folders = work:list_all()
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

  movetofolder_and_mark_read = (function(description, folder, matcher)
    messages = matcher()
    print_status(messages, description .. ' -> move to folder & mark read')
    messages:mark_seen()
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

  -- meeting responses
  -- git related
  -- aws related
  -- microsoft related

  -- mark all spam as read
  new_spam = spam:is_unseen()
  print_status(new_spam, 'unread spam -> mark as read')
  new_spam:mark_seen()

  -- all git related crap, except due date reminders, failed pipelines, gitlab support
  movetofolder_and_mark_read('git related notifications', git, (function()
    results = inbox:match_field('Reply-To', 'GitLab .*') +
              inbox:match_field('Reply-To', '.*internal-service-account+.*') -
              inbox:contain_body('The following issue is due on') -
              inbox:contain_subject('Failed pipeline for .*') -
              inbox:contain_from('GitLab Support')
--    :contains_field('X-GitLab-NotificationReason', 'mentioned')
    return results
  end))

  -- all jira related crap
  movetofolder('jira messages', jira, (function()
    results = inbox
      :match_field('In-Reply-To', '.*@Atlassian.JIRA>')
    return results
  end))

  -- all bamboohr related crap
  movetofolder('bamboo messages', bamboo, (function()
    results = inbox
      :contain_field('Sender', 'notifications@app.bamboohr.com')
    return results
  end))

  -- all greenhouse related crap
  movetofolder('greenhouse messages', grnhouse, (function()
    results = inbox
      :contain_field('Sender', 'no-reply@greenhouse.io')
    return results
  end))

  -- notion related emails
  movetofolder_and_mark_read('notion messages', notion, (function()
    results = inbox
      :contain_from('^Notion .*')
    return results
  end))

  -- zendesk related emails
  movetofolder('zendesk messages', zendesk, (function()
    results = inbox
      :contain_field('X-Mailer', 'Zendesk Mailer (HC)')
    return results
  end))

  -- netdata related emails
  movetofolder('netdata messages', netdata, (function()
    results = inbox
      :contain_from('Netdata .*')
    return results
  end))

  -- netdata related emails
  movetofolder('dmarc reports', security, (function()
    results = inbox:contain_from('.?dmarc.*') +
              inbox:contain_subject('Report domain: kion.io .*')
    return results
  end))

  -- aws admin emails
  movetofolder('aws admin messages', awsadmin, (function()
    results = inbox
      :contain_field('X-AMAZON-MAIL-RELAY-TYPE', 'notification')
    return results
  end))

  -- aws marketing emails
  movetofolder_and_mark_read('aws marketing messages', awsmark, (function()
    results = inbox:contain_field('Reply-To', 'aws-marketing-email-replies@amazon.com') +
              inbox:contain_field('Reply-To', 'aws-marketplace-email-replies@amazon.com') +
              inbox:contain_field('Reply-To', 'aws-customer-research@amazon.com') +
              inbox:contain_subject('Getting Started with Amazon .*')
    return results
  end))

  -- aws marketplace new daily customers
  movetofolder('new parter portal', awspart, (function()
    results = inbox
      :contain_from('apn-training-noreply@awspartner.com')
    return results
  end))

  -- aws marketplace new daily customers
  movetofolder_and_mark_read('new aws marketplace', awsmp, (function()
    results = inbox:contain_from('aws-account-inbox@kion.io'):contain_subject('You have a new Daily') +
              inbox:contain_from('AWS Marketplace') +
              inbox:contain_field('X-Original-Sender','aws-marketing-email-replies@amazon.com')
    return results
  end))

  -- microsoft admin emails
  movetofolder('microsoft admin messages', msadmin, (function()
    results = inbox:contain_field('Return-Path', 'azure-noreply@microsoft.com') +
              inbox:contain_field('Return-Path', 'o365mc@microsoft.com') +
              inbox:contain_from('msonlineservicesteam@email.microsoftonline.com')
    return results
  end))

  -- all meeting accepts, declines, updates, etc
  movetofolder_and_mark_read('meeting messages', meetings, (function()
    results = inbox:match_subject('^Invitation: .*') +
              inbox:match_subject('^Declined: .*') +
              inbox:match_subject('^Accepted: .*') +
              inbox:match_subject('^Updated invitation: .*') +
              inbox:match_subject('^Updated invitation with note: .*') +
              inbox:match_subject('^Canceled: .*') +
              inbox:match_subject('^Canceled event: .*') +
              inbox:match_subject('^Canceled event with note: .*') +
              inbox:contain_from('meetings@macro.io')
    return results
  end))

  -- cms services related emails
  archive_and_mark_read('cms services messages', (function()
    results = inbox
      :contain_from('cmslists@subscriptions.cms.hhs.gov')
    return results
  end))

  -- github personal action notifications
  -- archive_and_mark_read('github personal activity', (function()
  --   own = inbox:match_field('X-GitHub-Sender', '{{ GitUsername }}')
  --   return own + github_related(own)
  -- end))

  -- bonusly
  movetofolder_and_mark_read('bonusly messages', bonusly, (function()
    results = inbox:contain_from('noreply@bonus.ly') +
              inbox:contain_from('system@bonus.ly')
--    :contain_subject('did something awesome')
    return results
  end))

  -- google
  movetofolder('google bits', google, (function()
    results = inbox:contain_from('noreply+workspace@google.com') +
              inbox:contain_from('google-workspace-alerts-noreply@google.com')
    return results
  end))

  -- zoom john doe has joined your meeting
  archive_and_mark_read('zoom meeting attendee', (function()
    results = inbox
      :contain_from('no-reply@zoom.us')
      :contain_subject('has joined your meeting -')
    return results
  end))

  -- past employees
  movetofolder('past employee messages', employee, (function()
    results = inbox:contain_to('cmagee@cloudtamer.io') +
              inbox:contain_to('jspurrier@kion.io') +
              inbox:contain_to('jspurrier@cloudtamer.io')
    return results
  end))

  -- code escrow related emails
  movetofolder('code escrow', escrow, (function()
    results = inbox:match_field('Reply-To', '	ipmvaultadministration@nccgroup.com') +
              inbox:contain_subject('RE: Materials Received for Escrow Account Number *')
    return results
  end))

  -- kion application notifications
  movetofolder('kion app', kion, (function()
    results = inbox:contain_subject('Kion | *') *
              inbox:contain_from('noreply@kion.io')
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
