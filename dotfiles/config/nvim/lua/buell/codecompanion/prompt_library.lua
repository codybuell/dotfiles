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

--------------------------------------------------------------------------------
--                                                                            --
--  Initialize Living Documentation                                           --
--                                                                            --
--  The foundational workflow prompt that bootstraps the living               --
--  documentation system for new or existing projects. This sets up the       --
--  essential documentation infrastructure and workspace configuration        --
--  needed for the complete living documentation feedback loop.               --
--                                                                            --
--  Workflow:                                                                 --
--    1. Scans project structure using file search tools                      --
--    2. Identifies missing essential documentation files                     --
--    3. Creates missing files using appropriate templates                    --
--    4. Sets up codecompanion-workspace.json with project-specific config    --
--    5. Customizes templates based on detected project technologies          --
--    6. Preserves any existing documentation (safe, non-destructive)         --
--                                                                            --
--  Safety: Only creates missing files - never overwrites existing docs       --
--                                                                            --
--  Triggered by: <leader>di or :CodeCompanion init_docs                      --
--  Expected frequency: Once per project (setup phase)                        --
--                                                                            --
--------------------------------------------------------------------------------

M["Initialize Living Docs"] = {
  strategy = "chat",
  description = "Initialize living documentation workflow for a new project",
  opts = {
    short_name = "init_docs",
    auto_submit = false,
  },
  prompts = {
    {
      role = "system",
      content = [[You help initialize the living documentation workflow for projects. Your tasks:

1. **ASSESS**: Check what documentation already exists using @{file_search}
2. **CREATE**: Create missing essential documentation files with appropriate templates using @{create_file}
3. **SETUP**: Create or update the codecompanion-workspace.json file

IMPORTANT: Only create files that don't already exist. Never overwrite existing documentation.

Essential files for living documentation:
- doc/project-context.md (project overview and goals)
- doc/decisions.md (architectural decision records)
- doc/tech-context.md (technology choices and patterns)
- codecompanion-workspace.json (AI context configuration)

Use the @{create_file} tool to create missing files with appropriate templates.]]
    },
    {
      role = "user",
      content = [[Please initialize the living documentation workflow for this project.

First, use @{file_search} to check what documentation already exists. Only create files that are missing - never overwrite existing documentation.

For doc/project-context.md, use this template:
```markdown
# [Project Name]

## Overview
Brief description of what this project does and why it exists.

## Goals & Objectives
- Primary objective 1
- Primary objective 2

## Constraints
- Technical constraints
- Business constraints

## Architecture Overview
High-level system design and key components.

## Key Technologies
- Technology 1: Rationale
- Technology 2: Rationale

## Related Documentation
- [Decisions](./decisions.md)
- [Tech Context](./tech-context.md)
```

For doc/decisions.md, use this template:
```markdown
# Architectural Decision Records

## Decision Template
When adding new decisions, use this format:

### [YYYY-MM-DD] - [Decision Title]
**Status:** Proposed | Accepted | Rejected | Superseded
**Context:** Why this decision was needed
**Decision:** What was decided
**Consequences:** Expected outcomes and trade-offs
**Tags:** #relevant #tags

## Decisions

### [Current Date] - Adopt Living Documentation Workflow
**Status:** Accepted
**Context:** Need systematic approach to keep documentation current with code changes
**Decision:** Implement living documentation workflow with AI assistance via CodeCompanion
**Consequences:**
- Better knowledge retention across team
- Easier onboarding for new developers
- Documentation stays aligned with codebase evolution
- Regular review cycles ensure accuracy
**Tags:** #documentation #workflow #ai-assisted
```

For doc/tech-context.md, use this template:
```markdown
# Technology Context

## Technology Stack
Document key technologies and rationale:
- **Language:** [Primary language and version]
- **Framework:** [Main framework if applicable]
- **Database:** [Database technology]
- **Deployment:** [Deployment approach]

## Architecture Patterns
Document key patterns as they emerge:
- Pattern 1: Description and usage
- Pattern 2: Description and usage

## Conventions
### Naming Conventions
- Files: [convention]
- Functions: [convention]
- Variables: [convention]

### Code Organization
Describe how code is structured and organized.

## Key Dependencies
Major dependencies and selection rationale:
- **Dependency 1:** Why chosen, alternatives considered
- **Dependency 2:** Why chosen, alternatives considered

## Development Setup
Basic setup requirements and configuration.
```

For codecompanion-workspace.json, create a minimal configuration:
```json
{
  "name": "[Detected Project Name]",
  "version": "1.0.0",
  "system_prompt": "This project follows a living documentation workflow. Always consult the ${docs_path}/ folder for project context, decisions, and patterns before providing advice.",
  "vars": {
    "docs_path": "doc"
  },
  "groups": [
    {
      "name": "Core Architecture",
      "system_prompt": "Essential project understanding - review before architectural changes",
      "data": ["project-overview", "decisions", "tech-stack"]
    }
  ],
  "data": {
    "project-overview": {
      "type": "file",
      "path": "${docs_path}/project-context.md",
      "description": "High-level project goals and architecture"
    },
    "decisions": {
      "type": "file",
      "path": "${docs_path}/decisions.md",
      "description": "Technical decisions and rationale"
    },
    "tech-stack": {
      "type": "file",
      "path": "${docs_path}/tech-context.md",
      "description": "Technology stack and patterns"
    }
  }
}
```

Customize the templates based on what you discover about the project structure and technologies used.]]
    }
  }
}

