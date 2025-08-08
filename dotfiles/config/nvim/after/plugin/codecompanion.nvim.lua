--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion                                                             --
--                                                                            --
--  https://codecompanion.olimorris.dev/                                      --
--  https://github.com/olimorris/codecompanion.nvim                           --
--                                                                            --
--  TBD/Todo                                                                  --
--  --------                                                                  --
--                                                                            --
--  - update adapter tokens function to return table and show ↑ ↓ and total   --
--  - fix bad calculations that show using more tokens than context window    --
--  - consider virtual input windows, github bits:                            --
--    folke/snacks.nvim/blob/main/docs/input.md                               --
--    lucobellic/nvim-config/blob/main/lua/plugins/snacks/snacks-input.lua    --
--  - add inline symbol column context indicator                              --
--    https://github.com/olimorris/codecompanion.nvim/discussions/1297        --
--                                                                            --
--  Reference                                                                 --
--  ---------                                                                 --
--                                                                            --
--  temperature: controls randomness in output, lower is more focused         --
--               higher is more creative, 0 <-> 1                             --
--  top_p:       limits the model to consider only the most probable tokens   --
--               whose cumulative probability is ≤ top_p, balances            --
--               randomness and coherence                                     --
--  n:           how many completions (responses) the model should            --
--               generate per prompt                                          --
--                                                                            --
--  Quick Keys:                                                               --
--    gS         - Show copilot usage stats                                   --
--    gta        - Toggle auto tool mode                                      --
--    gd         - Debug the chat buffer, show full chat history table        --
--    <leader>c  - CodeCompanion command prompt                               --
--    <leader>a  - CodeCompanion actions menu                                 --
--    <leader>dr - Review documentation                                       --
--    <leader>di - Capture insights                                           --
--    <leader>du - Update context docs                                        --
--    ga         - accept an inline edit                                      --
--    gr         - reject an inline edit                                      --
--                                                                            --
--  Inline Workflow                                                           --
--  ---------------                                                           --
--                                                                            --
--  1. Visual select some context (alternatively use #{buffer} in prompt)     --
--  2. <Leader>c [write out your prompt]                                      --
--                                                                            --
--  Chat Workflow                                                             --
--  -------------                                                             --
--                                                                            --
--  1. Open the chat window:                                                  --
--     <leader>1 - open the last used chat window else new copilot            --
--     <leader>2 - open a copilot chat window                                 --
--     <leader>3 - open an anthropic chat window                              --
--     <leader>3 - open an openai chat window                                 --
--  2. Insert context, call tools, etc (/,@,# + completion)                   --
--  3. Write prompt                                                           --
--  4. Send with <C-s>                                                        --
--                                                                            --
--  Living Documentation Workflow / Feedback Loop                             --
--  ---------------------------------------------                             --
--                                                                            --
--  TLDR Workflow:                                                            --
--    <leader>di (init_docs)      - Initialize living documentation workflow  --
--    <leader>dr (review_docs)    - Analyze code and suggest doc updates      --
--    <leader>de (expand_docs)    - Add "optional" docs as project grows      --
--    <leader>dc (capture)        - Document discoveries and decisions now    --
--    <leader>dg (gaps)           - Systematically detect documentation gaps  --
--    <leader>du (update_context) - Review and update project documentation   --
--    <leader>dw (/workspace)     - Load project context from workspace.json  --
--                                                                            --
--  The core innovation of this setup is creating a self-reinforcing cycle    --
--  where documentation continuously improves AI interactions, which in turn  --
--  generates better documentation. This creates compound intelligence over   --
--  time rather than starting from zero in each session.                      --
--                                                                            --
--  ┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌─────────────┐ --
--  │   CREATE    │───▶│   APPROVE    │───▶│   UPDATE    │───▶│  CONTEXT    │ --
--  │             │    │              │    │             │    │             │ --
--  │ AI analyzes │    │ Human reviews│    │ AI updates  │    │ Updated docs│ --
--  │ codebase vs │    │ suggestions  │    │ approved    │    │ feed back   │ --
--  │ current docs│    │ and selects  │    │ items using │    │ into future │ --
--  │ using tools │    │ what to      │    │ file editing│    │ AI sessions │ --
--  │ and prompts │    │ implement    │    │ tools       │    │ as context  │ --
--  └─────────────┘    └──────────────┘    └─────────────┘    └─────────────┘ --
--        │                                                          │        --
--        └──────────────────────────────────────────────────────────┘        --
--                            Cycle Repeats                                   --
--                                                                            --
--  CREATE PHASE (Enhanced):                                                  --
--    - init_docs: Bootstrap documentation structure for new projects         --
--    - review_docs: Comprehensive analysis using @file_search/@grep_search   --
--    - expand_docs: Add optional docs based on project complexity            --
--    - gaps: Systematic identification and prioritization of missing docs    --
--    - capture: Ad-hoc documentation of discoveries and insights             --
--    - All prompts present recommendations in checkbox format                --
--                                                                            --
--  APPROVE PHASE:                                                            --
--    - Human reviews AI suggestions before any changes                       --
--    - User can approve specific items: "Please implement items 1, 3, 5"     --
--    - User can request modifications: "Change X but hold off on Y"          --
--    - No documentation changes without explicit approval                    --
--                                                                            --
--  UPDATE PHASE:                                                             --
--    - AI uses @create_file for new documentation                            --
--    - AI uses @insert_edit_into_file for updates to existing files          --
--    - Changes follow established patterns and formats                       --
--    - AI explains what was changed and why                                  --
--                                                                            --
--  CONTEXT PHASE:                                                            --
--    - /workspace automatically loads documentation as context               --
--    - codecompanion-workspace.json defines project-specific context         --
--    - AI references documented decisions in future recommendations          --
--    - Each session builds on previous documented knowledge                  --
--                                                                            --
--  Project Lifecycle Support:                                                --
--    New Project:     init_docs → workspace setup → regular review cycle     --
--    Growing Project: expand_docs → add optional documentation               --
--    Mature Project:  review_docs → gaps → capture insights → update cycle   --
--                                                                            --
--  Evolution Timeline:                                                       --
--    Week 1:  Basic context, generic AI responses                            --
--    Month 1: AI references your documented patterns and decisions           --
--    Month 3: AI acts like experienced team member with full project         --
--             context, catches inconsistencies, suggests aligned solutions   --
--    Month 6: AI proactively suggests improvements based on documented       --
--             patterns and helps onboard new team members                    --
--                                                                            --
--  Key Benefits:                                                             --
--    - Persistent knowledge across sessions (no more "starting from zero")   --
--    - Project-specific guidance aligned with your established patterns      --
--    - Compound intelligence - each interaction makes the next one better    --
--    - Human oversight ensures quality and prevents documentation drift      --
--    - Living documentation stays current with actual codebase               --
--    - Safe initialization that won't overwrite existing documentation       --
--                                                                            --
--  Files Created by This Setup:                                              --
--    Essential (always):                                                     --
--      codecompanion-workspace.json - Project context and data sources       --
--      doc/decisions.md             - Decision log (ADR-style)               --
--      doc/project-context.md       - High-level goals and architecture      --
--      doc/tech-context.md          - Tech stack and patterns                --
--    Optional (as needed):                                                   --
--      doc/code-standards.md        - Coding conventions                     --
--      doc/deployment.md            - Deployment procedures                  --
--      doc/onboarding.md            - New developer guide                    --
--      doc/testing.md               - Testing strategies and patterns        --
--      doc/troubleshooting.md       - Common issues and solutions            --
--                                                                            --
--  Keymaps:                                                                  --
--    <leader>di - Initialize living docs (safe, won't overwrite)             --
--    <leader>dr - Review documentation (comprehensive analysis)              --
--    <leader>de - Expand documentation (add optional files)                  --
--    <leader>dc - Capture insights/decisions (immediate documentation)       --
--    <leader>dg - Detect documentation gaps (systematic analysis)            --
--    <leader>du - Update context docs (high-level updates)                   --
--    <leader>dw - Load workspace context (quick context loading)             --
--                                                                            --
--  Required minimum codecompanion-workspace.json file:                       --
--    see dotfiles/config/nvim/snippets/snipmate/all.snippets -> ws           --
--                                                                            --
--------------------------------------------------------------------------------

local has_codecompanion, codecompanion = pcall(require, 'codecompanion')
if not has_codecompanion then
  return
end

-- Load modular configuration
local config_modules = {
  system_prompt  = require('buell.codecompanion.system_prompt'),
  prompt_library = require('buell.codecompanion.prompt_library'),
  display        = require('buell.codecompanion.display'),
  adapters       = require('buell.codecompanion.adapters'),
  strategies     = require('buell.codecompanion.strategies'),
  extensions     = require('buell.codecompanion.extensions'),
  helpers        = require('buell.codecompanion.helpers'),
}

vim.defer_fn(function()

  -- Assemble the configuration
  local config = {
    opts = {
      system_prompt = config_modules.system_prompt,
    },
    prompt_library  = config_modules.prompt_library,
    display         = config_modules.display,
    adapters        = config_modules.adapters,
    strategies      = config_modules.strategies,
    extensions      = config_modules.extensions,
  }

  -- Load the configuration into CodeCompanion
  codecompanion.setup(config)

  -- Setup keymaps
  config_modules.helpers.setup_keymaps()

  -- After codecompanion setup, run overrides
  config_modules.helpers.mini_pick_action_menu()

end, 100)
