#!/usr/bin/env ruby

# Account list comes from ~/.mutt/accounts (generated from the MailAccounts
# .config key at deploy time): "name caps go-key flags" per line.
accounts = File.readlines(ENV['HOME'] + '/.mutt/accounts')
                .map(&:strip)
                .reject { |l| l.empty? || l.start_with?('#') }
                .map { |l| l.split[1] }

SUFFIX_PRIORITY = {
  '' => '00',
  '.Starred' => '01',
  '.Sent' => '02',
  '.Drafts' => '03',
  '.Archive' => '04',
  '.Trash' => '05',
  '.Spam' => '06',
}

PRIORITY = {}
accounts.each do |account|
  SUFFIX_PRIORITY.each { |suffix, pri| PRIORITY[account + suffix] = pri }
end

mailboxes = []
Dir.chdir(ENV['HOME'] + '/.mail') do
  Dir["{#{accounts.join(',')}}/*"].each do |d|
    # Sent and Archive are append-only history, not queues; keep them out of
    # the sidebar (and the always-gold Archive noise with them) and reach
    # them with the gt / ga macros instead.
    next if d =~ /\.(Sent|Archive)$/
    mailboxes << %{"+#{d}"}
  end
end
mailboxes.sort! do |a, b|
  account_a, mailbox_a = a.split('.')
  account_b, mailbox_b = b.split('.')
  key_a = account_a + PRIORITY.fetch(mailbox_a || account_a, '99') + mailbox_a.to_s
  key_b = account_b + PRIORITY.fetch(mailbox_b || account_b, '99') + mailbox_b.to_s
  key_a <=> key_b
end

File.open(ENV['HOME'] + '/.mutt/config/mailboxes.mutt', 'w') do |f|
  f.puts "mailboxes #{mailboxes.join(' ')}"

  # Pin account inboxes so they survive $sidebar_non_empty_mailbox_only when
  # emptied (inbox zero); everything else may hide itself at zero.
  pins = accounts.select do |account|
    File.directory?(ENV['HOME'] + "/.mail/#{account}/#{account}")
  end
  unless pins.empty?
    f.puts "sidebar_pin #{pins.map { |account| %{"+#{account}/#{account}"} }.join(' ')}"
  end
end
