#!/usr/bin/env python3
"""Expand per-mail-account stanzas in dotfile templates.

The set of mail accounts is private configuration, so template files in the
public repo carry ONE generic stanza wrapped in loop markers, and this script
expands it into a block per account at deploy time (dots.sh runs it on the
staged copy before variable substitution). Account names therefore only ever
exist in the encrypted .config and in the deployed files under $HOME.

Accounts come from the MailAccounts key in .config (via the environment):

    MailAccounts = home:h, work:w:slow-archive, other:o

Each entry is name:go-key[:flag[,flag...]]. The go-key drives the mutt g<key>
account-switch macro. Recognized flags:

    slow-archive  large account; keep All Mail out of the main mbsync group
                  and sync it hourly via the <name>-archive group (sync.sh)
    nosync        keep the account configured and its maildir browsable in
                  mutt, but start no sync pane and never pull mail (home()
                  and control.sh skip it; sync.sh refuses to run it)

Markers sit alone on comment lines so unexpanded templates stay valid syntax:

    # {{% foreach mailaccount %}}
    ...stanza, may contain:
    #   {{ MailAcct }}         account name, lowercase (home)
    #   {{ MailAcctCaps }}     capitalized (Home) - maildir / channel names
    #   {{ MailAcctKey }}      the go-key (h)
    #   {{ MailAcctFlags }}    comma joined flags, '-' if none
    #   {{ MailAcctEmailXxx }} becomes {{ <Caps>EmailXxx }} for dots.sh to fill
    # {{% if slow-archive %}} / # {{% else %}} / # {{% endif %}}
    # {{% endforeach %}}
"""

import os
import re
import sys

FOREACH = re.compile(r'^\s*#\s*\{\{%\s*foreach mailaccount\s*%\}\}\s*$')
ENDFOR = re.compile(r'^\s*#\s*\{\{%\s*endforeach\s*%\}\}\s*$')
IF = re.compile(r'^\s*#\s*\{\{%\s*if ([a-z-]+)\s*%\}\}\s*$')
ELSE = re.compile(r'^\s*#\s*\{\{%\s*else\s*%\}\}\s*$')
ENDIF = re.compile(r'^\s*#\s*\{\{%\s*endif\s*%\}\}\s*$')


def parse_accounts(spec):
    accounts = []
    for entry in spec.split(','):
        entry = entry.strip()
        if not entry:
            continue
        # a token with no ':' is a continuation of the previous entry's
        # flag list (name:key:flag,flag splits on the comma above)
        if ':' not in entry:
            if not accounts:
                sys.exit(f"mailgen: flag '{entry}' before any account in MailAccounts")
            accounts[-1]['flags'].append(entry)
            continue
        parts = [p.strip() for p in entry.split(':')]
        name = parts[0]
        if not re.fullmatch(r'[a-z][a-z0-9]*', name):
            sys.exit(f"mailgen: bad account name '{name}' in MailAccounts")
        accounts.append({
            'name': name,
            'caps': name.capitalize(),
            'key': parts[1] if len(parts) > 1 else name[0],
            'flags': parts[2].split(',') if len(parts) > 2 else [],
        })
    if not accounts:
        sys.exit("mailgen: MailAccounts parsed to zero accounts")
    return accounts


def render_block(lines, acct):
    out = []
    keep = True
    stack = []  # (parent_keep, if_branch_taken)
    for line in lines:
        m = IF.match(line)
        if m:
            cond = m.group(1) in acct['flags']
            stack.append((keep, cond))
            keep = keep and cond
        elif ELSE.match(line):
            parent, cond = stack[-1]
            keep = parent and not cond
        elif ENDIF.match(line):
            parent, _ = stack.pop()
            keep = parent
        elif keep:
            out.append(line)
    if stack:
        sys.exit("mailgen: unterminated {{% if %}} block")
    text = ''.join(out)
    # order matters: longest-prefix tokens first so {{ MailAcct }} can't eat
    # the front of the others
    text = text.replace('{{ MailAcctEmail', '{{ ' + acct['caps'] + 'Email')
    text = re.sub(r'\{\{\s*MailAcctCaps\s*\}\}', acct['caps'], text)
    text = re.sub(r'\{\{\s*MailAcctKey\s*\}\}', acct['key'], text)
    text = re.sub(r'\{\{\s*MailAcctFlags\s*\}\}',
                  ','.join(acct['flags']) or '-', text)
    text = re.sub(r'\{\{\s*MailAcct\s*\}\}', acct['name'], text)
    return text


def process(path, accounts):
    with open(path, encoding='utf-8') as f:
        lines = f.readlines()

    out, block, in_block, changed = [], [], False, False
    for line in lines:
        if FOREACH.match(line):
            if in_block:
                sys.exit(f"mailgen: nested foreach in {path}")
            in_block, block = True, []
        elif ENDFOR.match(line):
            if not in_block:
                sys.exit(f"mailgen: stray endforeach in {path}")
            for acct in accounts:
                out.append(render_block(block, acct))
            in_block, changed = False, True
        elif in_block:
            block.append(line)
        else:
            out.append(line)
    if in_block:
        sys.exit(f"mailgen: unterminated foreach in {path}")

    if changed:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(''.join(out))
    return changed


def main():
    spec = os.environ.get('MailAccounts', '')
    if not spec:
        sys.exit("mailgen: MailAccounts not set in environment")
    accounts = parse_accounts(spec)
    for path in sys.argv[1:]:
        process(path, accounts)


if __name__ == '__main__':
    main()
