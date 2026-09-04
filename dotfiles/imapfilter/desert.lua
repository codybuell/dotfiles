dofile(os.getenv('HOME') .. '/.imapfilter/common.lua')

local me = '{{ DesertEmailUsername }}'
local password = get_pass('{{ DesertEmailKeychain }}', '{{ DesertEmailHost }}')

function connect()
  return IMAP {
    server = '{{ DesertEmailHost }}',
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

  local desert = connect()
  inbox      = desert.INBOX
  allmail    = desert['[Gmail]/All Mail']

  --
  -- Rules
  --

  -- vip senders: flag so they stand out in the index
  flag_vips('{{ DesertEmailVips }}')

  -- github personal action notifications
  archive_and_mark_read('github personal activity', (function()
    local own = inbox:match_field('X-GitHub-Sender', '{{ GitUsername }}')
    return own + github_related(own)
  end))
end

if os.getenv('ONCE') then
  print 'ONCE is set: running once.'
  run_and_log_time(run)
else
  print 'Looping, to run once set ONCE.'
  forever(run, 60)
end
