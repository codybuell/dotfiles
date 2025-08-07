--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Prompt Library                                              --
--                                                                            --
--  This module defines custom prompts and workflows that extend              --
--  CodeCompanion's capabilities beyond the default set. Prompts can be       --
--  simple templates, multi-step workflows, or complex interactive            --
--  sessions with specific context and behavior.                              --
--                                                                            --
--  Prompt Types:                                                             --
--    - Chat: Interactive conversations with context loading                  --
--    - Workflow: Multi-step processes with user approval gates               --
--    - Inline: Direct code modification prompts                              --
--                                                                            --
--  Access via:                                                               --
--    - :CodeCompanion <short_name>                                           --
--    - <leader>a (action palette)                                            --
--    - Custom keymaps defined in helpers.lua                                 --
--                                                                            --
--------------------------------------------------------------------------------

local M = {}

----------------------------
--  Review Documentation  --
----------------------------

--------------------------------------------------------------------------------
--                                                                            --
--  Review Documentation                                                       --
--                                                                            --
--  The primary workflow prompt for maintaining living documentation.         --
--  This implements the "CREATE" step of the documentation feedback loop      --
--  by analyzing the current codebase against existing documentation and      --
--  suggesting specific, actionable updates.                                  --
--                                                                            --
--  Workflow:                                                                 --
--    1. Loads existing documentation files as context                        --
--    2. Analyzes code for gaps, outdated info, missing decisions             --
--    3. Presents recommendations in checkbox format for user approval        --
--    4. Updates approved items using file editing tools                      --
--                                                                            --
--  Triggered by: <leader>dr or :CodeCompanion review_docs                    --
--  Expected frequency: Weekly or after significant code changes              --
--                                                                            --
--------------------------------------------------------------------------------

M["Review Documentation"] = {
  strategy = "chat",
  description = "Analyze codebase and suggest documentation updates",
  opts = {
    short_name = "review_docs",
    auto_submit = false,
  },
  context = {
    {
      type = "file",
      path = "codecompanion-workspace.json",
      optional = true
    },
    {
      type = "file",
      path = "doc/project-context.md",
      optional = true
    },
    {
      type = "file",
      path = "doc/decisions.md",
      optional = true
    },
    {
      type = "file",
      path = "doc/tech-context.md",
      optional = true
    }
  },
  prompts = {
    {
      role = "system",
      content = [[You are a documentation reviewer. Your job is to:

1. **ANALYZE**: Compare current documentation with codebase
2. **RECOMMEND**: Present specific, actionable updates in checkbox format
3. **WAIT**: Always get user approval before making changes
4. **IMPLEMENT**: Only update items the user approves

Focus on:
- Missing architectural decisions that should be documented
- Outdated technical information
- New patterns or conventions that emerged
- Gaps between code and documentation

Present recommendations as checkboxes so the user can approve specific items.]]
    },
    {
      role = "user",
      content = [[Please analyze the current documentation against the codebase and recommend updates.

Use the @{files} tool to examine recent changes and @{grep_search} to identify patterns.

Present your findings as:

## Documentation Recommendations

### Missing Documentation
- [ ] **Topic/File**: Specific recommendation and rationale

### Outdated Information
- [ ] **Section**: What needs updating and why

### Decision Gaps
- [ ] **Decision**: What should be captured in decisions.md

### Pattern Documentation
- [ ] **Pattern**: What coding patterns need documentation

After I approve items, you can implement them using @{edit_file}.]]
    }
  }
}

--------------------------------------------------------------------------------
--                                                                            --
--  Capture Insights                                                          --
--                                                                            --
--  Ad-hoc workflow for documenting discoveries and insights as they occur.   --
--  This prompt helps capture the "why" behind solutions, creating a living   --
--  record of technical decisions and learnings that feed back into future    --
--  AI interactions.                                                          --
--                                                                            --
--  Use Cases:                                                                --
--    - "I figured out why X was failing" → Document the root cause          --
--    - "We should use Y because..." → Record the decision rationale          --
--    - "I discovered that Z works better" → Capture the insight              --
--                                                                            --
--  Workflow:                                                                 --
--    1. User shares insight or discovery                                     --
--    2. AI drafts structured entry for decisions.md                          --
--    3. User approves or refines the entry                                   --
--    4. Documentation is updated with the new knowledge                      --
--                                                                            --
--  Triggered by: <leader>di or :CodeCompanion capture_insight               --
--  Expected frequency: As-needed when insights occur                         --
--                                                                            --
--------------------------------------------------------------------------------

M["Capture Insights"] = {
  strategy = "chat",
  description = "Document discoveries and add to decisions log",
  opts = {
    short_name = "capture_insight",
    auto_submit = false,
  },
  context = {
    {
      type = "file",
      path = "doc/decisions.md"
    }
  },
  prompts = {
    {
      role = "system",
      content = [[You help capture insights and decisions. When the user shares:
- "I figured out why..."
- "The issue was..."
- "We should use X because..."
- "I discovered that..."

Draft an addition to the decisions log using this format:

### [DATE] - [DECISION TITLE]
**Context**: Why this decision was needed
**Decision**: What was decided
**Rationale**: Why this approach was chosen
**Consequences**: Expected outcomes, trade-offs
**Status**: Accepted
**Tags**: #relevant #tags

Always ask for approval before updating the file.]]
    },
    {
      role = "user",
      content = "I just figured out [describe your insight]. Should this be documented? If so, please draft an entry for the decisions log."
    }
  }
}

--------------------------------------------------------------------------------
--                                                                            --
--  Update Project Context                                                    --
--                                                                            --
--  Comprehensive review workflow for high-level project documentation.       --
--  This prompt focuses on strategic documentation - project goals,           --
--  architecture decisions, and technology stack evolution rather than        --
--  detailed code-level documentation.                                        --
--                                                                            --
--  Scope:                                                                    --
--    - Project vision and constraints (project-context.md)                  --
--    - Technology stack and patterns (tech-context.md)                      --
--    - Dependencies and version considerations                               --
--                                                                            --
--  Workflow:                                                                 --
--    1. Reviews current project documentation against codebase state         --
--    2. Identifies outdated tech info, missing patterns, new requirements    --
--    3. Suggests updates to maintain alignment with project evolution        --
--    4. Updates approved documentation sections                              --
--                                                                            --
--  Triggered by: <leader>du or :CodeCompanion update_context                --
--  Expected frequency: Monthly or after major architectural changes          --
--                                                                            --
--------------------------------------------------------------------------------

M["Update Project Context"] = {
  strategy = "chat",
  description = "Review and update all project documentation",
  opts = {
    short_name = "update_context",
    auto_submit = false,
  },
  context = {
    {
      type = "file",
      path = "doc/project-context.md"
    },
    {
      type = "file",
      path = "doc/tech-context.md"
    },
    {
      type = "file",
      path = "package.json",
      optional = true
    }
  },
  prompts = {
    {
      role = "system",
      content = [[You help maintain project documentation. Review the current docs and suggest specific updates based on:

1. Changes in dependencies or tech stack
2. Evolution of architecture or patterns
3. New requirements or constraints
4. Outdated information

Present recommendations in checkbox format and wait for approval before making changes.]]
    },
    {
      role = "user",
      content = "Please review the project documentation and suggest updates based on the current state of the codebase."
    }
  }
}

return M
