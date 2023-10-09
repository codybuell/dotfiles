--------------------------------------------------------------------------------
--                                                                            --
--  Corpus
--                                                                            --
--------------------------------------------------------------------------------

vim.g.CorpusBangCreation = 1
vim.g.CorpusAutoCd = 1

CorpusDirectories = {
  ['{{ CodexRepo }}'] = {
    autocommit = true,
    autoreference = false,
    autotitle = 1,
    base = './',
    transform = 'local',
  },
}

