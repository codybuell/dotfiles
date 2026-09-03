#!/usr/bin/env python3
"""Generate .config.example from .config, fail-closed.

Every `Key = value` line is scrubbed to a placeholder UNLESS the key is
explicitly allowlisted as safe to publish. Unknown keys are always scrubbed
(and warned about) so a newly added secret can never leak by omission.

After generation three guards run against the output:

  1. value-absence: no original value from a scrubbed key may appear
     anywhere in the output, comments included
  2. secret patterns: token-shaped strings (sk-, ghp_, AKIA, PEM, ...)
     fail the build unless they are a known placeholder
  3. email domains: any email outside the published-domain set fails

On any guard failure nothing is written and the exit code is non-zero.
"""

import re
import sys

CONFIG = ".config"
EXAMPLE = ".config.example"

# Keys whose real values are safe to publish. Everything else is scrubbed.
ALLOW = {
    "Name", "Email", "OSUsername", "IRCNick", "OSHomeRoot",
    "GitUsername", "GitSignKey", "WorkGitUsername",
    "DefaultEmailAccount", "DefaultEmailAccCaps",
    "HomeEmailSmtp", "HomeEmailHost", "HomeEmailKeychain",
    "HomeEmailUsername", "HomeEmailAddress",
    "WorkEmailSmtp", "WorkEmailHost",
    "ProjEmailSmtp", "ProjEmailHost",
    "Notes", "Journal", "Projects", "Domains",
    "Repos", "WorkRepos", "Gists", "CDPath", "GoPath",
    "Vault", "VaultCAPath",
}
ALLOW_RE = [re.compile(r"^PATH\d+$"), re.compile(r"^SYMLINK\d+$")]

# Curated placeholders for scrubbed keys. Keys absent here fall back to a
# generic scrub value, so listing a key is cosmetic, never load-bearing.
PLACEHOLDERS = {
    "WorkEmail": "your@workemail.com",
    "Team": "UserA,UserB,UserC",
    "GitHubHomebrewAPIToken": "1234567890abcdefghijklmnopqrstuvwxyz0123",
    "OpenAIAPIKey": "sk-123456789abcdefghijklmnopqrstuvwxyz",
    "AnthropicAPIKey": "sk-ant-api03-123456789abcdefghijklmnopqrstuvwxyz",
    "ClaudeCodeOAuthToken": "sk-ant-oat01-123456789abcdefghijklmnopqrstuvwxyz",
    "WorkGitSignKey": "1234567891234567891234567891234567891234",
    "DefaultEmailAddress": "your@email.com",
    "WorkEmailKeychain": "you+mutt@workemail.com",
    "WorkEmailUsername": "your@workemail.com",
    "WorkEmailAddress": "your@workemail.com",
    "ProjEmailKeychain": "you+mutt@othersite.com",
    "ProjEmailUsername": "you@othersite.com",
    "ProjEmailAddress": "you@othersite.com",
    "VaultToken": "1234567890abcdefghijklmnopqrstuvwxyz",
    "VaultAddress": "https://vaultserver.tld:8200",
    "VaultServer": "vaultserver.tld",
    "TPAMUrl": "tpam.tld",
    "TPAMUsername": "username",
    "TPAMPassword": "`command to get password`",
}
GENERIC = "xxxxxxxxxxxxxxxxxxxx"

# Domains allowed to appear in emails in the published example.
PUBLIC_EMAIL_DOMAINS = {
    "codybuell.com", "email.com", "workemail.com", "othersite.com",
    "github.com",  # git@github.com in ssh clone urls, not an email
}

SECRET_PATTERNS = [
    re.compile(r"sk-[A-Za-z0-9_-]{20,}"),
    re.compile(r"gh[pousr]_[A-Za-z0-9]{20,}"),
    re.compile(r"github_pat_[A-Za-z0-9_]{20,}"),
    re.compile(r"AKIA[0-9A-Z]{16}"),
    re.compile(r"xox[baprs]-[A-Za-z0-9-]+"),
    re.compile(r"eyJ[A-Za-z0-9_-]{20,}"),
    re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
    re.compile(r"ssh-(rsa|ed25519) AAAA[A-Za-z0-9+/=]+"),
]

