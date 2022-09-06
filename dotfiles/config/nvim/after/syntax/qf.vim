" vim-fugitive overrides, format defined in after/plugin/vim-fugitive.lua
syn match buellGitLogLine     /\v^\w+:?[^|]+\|\|\s\d{4}-\d{2}-\d{2}\s{3}.{16}\s.*$/
syn match buellGitSha         /\v^[^:|]+[:|]/he=e-1 contained containedin=buellGitLogLine
syn match buellGitFilename    /\v:[^|]+\|\|/hs=s+1,he=e-2 contained containedin=buellGitSha
syn match buellGitShaFileSep  /\v:{1}/ contained containedin=buellGitFilename
syn match buellGitDate        /\v\|\|\s\d{4}-\d{2}-\d{2}/hs=s+2 contained containedin=buellGitFilename,buellGitSha
syn match buellGitSeparator   /\v\|\|/ contained containedin=buellGitDate
syn match buellGitUsername    /\v\|\|\s\d{4}-\d{2}-\d{2}\s{3}.{16}/hs=s+13 contained containedin=buellGitSeparator
syn match buellGitRefNames    /\v\([^\)]+\)/ contained containedin=buellGitLogLine

hi def link buellGitSha Label
hi def link buellGitFilename Label
hi def link buellGitShaFileSep Comment
hi def link buellGitDate Directory
hi def link buellGitSeparator Ignore
hi def link buellGitUsername String
hi def link buellGitRefNames WarningMsg
