" Vim syntax file
" Language:	Markdown
" Maintainer:	Ben Williams <benw@plasticboy.com>
" URL:		http://plasticboy.com/markdown-vim-mode/
" Remark:	Uses HTML syntax file
" TODO: 	Handle stuff contained within stuff (e.g. headings within blockquotes)


" read the HTML syntax to start with
runtime! syntax/html.vim

if exists('b:current_syntax')
  unlet b:current_syntax
endif

if exists('b:current_syntax')
  finish
endif

" don't use standard HiLink, it will not work with included syntax files
command! -nargs=+ HtmlHiLink hi def link <args>

syn spell toplevel
syn case ignore
syn sync linebreaks=1

" additions to html groups
syn region mkdItalic matchgroup=mkdItalic start="\%(\*\|_\)"    end="\%(\*\|_\)"
syn region mkdBold matchgroup=mkdBold start="\%(\*\*\|__\)"    end="\%(\*\*\|__\)"
syn region mkdBoldItalic matchgroup=mkdBoldItalic start="\%(\*\*\*\|___\)"    end="\%(\*\*\*\|___\)"
syn region htmlItalic matchgroup=mkdItalic start="\%(^\|\s\)\zs\*\ze[^\\\*\t ]\%(\%([^*]\|\\\*\|\n\)*[^\\\*\t ]\)\?\*\_W" end="[^\\\*\t ]\zs\*\ze\_W" keepend contains=@Spell concealends
syn region htmlItalic matchgroup=mkdItalic start="\%(^\|\s\)\zs_\ze[^\\_\t ]" end="[^\\_\t ]\zs_\ze\_W" keepend contains=@Spell concealends
syn region htmlBold matchgroup=mkdBold start="\%(^\|\s\)\zs\*\*\ze\S" end="\S\zs\*\*" keepend contains=@Spell concealends
syn region htmlBold matchgroup=mkdBold start="\%(^\|\s\)\zs__\ze\S" end="\S\zs__" keepend contains=@Spell concealends
syn region htmlBoldItalic matchgroup=mkdBoldItalic start="\%(^\|\s\)\zs\*\*\*\ze\S" end="\S\zs\*\*\*" keepend contains=@Spell concealends
syn region htmlBoldItalic matchgroup=mkdBoldItalic start="\%(^\|\s\)\zs___\ze\S" end="\S\zs___" keepend contains=@Spell concealends

" [link](URL) | [link][id] | [link][] | ![image](URL)
syn region mkdFootnotes matchgroup=mkdDelimiter start="\[^"    end="\]"
syn region mkdID matchgroup=mkdDelimiter    start="\["    end="\]" contained oneline conceal
syn region mkdURL matchgroup=mkdDelimiter   start="("     end=")"  contained oneline conceal
syn region mkdLink matchgroup=mkdDelimiter  start="\\\@<!!\?\[\ze[^]\n]*\n\?[^]\n]*\][[(]" end="\]" contains=@mkdNonListItem,@Spell nextgroup=mkdURL,mkdID skipwhite concealends

" autolink without angle brackets
" mkd  inline links:      protocol     optional  user:pass@  sub/domain                    .com, .co.uk, etc         optional port   path/querystring/hash fragment
"                         ------------ _____________________ ----------------------------- _________________________ ----------------- __
syn match   mkdInlineURL /https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z0-9][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?[^] \t]*/

" Autolink with parenthesis.
syn region  mkdInlineURL matchgroup=mkdDelimiter start="(\(https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z0-9][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?[^] \t]*)\)\@=" end=")"

" Autolink with angle brackets.
syn region mkdInlineURL matchgroup=mkdDelimiter start="\\\@<!<\ze[a-z][a-z0-9,.-]\{1,22}:\/\/[^> ]*>" end=">"

" Link definitions: [id]: URL (Optional Title)
syn region mkdLinkDef matchgroup=mkdDelimiter   start="^ \{,3}\zs\[\^\@!" end="]:" oneline nextgroup=mkdLinkDefTarget skipwhite
syn region mkdLinkDefTarget start="<\?\zs\S" excludenl end="\ze[>[:space:]\n]"   contained nextgroup=mkdLinkTitle,mkdLinkDef skipwhite skipnl oneline
syn region mkdLinkTitle matchgroup=mkdDelimiter start=+"+     end=+"+  contained
syn region mkdLinkTitle matchgroup=mkdDelimiter start=+'+     end=+'+  contained
syn region mkdLinkTitle matchgroup=mkdDelimiter start=+(+     end=+)+  contained

