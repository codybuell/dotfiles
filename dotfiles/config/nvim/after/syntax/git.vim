" vim-fugitive :Git log overrides, expects format '%h  %ad  %<(16,trunc)%aN %d %s"<CR>'
syn match buellGitLogLine  /\v\x{7,}\s{2}\d{4}-\d{2}-\d{2}\s{2}.{16}\s{2}(\([^)]+\))?.*$/
syn match buellGitUsername /\v\x{7,}\s{2}\d{4}-\d{2}-\d{2}\s{2}.{16}/ contained containedin=buellGitLogLine
syn match buellGitDate     /\v\x{7,}\s{2}\d{4}-\d{2}-\d{2}/ contained containedin=buellGitUsername
syn match buellGitSha      /\v\x{7,}/ contained containedin=buellGitDate
syn match buellGitRefNames /\v\([^\)]+\)/ contained containedin=buellGitLogLine

hi def link buellGitUsername String
hi def link buellGitDate Directory
hi def link buellGitSha Label
hi def link buellGitRefNames WarningMsg
