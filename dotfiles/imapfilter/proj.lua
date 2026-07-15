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

  local proj = connect()
  inbox      = proj.INBOX
  allmail    = proj['[Gmail]/All Mail']

  --
  -- Rules
  --

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
