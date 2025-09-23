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
--  Project Setup Strategy                                                    --
--  ----------------------                                                    --
--                                                                            --
--  CodeCompanion uses two complementary context systems:                     --
--                                                                            --
--  MEMORY SYSTEM (Always Available)                                          --
--    Purpose: Essential project context loaded with every chat               --
--    Files: docs/{context,decisions,patterns}.md + global standards          --
--    When: Use for foundational project knowledge and coding standards       --
--    Setup: Files are optional - memory gracefully handles missing files     --
--                                                                            --
--  WORKSPACE SYSTEM (Feature-Specific)                                       --
--    Purpose: Deep-dive context for complex architectural discussions        --
--    Files: codecompanion-workspace.json (optional)                          --
--    When: Use for large codebases, team collaboration, token efficiency     --
--    Access: /workspace slash command in chat buffer                         --
--                                                                            --
--  Project Lifecycle:                                                        --
--    New Project:     Create docs/context.md, start simple                   --
--    Growing:         Add docs/patterns.md as conventions emerge             --
--    Complex:         Add docs/decisions.md, consider workspace file         --
--    Team/Large:      Definitely use workspace file for organized context    --
--                                                                            --
--  Essential Memory Files:                                                   --
--    docs/context.md    - Project overview, goals, architecture              --
--    docs/decisions.md  - Key architectural decisions (ADR-style)            --
--    docs/patterns.md   - Code conventions and patterns                      --
--                                                                            --
--    The above files use the claude parser which processes markdown files    --
--    to enhance context:                                                     --
--      - Converts file paths to clickable links: [file.py](./src/file.py)    --
--      - Makes references interactive for easy addition to chat              --
--      - Maintains markdown structure while enabling file navigation         --
--      - Works with: relative paths, absolute paths, and URLs                --
--      - Example: "See [main config](./lua/config/init.lua) for setup"       --
--      - Files referenced this way can be added as buffers with              --
--        default_params                                                      --
--                                                                            --
--  Memory loads: Global standards + project docs (if they exist)             --
--  Workspace loads: On-demand via /workspace command                         --
--                                                                            --
--  Snippets Available:                                                       --
--    con<tab>  - docs/context.md template                                    --
--    dec<tab>  - docs/decisions.md template                                  --
--    pat<tab>  - docs/patterns.md template                                   --
--    ws<tab>   - codecompanion-workspace.json template                       --
--                                                                            --
--  Quick Ref: (see lua/buell/codecompanion/[helpers|strategies].lua for all) --
--    gS              - Show copilot usage stats                              --
--    <localleader>T  - Toggle auto tool mode                                 --
--    gd              - Debug the chat buffer, show full chat history table   --
--    <leader>c       - CodeCompanion command prompt                          --
--    <leader>a       - CodeCompanion actions menu                            --
--    /workspace      - Load workspace context in chat buffer                 --
--    /memory         - Add memory groups to chat buffer                      --
--    ga              - accept an inline edit                                 --
--    gr              - reject an inline edit                                 --
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
--     <leader>4 - open an openai chat window                                 --
--  2. Insert context, call tools, etc (/,@,# + completion)                   --
--  3. Write prompt                                                           --
--  4. Send with <C-s>                                                        --
--                                                                            --
--  or                                                                        --
--                                                                            --
--  Send selection to chat window with <C-c>                                  --
--                                                                            --
--------------------------------------------------------------------------------

local has_codecompanion, codecompanion = pcall(require, 'codecompanion')
if not has_codecompanion then
  return
end

vim.defer_fn(function()

  -- Pull in helpers
  local helpers = require('buell.codecompanion.helpers')

  -- Assemble the configuration
  local config = {
    opts = {
      system_prompt = require('buell.codecompanion.system_prompt'),
    },
    prompt_library  = require('buell.codecompanion.prompt_library'),
    display         = require('buell.codecompanion.display'),
    adapters        = require('buell.codecompanion.adapters'),
    strategies      = require('buell.codecompanion.strategies'),
    memory          = require('buell.codecompanion.memory'),
    extensions      = require('buell.codecompanion.extensions'),
  }

  -- Load the configuration into CodeCompanion
  codecompanion.setup(config)

  -- Setup keymaps
  helpers.setup_keymaps()

  -- After codecompanion setup, run overrides
  helpers.mini_pick_action_menu()

  -- Resize the CodeCompanion window if needed
  local augroup = buell.util.augroup
  local autocmd = buell.util.autocmd

  augroup('BuellCodeCompanionResize', function()
    autocmd('BufWinEnter', '*', function()
      if vim.bo.filetype ~= 'codecompanion' then
        return
      end

      -- Debug info
      local win_count = vim.fn.winnr('$')
      local current_win = vim.api.nvim_get_current_win()
      local current_width = vim.api.nvim_win_get_width(current_win)
      local columns = vim.o.columns

      -- Only proceed if we have exactly 2 windows
      if win_count ~= 2 then
        return
      end

      -- If width suggests vertical split
      if current_width < (columns * 0.8) then
        -- Go to previous window and verify we switched
        vim.cmd('wincmd p')
        local prev_win = vim.api.nvim_get_current_win()

        -- Ensure we actually switched windows
        if prev_win == current_win then
          return
        end

        local prev_width = vim.api.nvim_win_get_width(prev_win)

        -- Resize to 80 characters if not already
        local target_width = 80 + buell.util.gutter_width() + 1
        local success, _ = pcall(function()
          if prev_width ~= target_width then
            vim.api.nvim_win_set_width(prev_win, target_width)
          end
        end)

        -- Return to codecompanion window
        if success then
          vim.api.nvim_set_current_win(current_win)
        end
      end
    end)
  end)

end, 100)
