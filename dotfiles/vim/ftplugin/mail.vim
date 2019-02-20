" see also after/ftplugin/mail.vim

" enable spell checking
setlocal spell

" enables markdown syntax highlighting if message starts with !m
syntax include @mailMarkdown syntax/markdown.vim
syntax region mailMarkdown start="^!m$" end="%%" contains=@mailMarkdown
