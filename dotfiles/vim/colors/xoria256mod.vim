" Vim color file
"
" Name:         xoria256mod.vim
" Version:      1.5.mod
" Maintainer:   Dmitriy Y. Zotikov (xio) <xio@ungrund.org>
" Modified By:  Cody Buell <cody@coydbuell.com>
"
" Should work in recent 256 color terminals.  88-color terms like urxvt are
" NOT supported.
"
" Don't forget to install 'ncurses-term' and set TERM to xterm-256color or
" similar value.
"
" Color numbers (0-255) see:
" http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
"
" For a specific filetype highlighting rules issue :syntax list when a file of
" that type is opened.

"////////////////////"
"// initialization //"
"////////////////////"

if &t_Co != 256 && ! has("gui_running")
  echomsg ""
  echomsg "err: please use GUI or a 256-color terminal (so that t_Co=256 could be set)"
  echomsg ""
  finish
endif

set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "xoria256mod"

"/////////////"
"// general //"
"/////////////"

hi Normal            ctermfg=253   ctermbg=234   guifg=#dadada   guibg=#1c1c1c   cterm=none      gui=none
hi Cursor                          ctermbg=214                   guibg=#ffaf00
hi CursorColumn                    ctermbg=238                   guibg=#444444
hi CursorLine                      ctermbg=235                   guibg=#262626   cterm=none      gui=none
hi Error             ctermfg=15    ctermbg=1     guifg=#ffffff   guibg=#800000
hi ErrorMsg          ctermfg=15    ctermbg=1     guifg=#ffffff   guibg=#800000
hi FoldColumn        ctermfg=238   ctermbg=bg    guifg=#444444   guibg=#1c1c1c
hi Folded            ctermfg=242   ctermbg=235   guifg=#6c6c6c   guibg=#262626
hi IncSearch         ctermfg=0     ctermbg=223   guifg=#000000   guibg=#ffdfaf   cterm=none      gui=none
hi LineNr            ctermfg=238   ctermbg=bg    guifg=#444444   guibg=#1c1c1c
hi CursorLineNr      ctermfg=250   ctermbg=bg    guifg=#bcbcbc   guibg=#1c1c1c
hi MatchParen        ctermfg=188   ctermbg=68    guifg=#dfdfdf   guibg=#5f87df   cterm=bold      gui=bold
" hi MoreMsg
hi NonText           ctermfg=235   ctermbg=234   guifg=#262626   guibg=#121212   cterm=bold      gui=bold
hi Pmenu             ctermfg=0     ctermbg=250   guifg=#000000   guibg=#bcbcbc
hi PmenuSel          ctermfg=255   ctermbg=243   guifg=#eeeeee   guibg=#767676
hi PmenuSbar                       ctermbg=252                   guibg=#d0d0d0
hi PmenuThumb        ctermfg=243                 guifg=#767676
hi Search            ctermfg=0     ctermbg=67    guifg=#000000   guibg=#afdf5f
hi SignColumn        ctermfg=248                 guifg=#a8a8a8
hi SpecialKey        ctermfg=1                   guifg=#800000
hi SpellBad          ctermfg=160   ctermbg=bg    guifg=fg                        cterm=underline guisp=#df0000
hi SpellCap          ctermfg=189   ctermbg=bg    guifg=#dfdfff   guibg=bg        cterm=underline gui=underline
hi SpellRare         ctermfg=168   ctermbg=bg    guifg=#df5f87   guibg=bg        cterm=underline gui=underline
hi SpellLocal        ctermfg=98    ctermbg=bg    guifg=#875fdf   guibg=bg        cterm=underline gui=underline
hi StatusLine        ctermfg=15    ctermbg=239   guifg=#ffffff   guibg=#4e4e4e   cterm=bold      gui=bold
hi StatusLineNC      ctermfg=249   ctermbg=237   guifg=#b2b2b2   guibg=#3a3a3a   cterm=none      gui=none
hi TabLine           ctermfg=243   ctermbg=237   guifg=#767676   guibg=#3a3a3a   cterm=none      gui=none
hi TabLineFill       ctermfg=243   ctermbg=237   guifg=#767676   guibg=#3a3a3a   cterm=none      gui=none
hi TabLineSel        ctermfg=254   ctermbg=bg    guifg=#e4e4e4   guibg=bg        cterm=none      gui=none
hi Title             ctermfg=225                 guifg=#ffdfff
hi Todo              ctermfg=0     ctermbg=184   guifg=#000000   guibg=#dfdf00
hi Underlined        ctermfg=39                  guifg=#00afff                   cterm=underline gui=underline
hi VertSplit         ctermfg=237   ctermbg=237   guifg=#3a3a3a   guibg=#3a3a3a   cterm=none      gui=none
" hi VIsualNOS       ctermfg=24    ctermbg=153   guifg=#005f87   guibg=#afdfff   cterm=none      gui=none
hi Visual            ctermfg=255   ctermbg=67    guifg=#eeeeee   guibg=#5f87af
hi VisualNOS         ctermfg=255   ctermbg=60    guifg=#eeeeee   guibg=#5f5f87
hi WildMenu          ctermfg=0     ctermbg=150   guifg=#000000   guibg=#afdf87   cterm=bold      gui=bold

