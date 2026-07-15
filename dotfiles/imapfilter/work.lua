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

  local work = connect()
  inbox      = work.INBOX
  local spam = work['[Gmail]/Spam']
  allmail    = work['[Gmail]/All Mail']

  local git      = work['Git']
  local jira     = work['Jira']
  local meetings = work['Meetings']
  local bamboo   = work['Bamboo']
  local notion   = work['Notion']
  local ramp     = work['Ramp']
  local zendesk  = work['Zendesk']
  local awsadmin = work['AWS Admin']
  local awssupp  = work['AWS Support']
  local awsmark  = work['AWS Marketing']
  local awsmp    = work['AWS Marketplace']
  local awspart  = work['AWS Partner']
  local google   = work['Google']
  local msadmin  = work['MS Admin']
  local mssupp   = work['MS Support']
  local msmark   = work['MS Marketing']
  local bonusly  = work['Bonusly']
  local employee = work['Past Employees']
  local netdata  = work['Netdata']
  local security = work['Security']
  local grnhouse = work['Greenhouse']
  local escrow   = work['Code Escrow']
  local kion     = work['Kion']

  --
  -- Rules
  --

  -- mark all spam as read
  local new_spam = spam:is_unseen()
  print_status(new_spam, 'unread spam -> mark as read')
  new_spam:mark_seen()

  -- all git related crap, except due date reminders, failed pipelines, gitlab support
  movetofolder_and_mark_read('git related notifications', git, (function()
    return inbox:match_field('Reply-To', 'GitLab .*') +
           inbox:match_field('Reply-To', '.*internal-service-account+.*') -
           inbox:contain_body('The following issue is due on') -
           inbox:contain_subject('Failed pipeline for .*') -
           inbox:contain_from('GitLab Support')
  end))

  -- all jira related crap
  movetofolder('jira messages', jira, (function()
    return inbox:match_field('In-Reply-To', '.*@Atlassian.JIRA>')
  end))

  -- all bamboohr related crap
  movetofolder('bamboo messages', bamboo, (function()
    return inbox:contain_field('Sender', 'notifications@app.bamboohr.com')
  end))

  -- all greenhouse related crap
  movetofolder('greenhouse messages', grnhouse, (function()
    return inbox:contain_field('Sender', 'no-reply@greenhouse.io')
  end))

  -- all ramp related emails
  movetofolder('ramp messages', ramp, (function()
    return inbox:contain_from('^Ramp .*')
  end))

  -- notion related emails
  movetofolder_and_mark_read('notion messages', notion, (function()
    return inbox:contain_from('^Notion .*')
  end))

  -- zendesk related emails
  movetofolder('zendesk messages', zendesk, (function()
    return inbox:contain_field('X-Mailer', 'Zendesk Mailer (HC)')
  end))

  -- netdata related emails
  movetofolder('netdata messages', netdata, (function()
    return inbox:contain_from('Netdata .*')
  end))

  -- dmarc reports
  movetofolder('dmarc reports', security, (function()
    return inbox:contain_from('.?dmarc.*') +
           inbox:contain_subject('Report domain: kion.io .*') +
           inbox:contain_subject('Report domain: norlabs.com .*')
  end))

  -- aws admin emails
  movetofolder('aws admin messages', awsadmin, (function()
    return inbox:contain_field('X-AMAZON-MAIL-RELAY-TYPE', 'notification')
  end))

  -- aws marketing emails
  movetofolder_and_mark_read('aws marketing messages', awsmark, (function()
    return inbox:contain_field('Reply-To', 'aws-marketing-email-replies@amazon.com') +
           inbox:contain_field('Reply-To', 'aws-marketplace-email-replies@amazon.com') +
           inbox:contain_field('Reply-To', 'aws-customer-research@amazon.com') +
           inbox:contain_subject('Getting Started with Amazon .*')
  end))

  -- aws partner portal
  movetofolder('new partner portal', awspart, (function()
    return inbox:contain_from('apn-training-noreply@awspartner.com')
  end))

  -- aws marketplace new daily customers
  movetofolder_and_mark_read('new aws marketplace', awsmp, (function()
    return inbox:contain_from('aws-account-inbox@kion.io'):contain_subject('You have a new Daily') +
           inbox:contain_from('AWS Marketplace') +
           inbox:contain_field('X-Original-Sender','aws-marketing-email-replies@amazon.com')
  end))

  -- microsoft admin emails
  movetofolder('microsoft admin messages', msadmin, (function()
    return inbox:contain_field('Return-Path', 'azure-noreply@microsoft.com') +
           inbox:contain_field('Return-Path', 'o365mc@microsoft.com') +
           inbox:contain_from('msonlineservicesteam@email.microsoftonline.com')
  end))

  -- all meeting accepts, declines, updates, etc
  movetofolder_and_mark_read('meeting messages', meetings, (function()
    return inbox:match_subject('^Invitation: .*') +
           inbox:match_subject('^Declined: .*') +
           inbox:match_subject('^Accepted: .*') +
           inbox:match_subject('^Updated invitation: .*') +
           inbox:match_subject('^Updated invitation with note: .*') +
           inbox:match_subject('^Canceled: .*') +
           inbox:match_subject('^Canceled event: .*') +
           inbox:match_subject('^Canceled event with note: .*') +
           inbox:contain_from('meetings@macro.io')
  end))

  -- cms services related emails
  archive_and_mark_read('cms services messages', (function()
    return inbox:contain_from('cmslists@subscriptions.cms.hhs.gov')
  end))

  -- bonusly
  movetofolder_and_mark_read('bonusly messages', bonusly, (function()
    return inbox:contain_from('noreply@bonus.ly') +
           inbox:contain_from('system@bonus.ly')
  end))

  -- google
  movetofolder('google bits', google, (function()
    return inbox:contain_from('noreply+workspace@google.com') +
           inbox:contain_from('google-workspace-alerts-noreply@google.com')
  end))

  -- zoom john doe has joined your meeting
  archive_and_mark_read('zoom meeting attendee', (function()
    return inbox
      :contain_from('no-reply@zoom.us')
      :contain_subject('has joined your meeting -')
  end))

  -- past employees
  movetofolder('past employee messages', employee, (function()
    return inbox:contain_to('cmagee@cloudtamer.io') +
           inbox:contain_to('jspurrier@kion.io') +
           inbox:contain_to('jspurrier@cloudtamer.io')
  end))

  -- code escrow related emails
  movetofolder('code escrow', escrow, (function()
    return inbox:match_field('Reply-To', '	ipmvaultadministration@nccgroup.com') +
           inbox:contain_subject('RE: Materials Received for Escrow Account Number *')
  end))

  -- kion application notifications
  movetofolder('kion app', kion, (function()
    return inbox:contain_subject('Kion | *') *
           inbox:contain_from('noreply@kion.io')
  end))
end

if os.getenv('ONCE') then
  print 'ONCE is set: running once.'
  run_and_log_time(run)
else
  print 'Looping, to run once set ONCE.'
  forever(run, 60)
end