" html Headings
syn region htmlH1 matchgroup=mkdHeading start="^\s*#"      end="$" contains=mkdLink,mkdInlineURL,@Spell
syn region htmlH2 matchgroup=mkdHeading start="^\s*##"     end="$" contains=mkdLink,mkdInlineURL,@Spell
syn region htmlH3 matchgroup=mkdHeading start="^\s*###"    end="$" contains=mkdLink,mkdInlineURL,@Spell
syn region htmlH4 matchgroup=mkdHeading start="^\s*####"   end="$" contains=mkdLink,mkdInlineURL,@Spell
syn region htmlH5 matchgroup=mkdHeading start="^\s*#####"  end="$" contains=mkdLink,mkdInlineURL,@Spell
syn region htmlH6 matchgroup=mkdHeading start="^\s*######" end="$" contains=mkdLink,mkdInlineURL,@Spell
syn match  htmlH1 /^.\+\n=\+$/ contains=mkdLink,mkdInlineURL,@Spell
syn match  htmlH2 /^.\+\n-\+$/ contains=mkdLink,mkdInlineURL,@Spell

" define markdown groups
syn match  mkdLineBreak    /  \+$/
syn region mkdBlockquote   start=/^\s*>/                   end=/$/ contains=mkdLink,mkdInlineURL,mkdLineBreak,@Spell
syn region mkdCode matchgroup=mkdCodeDelimiter start=/\(\([^\\]\|^\)\\\)\@<!`/ end=/`/ concealends
syn region mkdCode matchgroup=mkdCodeDelimiter start=/\(\([^\\]\|^\)\\\)\@<!``/ skip=/[^`]`[^`]/ end=/``/ concealends
" syn region mkdCode matchgroup=mkdCodeDelimiter start=/^\s*\z(`\{3,}\)[^`]*$/ end=/^\s*\z1*\s*$/ concealends
syn region mkdCode matchgroup=mkdCodeDelimiter start=/^\s*\z(`\{3,}\)[^`]*$/ end=/^\s*\z1*\s*$/
syn region mkdCode matchgroup=mkdCodeDelimiter start=/\(\([^\\]\|^\)\\\)\@<!\~\~/ end=/\(\([^\\]\|^\)\\\)\@<!\~\~/ concealends
"syn region mkdCode matchgroup=mkdCodeDelimiter start=/^\s*\z(\~\{3,}\)\s*[0-9A-Za-z_+-]*\s*$/ end=/^\s*\z1*\s*$/ concealends
syn region mkdCode matchgroup=mkdCodeDelimiter start="<pre\(\|\_s[^>]*\)\\\@<!>" end="</pre>" concealends
syn region mkdCode matchgroup=mkdCodeDelimiter start="<code\(\|\_s[^>]*\)\\\@<!>" end="</code>" concealends
syn region mkdFootnote start="\[^" end="\]"
syn match  mkdCode /^\s*\n\(\(\s\{8,}[^ ]\|\t\t\+[^\t]\).*\n\)\+/
syn match  mkdCode /\%^\(\(\s\{4,}[^ ]\|\t\+[^\t]\).*\n\)\+/
syn match  mkdCode /^\s*\n\(\(\s\{4,}[^ ]\|\t\+[^\t]\).*\n\)\+/ contained
syn match  mkdListItem /^\s*\%([-*+]\|\d\+\.\)\ze\s\+/ contained
syn region mkdListItemLine start="^\s*\%([-*+]\|\d\+\.\)\s\+" end="$" oneline contains=@mkdNonListItem,mkdListItem,@Spell
syn region mkdNonListItemBlock start="\(\%^\(\s*\([-*+]\|\d\+\.\)\s\+\)\@!\|\n\(\_^\_$\|\s\{4,}[^ ]\|\t+[^\t]\)\@!\)" end="^\(\s*\([-*+]\|\d\+\.\)\s\+\)\@=" contains=@mkdNonListItem,@Spell
syn match  mkdRule /^\s*\*\s\{0,1}\*\s\{0,1}\*\(\*\|\s\)*$/
syn match  mkdRule /^\s*-\s\{0,1}-\s\{0,1}-\(-\|\s\)*$/
syn match  mkdRule /^\s*_\s\{0,1}_\s\{0,1}_\(_\|\s\)*$/

" todo items `- [ ] text`
syn match buellTodo      /\v^\s*-\s\[\s\]\s.*$/
syn match buellTodoText  /\v\[\s\]\s.*$/ contained containedin=buellTodo contains=mkdCode,htmlItalic,htmlBold,mkdBoldItalic,htmlStrike,mkdInlineURL,mkdStrike

" in progress todo items `- [/] text`
syn match buellInProgressTodo      /\v^\s*-\s\[[\/\\]\]\s.*$/
syn match buellInProgressTodoText  /\v\[[\/\\]\]\s.*$/ contained containedin=buellInProgressTodo contains=mkdCode,htmlItalic,htmlBold,mkdBoldItalic,htmlStrike,mkdInlineURL,mkdStrike

" completed todo items `- [x] text`
syn match buellCompletedTodo      /\v^\s*-\s\[[xX×]\]\s.*$/
syn match buellCompletedTodoText  /\v\[[xX×]\]\s.*$/ contained containedin=buellCompletedTodo contains=mkdStrike

" dropped todo items `- [-] text`
syn match buellDroppedTodo      /\v^\s*-\s\[[-]\]\s.*$/
syn match buellDroppedTodoText  /\v\[[-]\]\s.*$/ contained containedin=buellDroppedTodo

" important todo items `- [!] text`
syn match buellImportantTodo      /\v^\s*-\s\[[!]\]\s.*$/
syn match buellImportantTodoText  /\v\[[!]\]\s.*$/ contained containedin=buellImportantTodo

" yaml frontmatter
syn include @yamlTop syntax/yaml.vim
syn region Comment matchgroup=mkdDelimiter start="\%^---$" end="^\(---\|\.\.\.\)$" contains=@yamlTop keepend
unlet! b:current_syntax

" markdown math
" syn include @tex syntax/tex.vim
" syn region mkdMath start="\\\@<!\$" end="\$" skip="\\\$" contains=@tex keepend
" syn region mkdMath start="\\\@<!\$\$" end="\$\$" skip="\\\$" contains=@tex keepend

" strike through
syn region mkdStrike matchgroup=htmlStrike start="\%(\~\~\)" end="\%(\~\~\)" concealends
HtmlHiLink mkdStrike        htmlStrike

syn cluster mkdNonListItem contains=@htmlTop,htmlItalic,htmlBold,htmlBoldItalic,mkdFootnotes,mkdInlineURL,mkdLink,mkdLinkDef,mkdLineBreak,mkdBlockquote,mkdCode,mkdRule,htmlH1,htmlH2,htmlH3,htmlH4,htmlH5,htmlH6,mkdMath,mkdStrike

"highlighting for Markdown groups
HtmlHiLink mkdString        String
HtmlHiLink mkdCode          String
HtmlHiLink mkdCodeDelimiter String
HtmlHiLink mkdCodeStart     NonText
HtmlHiLink mkdCodeEnd       NonText
HtmlHiLink mkdFootnote      Comment
HtmlHiLink mkdBlockquote    Comment
HtmlHiLink mkdListItem      Identifier
HtmlHiLink mkdRule          Identifier
HtmlHiLink mkdLineBreak     Visual
HtmlHiLink mkdFootnotes     htmlLink
HtmlHiLink mkdLink          htmlLink
HtmlHiLink mkdURL           htmlString
HtmlHiLink mkdInlineURL     htmlLink
HtmlHiLink mkdID            Identifier
HtmlHiLink mkdLinkDef       mkdID
HtmlHiLink mkdLinkDefTarget mkdURL
HtmlHiLink mkdLinkTitle     htmlString
HtmlHiLink mkdDelimiter     Delimiter

let b:current_syntax = 'mkd'

delcommand HtmlHiLink
" vim: ts=8