KEY_LINE = re.compile(r"^(?P<key>[A-Za-z_][A-Za-z0-9_]*)(?P<eq>\s*=\s?)(?P<rest>.*)$")


def allowed(key):
    return key in ALLOW or any(r.match(key) for r in ALLOW_RE)


def split_comment(rest):
    m = re.search(r"\s+#", rest)
    if m:
        return rest[:m.start()], rest[m.start():]
    return rest.rstrip(), ""


def main():
    with open(CONFIG) as f:
        lines = f.read().splitlines()

    # first pass: collect raw values so paths can be re-templated
    values = {}
    for line in lines:
        m = KEY_LINE.match(line)
        if m:
            values[m.group("key")] = split_comment(m.group("rest"))[0]

    homedir = values.get("OSHomeRoot", "") + values.get("OSUsername", "")

    out, scrubbed, unknown = [], {}, []
    for line in lines:
        m = KEY_LINE.match(line)
        if not m:
            out.append(line)
            continue
        key, eq, rest = m.group("key"), m.group("eq"), m.group("rest")
        value, comment = split_comment(rest)
        if allowed(key):
            new = value
            if homedir and homedir in new:
                new = new.replace(homedir, "{{ OSHomeRoot }}{{ OSUsername }}")
        elif key in PLACEHOLDERS:
            new = PLACEHOLDERS[key]
            scrubbed[key] = value
        else:
            new = GENERIC
            scrubbed[key] = value
            unknown.append(key)
        if new == value:
            out.append(line)
        else:
            pad = ""
            if comment:
                hash_col = len(key) + len(eq) + len(value) + (len(comment) - len(comment.lstrip()))
                pad = " " * max(1, hash_col - len(key) - len(eq) - len(new))
            out.append(key + eq + new + pad + comment.lstrip() if comment else key + eq + new)

    header = (
        "# GENERATED FILE. Do not edit: produced from `.config` by `make example`.\n"
        "# See scripts/example.py for the scrub allowlist and placeholder map.\n\n"
    )
    text = header + "\n".join(out) + "\n"

    # guard 1: no scrubbed original value may survive, comments included; a
    # value also published verbatim under an allowlisted key is not a leak
    allowed_values = {v.strip().strip('"') for k, v in values.items() if allowed(k)}
    for key, value in scrubbed.items():
        inner = value.strip().strip('"')
        if (len(inner) >= 4 and inner != PLACEHOLDERS.get(key, GENERIC)
                and inner not in allowed_values and inner in text):
            sys.exit(f"LEAK: scrubbed value of '{key}' appears in generated output")

    # guard 2: token-shaped strings that are not known placeholders
    placeholder_strings = set(PLACEHOLDERS.values())
    for pat in SECRET_PATTERNS:
        for match in pat.finditer(text):
            if match.group(0) not in placeholder_strings:
                sys.exit(f"LEAK: secret-shaped string in output: {match.group(0)[:24]}...")

    # guard 3: emails must be on published domains
    for email in re.findall(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}", text):
        if email.rsplit("@", 1)[1].lower() not in PUBLIC_EMAIL_DOMAINS:
            sys.exit(f"LEAK: email outside published domains: {email}")

    if unknown:
        print(
            "warning: unknown keys scrubbed to generic placeholder "
            "(allowlist or add placeholders in scripts/example.py): "
            + ", ".join(unknown),
            file=sys.stderr,
        )

    with open(EXAMPLE, "w") as f:
        f.write(text)
    print(f"wrote {EXAMPLE} ({len(scrubbed)} values scrubbed)")


if __name__ == "__main__":
    main()
