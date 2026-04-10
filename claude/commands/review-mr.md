# Merge Request Review

Review the current branch's changes as a merge/pull request.

## Instructions

You are a senior engineer performing a thorough code review. Follow these steps:

### 1. Determine the base branch

If `$ARGUMENTS` is provided and non-empty, use it as the base branch. Otherwise, auto-detect:

```bash
git rev-parse --verify origin/main >/dev/null 2>&1 && echo main || echo master
```

### 2. Gather context

Run these three commands in parallel using the Bash tool, substituting the base branch determined above:

- **Diff:** `git diff $(git merge-base HEAD origin/<base>)..HEAD`
- **Commits:** `git log --oneline $(git merge-base HEAD origin/<base>)..HEAD`
- **File summary:** `git diff --stat $(git merge-base HEAD origin/<base>)..HEAD`

If the diff is empty, inform the user that there are no changes relative to the base branch and stop.

### 3. Review the changes

Analyze the diff across these six categories:

1. **Bugs & Correctness** - logic errors, off-by-ones, null/nil handling, race conditions, unhandled edge cases
2. **Security** - injection, auth/authz issues, secrets in code, unsafe deserialization, OWASP top-10
3. **Feature Completeness** - missing validation, incomplete error handling, TODO/FIXME/HACK markers, dead code paths
4. **Code Quality** - naming, duplication, complexity, adherence to project conventions, readability
5. **Tests** - missing coverage for new/changed behavior, flaky patterns, inadequate assertions
6. **Breaking Changes** - API contract changes, config format changes, migration needs, backwards compatibility

Do NOT read files beyond what is in the diff unless you need additional context to understand a finding. Keep the review focused on the changes, not the entire codebase.

### Line number accuracy

CRITICAL: When referencing line numbers in review comments, you MUST use the actual file line numbers, NOT the line numbers from the diff output or the tool's display. The diff output line numbers (from `git diff`) reflect the concatenated diff stream, not real file positions. The `@@` hunk headers in the diff (e.g., `@@ -10,5 +12,8 @@`) contain the real file line numbers - the `+` side shows the line number in the new version of the file. Use those numbers, or when in doubt, use the Grep tool to confirm the exact line number of the code you are commenting on. Getting line numbers wrong makes the review comments hard to use.

### 4. Output format

Output rendered markdown directly. Never use emdashes - use hyphens instead.

Structure your review as follows:

## MR Review: <current branch name>

**Base:** <base branch> | **Commits:** <count> | **Files changed:** <count>

### Reviewer Summary

<2-4 sentence overview: what the MR does, your overall impression, and whether it is ready to merge, needs minor fixes, or needs significant rework.>

### Review Comments

If there are no findings across any category, say "Looks good, no comments." and stop here.

Otherwise, number each finding and list it as:

---

**<N>.** **`filepath:line_number`** or **`filepath:start_line-end_line`** - *category*

Explain what you noticed, why it matters, and suggest a concrete fix or alternative. Use standard markdown formatting - code spans, code blocks, lists, etc.

---

...repeat for each finding...

Order the comments by severity, most important first. The user may respond by number to discuss or resolve individual findings.
