#!/usr/bin/env python3
"""Audit template tokens in dotfiles against .config keys.

Every `{{ Token }}` in a templated dotfile must resolve at deploy time:
either a key in .config, one of the variables library.sh seeds into
CONFIGVARS, or a MailAcct* token that mailgen.py expands (validated
against the MailAccounts list). Anything else deploys as a literal
`{{ Token }}` — this catches those before they ship.

Run via `make check`. Requires an unlocked .config.
"""

import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOTFILES = os.path.join(REPO, 'dotfiles')

# untemplated trees (vendored code, generated output, binaries)
EXCLUDE_DIRS = {
    'dotfiles/config/nvim/pack',
    'dotfiles/config/nvim/tmp',
    'dotfiles/mutt/scripts/vendor',
    'dotfiles/terminfo',
    'dotfiles/zsh/plugins',
    'dotfiles/zsh/colors/scripts',
    'dotfiles/config/kitty/colors',
    'dotfiles/config/tmux/colors',
}

# variables library.sh seeds into CONFIGVARS without .config entries
BUILTINS = {'CONFIGDIR', 'UNAME', 'HOMEDIR', 'HOMEBREW_PREFIX'}

# tokens mailgen.py rewrites during stanza expansion
MAILGEN = {'MailAcct', 'MailAcctCaps', 'MailAcctKey', 'MailAcctFlags'}

TOKEN = re.compile(r'\{\{\s*([A-Za-z][A-Za-z0-9_]*)\s*\}\}')
KEY_LINE = re.compile(r'^([A-Za-z_][A-Za-z0-9_]*)\s*=')


def config_keys():
    keys = set()
    with open(os.path.join(REPO, '.config')) as f:
        for line in f:
            m = KEY_LINE.match(line)
            if m:
                keys.add(m.group(1))
    return keys


def mail_account_caps(keys):
    spec = ''
    with open(os.path.join(REPO, '.config')) as f:
        for line in f:
            if line.startswith('MailAccounts'):
                spec = line.split('=', 1)[1].split('#')[0]
                break
    caps = []
    for entry in spec.split(','):
        name = entry.strip().split(':')[0]
        if name:
            caps.append(name.capitalize())
    return caps


def main():
    keys = config_keys()
    caps = mail_account_caps(keys)
    problems = []

    for root, dirs, files in os.walk(DOTFILES):
        rel = os.path.relpath(root, REPO)
        dirs[:] = [d for d in sorted(dirs)
                   if os.path.join(rel, d).replace(os.sep, '/') not in EXCLUDE_DIRS]
        for name in sorted(files):
            path = os.path.join(root, name)
            try:
                with open(path, encoding='utf-8') as f:
                    lines = f.readlines()
            except (UnicodeDecodeError, OSError):
                continue
            for n, line in enumerate(lines, 1):
                for token in TOKEN.findall(line):
                    if token in keys or token in BUILTINS or token in MAILGEN:
                        continue
                    if token.startswith('MailAcctEmail'):
                        suffix = token[len('MailAcct'):]  # Email<Xxx>
                        missing = [c for c in caps if c + suffix not in keys]
                        if missing:
                            problems.append(
                                f"{os.path.relpath(path, REPO)}:{n}: "
                                f"{{{{ {token} }}}} unresolvable for account(s) "
                                + ', '.join(missing))
                        continue
                    problems.append(
                        f"{os.path.relpath(path, REPO)}:{n}: "
                        f"{{{{ {token} }}}} has no .config key")

    if problems:
        print("unresolvable template tokens (would deploy literally):")
        for p in problems:
            print("  " + p)
        sys.exit(1)
    print(f"template tokens OK ({len(keys)} config keys, "
          f"{len(caps)} mail accounts)")


if __name__ == '__main__':
    main()