--------------------------------------------------------------------------------
--                                                                            --
--  Review Documentation                                                      --
--                                                                            --
--  A core workflow prompt for maintaining living documentation.              --
--  This implements the "CREATE" step of the documentation feedback loop      --
--  by analyzing the current codebase against existing documentation and      --
--  suggesting specific, actionable updates.                                  --
--                                                                            --
--  Workflow:                                                                 --
--    1. Checks for missing essential documentation files                     --
--    2. Creates missing files using templates if needed                      --
--    3. Loads existing documentation files as context                        --
--    4. Analyzes code for gaps, outdated info, missing decisions             --
--    5. Presents recommendations in checkbox format for user approval        --
--    6. Updates approved items using file creation/editing tools             --
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

1. **CHECK**: Verify essential documentation files exist
2. **ANALYZE**: Compare current documentation with codebase
3. **RECOMMEND**: Present specific, actionable updates in checkbox format
4. **CREATE**: Use @{create_file} for missing essential files
5. **WAIT**: Always get user approval before making changes
6. **IMPLEMENT**: Only update items the user approves

If essential documentation files don't exist, create them first using the templates from the "Initialize Living Docs" prompt.

Focus on:
- Missing architectural decisions that should be documented
- Outdated technical information
- New patterns or conventions that emerged
- Gaps between code and documentation]]
    },
    {
      role = "user",
      content = [[Please review the documentation for this project.

First, use @{file_search} to check what documentation exists. If essential files (project-context.md, decisions.md, tech-context.md, codecompanion-workspace.json) are missing, create them using @{create_file} with appropriate templates.

Then analyze existing documentation against the codebase using @{file_search} and @{grep_search} tools.

Present findings as:

## Documentation Review

### Missing Essential Files
- [ ] **File**: Why it's needed

### Documentation Recommendations

### Missing Documentation
- [ ] **Topic/File**: Specific recommendation and rationale

### Outdated Information
- [ ] **Section**: What needs updating and why

### Decision Gaps
- [ ] **Decision**: What should be captured in decisions.md

### Pattern Documentation
- [ ] **Pattern**: What coding patterns need documentation

After I approve items, implement them using @{create_file} or @{insert_edit_into_file}.]]
    }
  }
}

