--------------------------------------------------------------------------------
--                                                                            --
--  Codex                                                                     --
--                                                                            --
--  Corpus-style note chooser, creation, and link handling for the codex.    --
--  This is the only codex file containing templated paths; everything in    --
--  lua/codex/ is path-agnostic and configured here via setup().             --
--                                                                            --
--------------------------------------------------------------------------------

local has_codex, codex = pcall(require, 'codex')
if not has_codex then
  return
end

local notes = vim.fn.fnamemodify('{{ Notes }}', ':p'):gsub('/$', '')

codex.setup({
  notes   = notes,
  journal = vim.fn.fnamemodify('{{ Journal }}', ':p'):gsub('/$', ''),
  wikis   = {
    codex     = notes,
    archive   = notes .. '/Archive',
    domains   = notes .. '/Domains',
    ideas     = notes .. '/Ideas',
    journal   = notes .. '/Journal',
    people    = notes .. '/People',
    projects  = notes .. '/Projects',
    reference = notes .. '/Reference',
    self      = notes .. '/Self',
    topics    = notes .. '/Topics',
  },
})

----------------
--  Mappings  --
----------------

-- open the codex chooser
vim.keymap.set('n', '<Leader>n', codex.open, { silent = true })
