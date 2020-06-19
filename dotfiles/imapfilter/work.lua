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
  msadmin  = work['MS Admin']
  mssupp   = work['MS Support']
  msmark   = work['MS Marketing']
  bonusly  = work['Bonusly']

  -- list mailboxes and folders
--  mailboxes, folders = work:list_all()
--  for _, m in ipairs(mailboxes) do print(m) end
--  for _, f in ipairs(folders) do print(f) end

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

  -- meeting responses
  -- git related
  -- aws related
  -- microsoft related

  -- mark all spam as read
  new_spam = spam:is_unseen()
  print_status(new_spam, 'unread spam -> mark as read')
  new_spam:mark_seen()

  -- all git related crap, except due date reminders
  movetofolder('git related notifications', git, (function()
    results = inbox:match_field('Reply-To', 'GitLab .*') + 
              inbox:match_field('Reply-To', '.*internal-service-account+.*') -
              inbox:contain_body('The following issue is due on')
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

  -- notion related emails
  movetofolder('notion messages', notion, (function()
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

  -- aws admin emails
  movetofolder('aws admin messages', awsadmin, (function()
    results = inbox
      :contain_field('X-AMAZON-MAIL-RELAY-TYPE', 'notification')
    return results
  end))

  -- aws marketing emails
  movetofolder('aws marketing messages', awsmark, (function()
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
  movetofolder('new aws mp customers', awsmp, (function()
    results = inbox
      :contain_from('aws-account-inbox@cloudtamer.io')
      :contain_subject('You have a new Daily')
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
  movetofolder('meeting messages', meetings, (function()
    results = inbox:match_subject('^Invitation: .*') +
              inbox:match_subject('^Declined: .*') +
              inbox:match_subject('^Accepted: .*') +
              inbox:match_subject('^Updated invitation: .*') +
              inbox:match_subject('^Updated invitation with note: .*') +
              inbox:match_subject('^Canceled: .*') +
              inbox:match_subject('^Canceled event: .*') +
              inbox:match_subject('^Canceled event with note: .*')
    return results
  end))

  -- github personal action notifications
  archive_and_mark_read('github personal activity', (function()
    own = inbox:match_field('X-GitHub-Sender', '{{ GitUsername }}')
    return own + github_related(own)
  end))

  -- bonusly
  movetofolder('bonusly messages', bonusly, (function()
    results = inbox
      :contain_from('noreply@bonus.ly')
--    :contain_subject('did something awesome')
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
