--------------------------------------------------------------------------------
--                                                                            --
--  CodeCompanion Helpers and Utilities                                       --
--                                                                            --
--  This module contains utility functions and keymap configurations that    --
--  support the CodeCompanion workflow. It includes:                         --
--    - Smart chat functions: Context-preserving chat interactions           --
--    - Keymap setup: All CodeCompanion-related key bindings                 --
--    - Bug fixes: Workarounds for known issues                              --
--    - Documentation workflow shortcuts: Quick access to common tasks       --
--                                                                            --
--------------------------------------------------------------------------------

local M = {}

---------------
--  Helpers  --
---------------

-- Smart Chat Add
--
-- Prevent double code entries when calling CodeCompanionChat Add.
local function smart_chat_add()
  local mode = vim.api.nvim_get_mode().mode
  local chat = require('codecompanion.strategies.chat')
  local cmd = ''

  if mode == 'n' then
    cmd = 'V'
  end

  if chat and chat.last_chat and chat.last_chat() then
    return cmd .. '<CMD>CodeCompanionChat Add<CR>'
  else
    return cmd .. '<CMD>CodeCompanionChat<CR><CR><CR>'
  end
end

-- Setup Keymaps
--
-- Configures all keymaps related to CodeCompanion functionality.
function M.setup_keymaps()
  -- Alias cc to CodeCompanion
  vim.cmd([[cab cc CodeCompanion]])

  -- Mapping to close without killing the session (gq) in plugin/autocommand.lua
  -- Other maps are in normal.lua, eg <Leader>[1-4] to init chat interfaces

  -- Core mappings
  vim.keymap.set({'n', 'v'}, '<C-c>', smart_chat_add, { noremap = true, silent = true, expr = true })
  vim.keymap.set({'n', 'v'}, '<Leader>c', ':CodeCompanion ', { noremap = true, silent = false })
  vim.keymap.set({'n', 'v'}, '<Leader>a', '<CMD>CodeCompanionActions<CR>', { noremap = true, silent = true })

  -- Documentation workflow mappings
  vim.keymap.set('n', '<leader>dr', '<cmd>CodeCompanion review_docs<cr>', { desc = "Review documentation" })
  vim.keymap.set('n', '<leader>di', '<cmd>CodeCompanion capture_insight<cr>', { desc = "Capture insights" })
  vim.keymap.set('n', '<leader>du', '<cmd>CodeCompanion update_context<cr>', { desc = "Update context docs" })
  vim.keymap.set('n', '<leader>dw', '<cmd>CodeCompanionChat<cr>/workspace<cr>', { desc = "Load workspace context" })

  -- Enhanced send key, overload send key to go back to normal mode then submit
  vim.keymap.set({'i', 'n', 'v'}, '<C-s>', function()
    vim.cmd('stopinsert')
    vim.schedule(function()
      local chat = require('codecompanion.strategies.chat')
      if chat and chat.last_chat then
        chat.last_chat():submit()
      end
    end)
  end, { noremap = true, silent = true })
end

-- Apply Fixes
--
-- Applies any necessary fixes or workarounds for known issues.
function M.apply_fixes()
  -- start temp fix for E350 folding error in v17.7.1
  -- https://github.com/olimorris/codecompanion.nvim/discussions/1788
  local tools = require("codecompanion.strategies.chat.ui.tools")
  local original = tools.create_fold

  tools.create_fold = function(bufnr, start_line)
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_call(win, function()
      local old = vim.wo.foldmethod
      vim.wo.foldmethod = "manual"

      local ok, err = pcall(original, bufnr, start_line)
      if not ok then
        vim.schedule(function()
          vim.wo.foldmethod = old
        end)
        error(err)
      end

      vim.defer_fn(function()
        if vim.api.nvim_win_is_valid(win) then
          vim.wo.foldmethod = old
        end
      end, 50)
    end)
  end
  -- end of temp fix
end

return M
