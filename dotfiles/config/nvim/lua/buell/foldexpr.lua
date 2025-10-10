--------------------------------------------------------------------------------
--                                                                            --
-- Custom fold expression for Neovim.                                         --
--                                                                            --
-- This file defines a folding strategy that combines marker-based and        --
-- indent-based folding. By default, it uses the custom foldexpr below,       --
-- but you can map specific filetypes to alternative foldexpr functions       --
-- using the `filetype_foldexprs` table.                                      --
--                                                                            --
-- Marker-based folding:                                                      --
--   You can manually control folds in any file using special markers:        --
--                                                                            --
--     Start a fold at a specific level:                                      --
--       -- Section start {{{1                                                --
--                                                                            --
--     End a fold at a specific level:                                        --
--       -- Section end }}}1                                                  --
--                                                                            --
--     Increase fold level by 1:                                              --
--       -- Fold start {{{                                                    --
--                                                                            --
--     Decrease fold level by 1:                                              --
--       -- Fold end }}}                                                      --
--                                                                            --
--   The number after the marker sets the fold level; omitting it will        --
--   increase or decrease the current fold level by 1.                        --
--                                                                            --
-- Indent-based folding:                                                      --
--   On indented lines, folding behaves like Neovim's 'indent' method.        --
--                                                                            --
-- Filetype-based override:                                                   --
--   To use a different foldexpr for a filetype, add an entry to              --
--   `filetype_foldexprs` mapping the filetype to the desired function.       --
--                                                                            --
-- Example:                                                                   --
--   local filetype_foldexprs = {                                             --
--     lua = 'nvim_treesitter#foldexpr',                                      --
--     markdown = 'v:lua.buell.fold.markdown()',                              --
--   }                                                                        --
--                                                                            --
-- For debugging, you can show fold levels in the gutter:                     --
--   :set statuscolumn=%l\ %{foldlevel(v:lnum)}                               --
--   :set numberwidth=6                                                       --
--                                                                            --
--------------------------------------------------------------------------------

-- Table mapping filetypes to their foldexpr function names. If a filetype is
-- not in this table, the custom foldexpr defined below will be used.
local filetype_foldexprs = {
  lua      = 'nvim_treesitter#foldexpr',      -- use treesitter for Lua
  markdown = 'v:lua.buell.fold.markdown()',   -- use custom markdown foldexpr
}

-- Cache to store per-buffer record of fold markers.
-- Given that we don't expect there to be many markers in any given file, we
-- just store them in a simple list as opposed to a fancier data structure (like
-- a search tree).
local cache = {}

-- Don't bother trying to compute marker-based folds for buffers with more than
-- this number of lines.
local max_fold_lines = 10000

local parse_markers = function(lines, start_index)
  local markers = {}
  for i, line in ipairs(lines) do
    local line_number = start_index + i
    local start_level = line:match('{{{(%d+)')
    local end_level = line:match('}}}(%d+)')
    if start_level ~= nil and tonumber(start_level) ~= 0 then
      markers[#markers + 1] = {
        line = line_number,
        level = tonumber(start_level),
        kind = 'start',
      }
    elseif end_level ~= nil and tonumber(end_level) ~= 0 then
      markers[#markers + 1] = {
        line = line_number,
        level = tonumber(end_level),
        kind = 'end',
      }
    elseif line:match('{{{') then
      markers[#markers + 1] = {
        line = line_number,
        kind = 'increase',
      }
    elseif line:match('}}}') then
      markers[#markers + 1] = {
        line = line_number,
        kind = 'decrease',
      }
    end
  end
  return markers
end

