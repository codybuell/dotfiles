" syn-include markdown syntax after an explicit !m in mail files

" we need to temporarily unset the current syntax, not sure why, if we dont
" only parts of the markdown receive the appropriate syntax highlighting, in
" particular, h1-hN titles are not matched... wtf
let b:current_syntax = ''
unlet b:current_syntax

" define a group for our markdown syntax and define what region to apply it to
syntax include @mailMarkdown syntax/markdown.vim
syntax region mailMarkdown start="^!m$" end="%%" contains=@mailMarkdown

" reset our current syntax back to mail
let b:current_syntax = 'mail'