--------------------------------------------------------------------------------
--                                                                            --
--  Expand Living Documentation                                               --
--                                                                            --
--  A growth-phase workflow prompt that adds optional documentation files     --
--  as projects mature in complexity. This bridges the gap between the        --
--  minimal essential documentation and comprehensive project documentation   --
--  by intelligently recommending additional files based on project needs.    --
--                                                                            --
--  Workflow:                                                                 --
--    1. Analyzes project complexity and structure using search tools         --
--    2. Assesses team size indicators and development patterns               --
--    3. Evaluates testing, deployment, and code complexity                   --
--    4. Recommends optional documentation files in priority order            --
--    5. Creates approved files using comprehensive templates                 --
--    6. Updates workspace.json with new documentation groups if needed       --
--                                                                            --
--  Focus: Optional docs (onboarding, testing, troubleshooting, etc.)         --
--                                                                            --
--  Triggered by: <leader>de or :CodeCompanion expand_docs                    --
--  Expected frequency: As project complexity grows (monthly/quarterly)       --
--                                                                            --
--------------------------------------------------------------------------------

M["Expand Living Docs"] = {
  strategy = "chat",
  description = "Add optional documentation files as project grows",
  opts = {
    short_name = "expand_docs",
    auto_submit = false,
  },
  context = {
    {
      type = "file",
      path = "codecompanion-workspace.json",
      optional = true
    }
  },
  prompts = {
    {
      role = "system",
      content = [[You help projects expand their documentation as they mature. You assess project complexity and team size to recommend additional documentation files.

Optional documentation files to consider:
- doc/onboarding.md (for teams > 2 people)
- doc/testing.md (for complex testing strategies)
- doc/troubleshooting.md (after accumulating common issues)
- doc/code-standards.md (for teams with specific conventions)
- doc/deployment.md (for complex deployment processes)

Use @{create_file} to create recommended files with appropriate templates.]]
    },
    {
      role = "user",
      content = [[Analyze this project to determine if additional documentation would be beneficial. Use @{file_search} and @{grep_search} to understand project complexity.

Consider:
- Team size indicators (multiple contributors, etc.)
- Testing complexity
- Deployment complexity
- Code standards/conventions in use
- Common issues that might need documentation

Present recommendations as:

## Documentation Expansion Analysis

### Recommended Additions
- [ ] **File**: Why it would help this project

### Templates Available
List which templates you can create for approved files.

For doc/onboarding.md template:
```markdown
# Developer Onboarding

## Prerequisites
- Requirement 1
- Requirement 2

## Setup Steps
1. Step 1
2. Step 2

## Project Structure
Overview of how code is organized.

## Development Workflow
How to make changes, test, and deploy.

## Key Concepts
Important concepts new developers should understand.

## Common Tasks
- Task 1: How to do it
- Task 2: How to do it

## Getting Help
Where to ask questions and find resources.
```

Use similar comprehensive templates for other documentation types.]]
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
--    - "I figured out why X was failing" → Document the root cause           --
--    - "We should use Y because..." → Record the decision rationale          --
--    - "I discovered that Z works better" → Capture the insight              --
--                                                                            --
--  Workflow:                                                                 --
--    1. Checks if decisions.md exists (creates with template if missing)     --
--    2. User shares insight or discovery                                     --
--    3. AI drafts structured ADR entry for decisions.md                      --
--    4. User approves or refines the entry                                   --
--    5. Documentation is updated using file editing tools                    --
--                                                                            --
--  Triggered by: <leader>dc or :CodeCompanion capture                        --
--  Expected frequency: As-needed when insights occur                         --
--                                                                            --
--------------------------------------------------------------------------------

M["Capture Insights"] = {
  strategy = "chat",
  description = "Immediately document discoveries and decisions",
  opts = {
    short_name = "capture",
    auto_submit = false,
  },
  context = {
    {
      type = "file",
      path = "doc/decisions.md",
      optional = true
    }
  },
  prompts = {
    {
      role = "system",
      content = [[You help capture immediate insights and decisions as they occur during development. When a developer shares:
- "I figured out why..."
- "The issue was..."
- "We should use X because..."
- "I discovered that..."

Your job is to:
1. **CHECK**: Verify doc/decisions.md exists (create if missing using standard template)
2. **FORMAT**: Draft a properly structured ADR entry
3. **WAIT**: Get approval before updating the file
4. **UPDATE**: Add the entry to decisions.md using @{insert_edit_into_file}

ADR Format:
### [DATE] - [DECISION TITLE]
**Status:** Accepted
**Context:** Why this decision/discovery was needed
**Decision:** What was decided/discovered
**Consequences:** Expected outcomes, trade-offs, implications
**Tags:** #relevant #tags]]
    },
    {
      role = "user",
      content = "I just discovered/decided: [describe your insight]. Please help me document this properly in our decisions log."
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
--    - Project vision and constraints (project-context.md)                   --
--    - Technology stack and patterns (tech-context.md)                       --
--    - Dependencies and version considerations                               --
--                                                                            --
--  Workflow:                                                                 --
--    1. Loads existing high-level project documentation as context           --
--    2. Reviews current documentation against codebase state                 --
--    3. Identifies outdated tech info, missing patterns, new requirements    --
--    4. Suggests updates to maintain alignment with project evolution        --
--    5. Updates approved documentation sections using editing tools          --
--                                                                            --
--  Triggered by: <leader>du or :CodeCompanion update_context                 --
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

--------------------------------------------------------------------------------
--                                                                            --
--  Detect Documentation Gaps                                                 --
--                                                                            --
--  Systematic analysis workflow that proactively identifies missing or       --
--  outdated documentation across the project. This prompt performs a         --
--  comprehensive gap analysis, comparing project structure and codebase      --
--  evolution against existing documentation to prioritize improvement areas. --
--                                                                            --
--  Focus Areas:                                                              --
--    - New code patterns that lack documentation                             --
--    - Files/modules without corresponding documentation                     --
--    - Outdated information based on recent changes                          --
--    - Missing rationale for architectural choices                           --
--                                                                            --
--  Workflow:                                                                 --
--    1. Scans project structure using file search tools                      --
--    2. Analyzes codebase patterns using grep search tools                   --
--    3. Compares findings against existing documentation                     --
--    4. Prioritizes gaps by impact on developer productivity                 --
--    5. Presents recommendations in tiered priority format                   --
--    6. Suggests specific documentation structure and content                --
--                                                                            --
--  Triggered by: <leader>dg or :CodeCompanion gaps                           --
--  Expected frequency: Monthly or when feeling "documentation debt"          --
--                                                                            --
--------------------------------------------------------------------------------

M["Detect Documentation Gaps"] = {
  strategy = "chat",
  description = "Identify areas where documentation may be missing or outdated",
  opts = {
    short_name = "gaps",
    auto_submit = false,
  },
  context = {
    {
      type = "file",
      path = "codecompanion-workspace.json",
      optional = true
    }
  },
  prompts = {
    {
      role = "system",
      content = [[You are a documentation analyst. Your job is to:

1. **ANALYZE**: Compare project structure with documented areas
2. **IDENTIFY**: Find gaps where documentation is missing or likely outdated
3. **PRIORITIZE**: Rank gaps by impact on developer productivity
4. **RECOMMEND**: Suggest specific documentation additions

Focus on:
- New code patterns that aren't documented
- Files/modules without corresponding documentation
- Outdated information based on recent changes
- Missing decision rationale for architectural choices]]
    },
    {
      role = "user",
      content = [[Please analyze this project for documentation gaps. Use @{file_search} and @{grep_search} tools to understand the current codebase structure.

Present findings as:

## Documentation Gap Analysis

### Critical Gaps (High Impact)
- [ ] **Area**: Specific gap and why it's critical

### Important Gaps (Medium Impact)
- [ ] **Area**: Gap description and suggested documentation

### Nice-to-Have (Low Impact)
- [ ] **Area**: Documentation that would improve but isn't critical

After I approve items, suggest specific documentation structure and content.]]
    }
  }
}

--------------------------------------------------------------------------------
--                                                                            --
--  Pattern Documentation                                                     --
--                                                                            --
--  Code pattern analysis workflow that identifies and documents recurring    --
--  architectural approaches, conventions, and implementation patterns        --
--  across the codebase. This prompt helps establish consistency guidelines   --
--  and improves developer onboarding by capturing implicit knowledge.        --
--                                                                            --
--  Pattern Types:                                                            --
--    - Architectural patterns and design approaches                          --
--    - Naming conventions and code organization                              --
--    - Error handling and data flow patterns                                 --
--    - Testing strategies and configuration patterns                         --
--                                                                            --
--  Workflow:                                                                 --
--    1. Scans codebase for recurring structures using search tools           --
--    2. Identifies repeated approaches and implementation patterns           --
--    3. Analyzes naming conventions and organizational strategies            --
--    4. Documents patterns with descriptions and usage guidelines            --
--    5. Presents findings in structured format for approval                  --
--    6. Updates appropriate documentation files with pattern guides          --
--                                                                            --
--  Triggered by: :CodeCompanion patterns (no keymap assigned yet)            --
--  Expected frequency: When patterns emerge or for consistency reviews       --
--                                                                            --
--------------------------------------------------------------------------------

M["Pattern Documentation"] = {
  strategy = "chat",
  description = "Document emerging code patterns and conventions",
  opts = {
    short_name = "patterns",
    auto_submit = false,
  },
  prompts = {
    {
      role = "system",
      content = [[You are a code pattern analyst. Identify recurring patterns, conventions, and architectural approaches in the codebase that should be documented for consistency and onboarding.

Look for:
- Repeated code structures or approaches
- Naming conventions
- Error handling patterns
- Data flow patterns
- Testing patterns
- Configuration patterns]]
    },
    {
      role = "user",
      content = [[Please analyze the codebase for patterns that should be documented. Use @{grep_search} and @{file_search} tools to identify recurring approaches.

Document findings as:

## Code Pattern Analysis

### Architectural Patterns
- [ ] **Pattern Name**: Description and when to use

### Coding Conventions
- [ ] **Convention**: Specific rule and examples

### Common Approaches
- [ ] **Approach**: How this pattern is implemented across the codebase

After approval, I'll ask you to add these to the appropriate documentation files.]]
    }
  }
}

--------------------------------------------------------------------------------
--                                                                            --
--  Onboarding Guide                                                          --
--                                                                            --
--  Developer onboarding workflow that creates comprehensive guides for       --
--  new team members. This prompt analyzes project structure, setup           --
--  requirements, and development workflows to produce practical onboarding   --
--  documentation that reduces time-to-productivity for new developers.       --
--                                                                            --
--  Coverage Areas:                                                           --
--    - Prerequisites and development environment setup                       --
--    - Project structure and architectural overview                          --
--    - Development workflow and common development tasks                     --
--    - Key concepts, patterns, and team conventions                          --
--    - Testing approaches and quality standards                              --
--    - Where to find help and additional resources                           --
--                                                                            --
--  Workflow:                                                                 --
--    1. Analyzes project structure using file search tools                   --
--    2. Identifies setup requirements and dependencies                       --
--    3. Maps development workflow and common tasks                           --
--    4. Documents key concepts and architectural patterns                    --
--    5. Creates structured onboarding guide with practical steps             --
--    6. Updates or creates doc/onboarding.md with comprehensive content      --
--                                                                            --
--  Triggered by: :CodeCompanion onboard (no keymap assigned yet)             --
--  Expected frequency: When team grows or onboarding process needs refresh   --
--                                                                            --
--------------------------------------------------------------------------------
---
M["Onboarding Guide"] = {
  strategy = "chat",
  description = "Create or update developer onboarding documentation",
  opts = {
    short_name = "onboard",
    auto_submit = false,
  },
  context = {
    {
      type = "file",
      path = "README.md",
      optional = true
    },
    {
      type = "file",
      path = "doc/onboarding.md",
      optional = true
    }
  },
  prompts = {
    {
      role = "system",
      content = [[You create comprehensive onboarding guides that help new developers become productive quickly. Focus on practical steps, common pitfalls, and essential knowledge.]]
    },
    {
      role = "user",
      content = [[Create an onboarding guide for new developers on this project. Use @{file_search} to understand the project structure and @{grep_search} to identify setup requirements.

Include:
- Prerequisites and setup steps
- Project structure overview
- Development workflow
- Key concepts and patterns
- Common tasks and how to accomplish them
- Testing approach
- Where to find help

Present as a structured onboarding document ready for doc/onboarding.md]]
    }
  }
}

return M