"////////////"
"// syntax //"
"////////////"

hi Comment           ctermfg=244                 guifg=#808080
hi Constant          ctermfg=229                 guifg=#ffffaf
"hi Function
hi Identifier        ctermfg=254                 guifg=#dfafdf                   cterm=none
hi Ignore            ctermfg=238                 guifg=#444444
"hi Keyword
hi Number            ctermfg=180                 guifg=#dfaf87
hi PreProc           ctermfg=109                 guifg=#afdf87
hi Special           ctermfg=254                 guifg=#df8787
hi Statement         ctermfg=109                 guifg=#87afdf                   cterm=none      gui=none
hi String            ctermfg=187                 guifg=#d7d7af
hi Type              ctermfg=131                 guifg=#5f8787                   cterm=none      gui=none

"/////////"
"// git //"
"/////////"

hi gitcommitSummary  ctermfg=110

"//////////////"
"// nerdtree //"
"//////////////"

hi NERDTreeOpenable  ctermfg=110
hi NERDTreeClosable  ctermfg=110
hi NERDTreeExecFile  ctermfg=109

"/////////////"
"// vimdiff //"
"/////////////"

hi diffAdded         ctermfg=150                 guifg=#afdf87
hi diffRemoved       ctermfg=174                 guifg=#df8787
hi diffAdd           ctermfg=bg    ctermbg=151   guifg=bg        guibg=#afdfaf
"hi diffDelete       ctermfg=bg    ctermbg=186   guifg=bg        guibg=#dfdf87   cterm=none      gui=none
hi diffDelete        ctermfg=bg    ctermbg=246   guifg=bg        guibg=#949494   cterm=none      gui=none
hi diffChange        ctermfg=bg    ctermbg=181   guifg=bg        guibg=#dfafaf
hi diffText          ctermfg=bg    ctermbg=174   guifg=bg        guibg=#df8787   cterm=none      gui=none

"//////////"
"// html //"
"//////////"

" hi htmlTag         ctermfg=146                 guifg=#afafdf
" hi htmlEndTag      ctermfg=146                 guifg=#afafdf
hi htmlTag           ctermfg=244
hi htmlEndTag        ctermfg=244
hi htmlArg           ctermfg=254                 guifg=#e4e4e4
hi htmlValue         ctermfg=187                 guifg=#dfdfaf
hi htmlTitle         ctermfg=254   ctermbg=95
" hi htmlArg         ctermfg=146
" hi htmlTagName     ctermfg=146
" hi htmlString      ctermfg=187

"////////////"
"// django //"
"////////////"

hi djangoVarBlock    ctermfg=180
hi djangoTagBlock    ctermfg=150
hi djangoStatement   ctermfg=146
hi djangoFilter      ctermfg=174

"////////////"
"// python //"
"////////////"

hi pythonExceptions  ctermfg=174

"//////////////"
"// nerdtree //"
"//////////////"

hi Directory         ctermfg=110                 guifg=#87afdf
hi treeCWD           ctermfg=180                 guifg=#dfaf87
hi treeClosable      ctermfg=174                 guifg=#df8787
hi treeOpenable      ctermfg=150                 guifg=#afdf87
hi treePart          ctermfg=244                 guifg=#808080
hi treeDirSlash      ctermfg=244                 guifg=#808080
hi treeLink          ctermfg=182                 guifg=#dfafdf

"//////////////"
"// markdown //"
"//////////////"

hi htmlH1            ctermfg=131
hi htmlH2            ctermfg=131
hi htmlH3            ctermfg=131
hi htmlH4            ctermfg=131
hi htmlH5            ctermfg=131
hi htmlH6            ctermfg=131
hi markdownRule      ctermfg=131
hi markdownCodeBlock ctermfg=109

"//////////////////"
"// vimrc custom //"
"//////////////////"

hi ColorColumn                     ctermbg=237                   guibg=#3a3a3a   cterm=none      gui=none

"///////////////"
"// vim debug //"
"///////////////"

" FIXME
" you may want to set SignColumn highlight in your .vimrc
" :help sign
" :help SignColumn

" hi currentLine term=reverse cterm=reverse gui=reverse
" hi breakPoint  term=NONE    cterm=NONE    gui=NONE
" hi empty       term=NONE    cterm=NONE    gui=NONE

" sign define currentLine linehl=currentLine
" sign define breakPoint  linehl=breakPoint  text=>>
" sign define both        linehl=currentLine text=>>
" sign define empty       linehl=empty
