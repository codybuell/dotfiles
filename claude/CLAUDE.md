# STYLE: BLUF
- **Punchline first:** First sentence states the answer, verdict, or outcome. No
  preamble, no restating the question. Supporting detail follows, ordered by
  how likely I am to need it.
- **Default short:** Answers to questions are ≤3 sentences. I'll say "expand"
  when I want depth — don't pre-emptively elaborate. Deliverables (code,
  reviews, plans) run their natural length.
- **Structure over compression:** Past ~5 lines, use `##` headings, bullets,
  and short paragraphs so the eye can navigate. Cut whole details that don't
  change my next action; never compress by mangling sentences into fragments
  or dropping articles — complete sentences scan faster.
- **Bold the load-bearing words:** Only terms that carry the decision or
  verdict. If everything is bold, nothing is.
- **Literal code:** Keep technical terms, paths, and code blocks 100% exact.
- **No fluff:** Skip intros, outros, pleasantries, hedging, and filler
  ("basically", "actually", "just").

# DOTFILES
Repo: `~/Repos/github.com/codybuell/dotfiles`. Its `dotfiles/` folder holds
templated versions of configs deployed to `~` (e.g. `dotfiles/config/tmux/tmux.conf`
→ `~/.config/tmux/tmux.conf`). When editing a deployed config, mirror the change
in the repo's template or it will be lost on next deploy.

# GIT COMMITS
Follow tpope's standard (https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html).
Matches `~/.config/nvim/ftplugin/gitcommit.lua`, which sets `cc = {51, 73}`.
- **Subject ≤50 chars**, capitalized, imperative mood ("Add", "Fix", not "Added"/"Adds"), **no trailing period**.
- **Blank line**, then body **hard-wrapped at 72 columns**. Never rely on the reader's terminal to wrap.
- **Explain what and why, not how** — the diff already shows how. Prior decisions, rejected alternatives, and non-obvious constraints belong here.
- Bullets use `-`, hanging-indented to align.
- Committing is fine (see permissions memory); pushing is not, unless asked.

# TOOLS
- **Read** files with Read — never `cat`, `head`, `tail`, or `sed -n`.
- **Edit** files with Edit/Write — never `sed -i`, `python3 -c`, `echo >`, or heredocs.
- **Search** with Grep/Glob when available. If those tools are absent from the session, `grep`/`rg` via Bash is the fallback — say so rather than silently shelling out.
- **Shell is for running things**: builds, tests, git, servers, package managers, one-off binaries. Not for reading or writing file contents.
- **Exception:** multi-file or regex-driven transforms, where one script genuinely beats many Edit calls. Single-file literal replacements are not this.
- **Why:** native tools show the user a diff, fail loudly on a missing or ambiguous anchor, and require reading a file before overwriting it. Shell equivalents are silent, no-op on a failed match, and skip that guard.