-- This is a custom foldexpr (see `:help 'foldexpr'`) that combines the best of
-- `:set foldmethod=indent` and `:set foldmethod=marker`:
--
-- - On an indented line, it behaves like `foldmethod=indent`.
-- - On a non-indented line, it behaves like `foldmethod=marker`.
--
-- For the meaning of the return values, see `:help fold-expr`.
--
-- To debug this, set these to show the fold level in the gutter:
--
--    :set statuscolumn=%l\ %{foldlevel(v:lnum)}
--    :set numberwidth=6
--
local foldexpr = function(line_number)
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_get_option_value('filetype', {buf = bufnr})
  local foldexpr_func = filetype_foldexprs[filetype]

  if foldexpr_func then
    -- Evaluate the foldexpr function for this filetype. Use
    -- nvim_eval to handle both Vim and Lua function expressions.
    return vim.api.nvim_eval(foldexpr_func)
  end

  if not vim.api.nvim_buf_is_loaded(bufnr) then
    -- Believe it or not, we'll get called before the buffer is
    -- loaded, and calling `nvim_buf_attach()` with an unloaded
    -- buffer will fail; we have to bail when this happens.
    return 0
  end
  local line_count = vim.api.nvim_buf_line_count(0)
  if cache[bufnr] == nil then
    if line_count < max_fold_lines then
      -- Populate the cache.
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local markers = parse_markers(lines, 0)
      cache[bufnr] = markers

      -- Subscribe to future updates.
      vim.api.nvim_buf_attach(bufnr, false, {
        on_lines = function(_event, _bufnr, _changed_tick, first_line, last_line, new_last_line)
          local new_lines = vim.api.nvim_buf_get_lines(bufnr, first_line, new_last_line, false)
          local new_markers = parse_markers(new_lines, first_line)
          local old_markers = cache[bufnr]

          if old_markers then
            -- Remove potentially invalid markers inside changed range.
            -- Also, calculate position of marker from which we'll need to adjust
            -- line numbers.
            local position = #old_markers
            if position == 0 then
              -- Beware! If position is 0 (ie. `old_markers` table is empty), then
              -- the `table.move` below will effectively turn it into a non-list
              -- table, breaking it!
              position = 1
            else
              for i = #old_markers, 1, -1 do
                local marker = old_markers[i]
                if marker.line < first_line then
                  break
                elseif marker.line > last_line then
                  position = i
                elseif marker.line >= first_line and marker.line <= last_line then
                  table.remove(old_markers, i)
                  position = position - 1
                end
              end
            end

            -- Add new markers.
            -- Make space by moving elements to the right.
            table.move(old_markers, position, #old_markers, position + #new_markers)
            -- Copy elements from `new_markers` into `old_markers`.
            table.move(new_markers, 1, #new_markers, position, old_markers)

            -- Update line numbers of anything after the inserted/removed markers.
            local delta = new_last_line - last_line
            for i = position + #new_markers, #old_markers, 1 do
              if i ~= 0 then
                old_markers[i].line = old_markers[i].line + delta
              end
            end
          else
            -- Somehow, cache got cleared. Repopulate it.
            cache[bufnr] = new_markers
          end
        end,
        on_detach = function()
          cache[bufnr] = nil
        end,
        on_reload = function()
          cache[bufnr] = nil
        end,
      })
    else
      cache[bufnr] = {}
    end
  end

  -- Look through markers list to figure out the impact on the current line.
  -- If markers are not well-formed, all bets are off.
  local base = 0
  for _, marker in ipairs(cache[bufnr]) do
    if marker.line <= line_number then
      -- Note that when `marker.line == line_number` we don't just return the
      -- level, but rather a level-start indicator (eg. `>1`) instead. This
      -- is so that we can support consecutive markers like in the following
      -- example (where every line is of level 1, but we want 3 folds):
      --
      --     section 1 {{{1
      --     foo
      --     bar
      --     baz
      --
      --     section 2 {{{1
      --     foo
      --     bar
      --     baz
      --
      --     section 3 {{{1
      --     foo
      --     bar
      --     baz
      --
      if marker.kind == 'start' then
        if marker.line == line_number then
          return '>' .. marker.level
        end
        base = marker.level
      elseif marker.kind == 'end' then
        if marker.line == line_number then
          return '<' .. marker.level
        end
        base = marker.level - 1
      elseif marker.kind == 'increase' then
        base = base + 1
        if marker.line == line_number then
          return '>' .. base
        end
      elseif marker.kind == 'decrease' then
        base = base - 1
        if marker.line == line_number then
          return '>' .. base
        end
      end
    else
      break
    end
  end

  -- Now we do indent-based folding.
  local line = vim.fn.getline(line_number)
  local current_indent = vim.fn.indent(line_number)
  local previous_non_blank = vim.fn.prevnonblank(line_number - 1)
  local previous_non_blank_indent = vim.fn.indent(previous_non_blank)

  if line == '' then
    -- Blank line.
    return base + math.floor(previous_non_blank_indent / vim.fn.shiftwidth())
  else
    return base + math.floor(current_indent / vim.fn.shiftwidth())
  end
end

return foldexpr
