" get shell syntax highlighting after script: | in yaml files
" see h:syn-region h:syn-pattern h:syn-start (for matchgroup)
" rs is offsetting the start of the region 8 chars from start, this allows
" '  script' to be highlighted by matchgroup, but the ': |' to be shell
" syntax, closer to normal yaml syntax, without it region normally starts
" after the end of the match, so we're pulling it forward slightly here
let b:current_syntax = ''
unlet b:current_syntax
syntax include @SHELL syntax/sh.vim
syntax region shellCode matchgroup=Identifier start="^  script: *| *$"rs=s+8 end="^  \w"he=s-1,me=s-1 contains=@SHELL

" let b:current_syntax = ''
" unlet b:current_syntax
" syntax include @TEX syntax/tex.vim
" syntax region texCode start=#^tex:#hs=e+1 end=+^\w+he=s-1,me=s-1 contains=@TEX
