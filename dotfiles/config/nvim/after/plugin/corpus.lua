--------------------------------------------------------------------------------
--                                                                            --
--  Corpus                                                                    --
--                                                                            --
--------------------------------------------------------------------------------

vim.g.CorpusBangCreation = 1
vim.g.CorpusAutoCd = 1

CorpusDirectories = {
  [vim.fn.expand('{{ Notes }}')] = {
    autocommit = false,
    autoreference = false,
    autotitle = 0,
    base = './',
    transform = 'local',
  },
}

