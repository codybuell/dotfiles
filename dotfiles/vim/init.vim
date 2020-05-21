""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
"   Configurations for Vim & Neovim                                            "
"                                                                              "
"   Mappings:                                                                  "
"                                                                              "
"     leader       ␣ (spacebar)                                                "
"     localleader  \                                                           "
"                                                                              "
"     normal mode                                                              "
"     -----------                                                              "
"                                                                              "
"     available keys:                                                          "
"         leader                                                               "
"                   (      `1234567890 =abcdef hijklmnopqrstuvwxyz[];     )    "
"         ␣     +   ( ↹←→↓↑ 1234567890 =   de   i k m opqr   v xyz[];, /↵ )    "
"         \     +   ( ↹←→↓↑`1234567890-=ab defghijklmno q st v xyz[];,./↵ )    "
"         Ctrl  +   ( ↹←→↓↑`1234567890-=abcdefg i   mnopqrstuvwxyz[];,./↵ )    "
"         Shift +   ( ↹    `1234567890-=abcdefghijklmnopqrstuvwxyz[];,./↵ )    "
"                                                                              "
"     misc:                   top row:                command-t:               "
"     -  dirvish              ␣` cycle views          ␣t start at (n)vim cwd   "
"     ,/ clear hl search      ␣1 hitest, better :hi   ␣. start at buffer dir   "
"     ←  ale prev             ␣2 syn stack @curs      ␣b list buffers          "
"     →  ale next             ␣3                      ␣j list jump list        "
"     ↑  jump list nav        ␣4                      ␣h (n)vim help docs      "
"     ↓  jump list nav        ␣5                      ␣c ctags                 "
"     ␣␣ toggle buffers       ␣6                      ␣n notes                 "
"     ␣u underline text       ␣7                                               "
"     ␣m easymotion           ␣8                      ferret:                  "
"     ␣↵ re-run last macro    ␣9                      ␣aa ack all vim cwd      "
"     ↹  toggle fold          ␣0 cycle lists          ␣aw ack current word     "
"                             ␣- cycle sidebars       ␣as ack search & replace "
"                             ␣=                      ␣a. ack buffer dir       "
"                                                                              "
"     \c redo buffer syntax   easymotion:             scalpel:                 "
"     \r gen random chars     ␣f find a char & move   ␣s change word @ cursor  "
"     \w open work journal    ␣w move to word                                "
"     \p open personal jrnl                           fugitive (git...):       "
"     \u edit ft's snippets   fastfold:               ␣gs status               "
"     \v vertical split       zuz update folds        ␣gb blame                "
"     \h horizontal split                             ␣gp push orig mstr       "
"                             splitjoin:              ␣ga add %:p              "
"                             gS split oneliner       ␣gc commit -v -q         "
"                             gJ join multiliner      ␣gt commit -v -q %:p     "
"                                                     ␣gd vdiff                "
"                             laravel:                ␣ge edit                 "
"                             ␣lr edit routes.php     ␣gr read                 "
"                             ␣la laravel artisan     ␣gw write                "
"                             ␣ll list routes         ␣gl log for cur file     "
"                             ␣le edit .env           ␣gm move                 "
"                             ␣lw edit webpack        ␣go checkout             "
"     <C-h> nav split win                                                      "
"     <C-j> nav split win     commentary:                                      "
"     <C-k> nav split win     gcc comment out block                            "
"     <C-l> nav split win     gt  use with motion                              "
"                                                                              "
"                                                                              "
"     insert mode                                                              "
"     -----------                                                              "
"                                                                              "
"     hh    <esc>                                                              "
"     <C-l> expand snippet                                                     "
"     \c    correct syntax hl                                                  "
"                                                                              "
"     visual mode                                                              "
"     -----------                                                              "
"                                                                              "
"     ←  drag selection       v   expand selection                             "
"     →  drag selection       C-v shrink selection                             "
"     ↑  drag selection                                                        "
"     ↓  drag selection                                                        "
"                                                                              "
"     command mode                                                             "
"     ------------                                                             "
"                                                                              "
"                                                                              "
"   Lists:                                                                     "
"                                                                              "
"   QUICKFIX (global to one session)                                           "
"     - results from ferret                                                    "
"                                                                              "
"   LOCATION LIST (local to current tab or window within a tab)                "
"     - language server findings                                               "
"                                                                              "
"                                                                              "
"     * difference relevant when running splits, vim windows are tmux panes    "
"       equivalents, note however that tabs are collections of windows, so     "
"       a tab is treated as a different window                                 "
"                                                                              "
"                                                                              "
"   Debugging:                                                                 "
"                                                                              "
"     profile application launch:                                              "
"       `vim --startuptime vim.log`                                            "
"                                                                              "
"     capture debug info to log file:                                          "
"       `NVIM_PYTHON_LOG_FILE=nvim.log NVIM_NCM_LOG_LEVEL=DEBUG nvim`          "
"                                                                              "
"     show all scripts in order of evaluation:                                 "
"       :scriptnames                                                           "
"                                                                              "
"     check for missing providers / deps:                                      "
"       :checkhealth                                                           "
"                                                                              "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""
"            "
"   Python   "
"            "
""""""""""""""

" ultisnips complains about a depricated imp vs importlib, silence the warning
if !has('nvim') && has('python3')
  silent! python3 1
endif

" avoid search, speeding up start-up
if filereadable('/usr/local/bin/python') && filereadable('/usr/local/bin/python3')
  let g:python_host_prog  = '/usr/local/bin/python'
  let g:python3_host_prog = '/usr/local/bin/python3'
endif

"""""""""""""""
"             "
"   Plugins   "
"             "
"""""""""""""""

if &loadplugins
  if has('packages')
    " COMPLETION
    packadd! deoplete               " asynchronous completion utility
    packadd! deoplete-emoji         " deoplete completion source for emoji's
    packadd! ultisnips              " snippet utility

    " NAVIGATION
    packadd! command-t              " fuzzy search file navigation
    packadd! loupe                  " improved search configurations
    packadd! nerdtree               " tree-based file browser
    packadd! tagbar                 " ctags of open buffer ordered by scope
    packadd! vim-dirvish            " path navigator, netrw replacement
    packadd! vim-easymotion         " improved movement around files

    " SYNTAX & LIGIBILITY
    packadd! base16-vim             " base16 color themes
    packadd! indentline             " add vertical line showing indentations
    packadd! jsonc.vim              " syntax support for cjson / jsonc
    packadd! pinnacle               " highlight group manipulations
    packadd! scss-syntax.vim        " fix slow load times with native sass syntax
    packadd! typescript-vim         " typscript support for vim
    packadd! vim-blade              " blade syntax highlighting
    packadd! vim-json               " improved json syntax, no conceal
    packadd! vim-markdown           " improved markdown support
    packadd! vim-vue                " syntax highlighting for vue components

    " EDITING
    packadd! ferret                 " multi-file search and search/replace
    packadd! scalpel                " improved in file word replacement
    packadd! splitjoin              " toggle between single & multi-line formats
    packadd! vim-camelsnek          " case conversion util
    packadd! vim-commentary         " apply or remove comments, motion support
    packadd! vim-expand-region      " grow or shrink visual selections
    packadd! vim-repeat             " add ability to repeat non atomic functions
    packadd! vim-speeddating        " ctrl-a ctrl-x to increment decrement dates
    packadd! vim-surround           " ability to change surrounding enclosures

    " INTEGRATIONS
    packadd! terminus               " improved terminal and tmux integration
    packadd! vim-dadbod             " database interactions
    packadd! vim-fugitive           " git integration to vim
    packadd! vim-marked             " open markdown documents in Marked2

    " MISCELLANEOUS
    packadd! howmuch                " perform math on visual selections
    packadd! goyo.vim               " writing room stylings for focused work
    packadd! limelight.vim          " darken all text but current paragraph
    packadd! fastfold               " speed up folding, fold only when needed
    packadd! vim-obsession          " improved session management
    packadd! vim-tmux-navigator     " use vim window motions to nav into tmux

"   packadd! vim-go
    if has('nvim')
      packadd! firenvim             " use neovim in browser textareas
      packadd! nvim-lsp             " configurations for native lsp client
      packadd! deoplete-lsp         " native lsp completion support for deoplete
      packadd! diagnostic-nvim      " overrides to native lsp diagnostic funcs
"     packadd! float-preview
    endif
  else
    source $HOME/.vim/pack/bundle/opt/vim-pathogen/autoload/pathogen.vim
    call pathogen#infect('pack/bundle/opt/{}')
    call pathogen#helptags()
  endif
endif

"""""""""""""""""""""""
"                     "
"   Initializations   "
"                     "
"""""""""""""""""""""""

" turn on deoplete
let g:deoplete#enable_at_startup = 1

"""""""""""""""""""""""""""""""""""""""""""""
"                                           "
"   Order Sensitive Plugin Configurations   "
"                                           "
"""""""""""""""""""""""""""""""""""""""""""""

" shorten command from :Scalpel to :S
let g:ScalpelCommand = 'S'

" don't override vim-dirvish's mapping of -
let g:NERDTreeHijackNetrw = 0

" use ctrl+l for ultisnips expansion and jumping, shift+tab jumping back
let g:UltiSnipsExpandTrigger = "<C-y>"
let g:UltiSnipsJumpForwardTrigger = "<C-y>"
let g:UltiSnipsJumpBackwardTrigger = "<S-Tab>"

" disable default easymotion mappings
let g:EasyMotion_do_mapping = 0

" disable default ferret mappings
let g:FerretMap = 0

" dont center results
let g:LoupeCenterResults=0

" prevent netrw from clobbering registers
let g:netrw_banner=1

""""""""""""""""
"              "
"   Mappings   "
"              "
""""""""""""""""

" settings pertaining to mappings actual mappings are stored in plugin/mappings/*

let mapleader="\<Space>"
let maplocalleader="\\"

""""""""""""""""
"              "
"   Settings   "
"              "
""""""""""""""""

" baseline vim/nvim settings, ft specific overrides reside in ftplugin/*

" configure file type detection and allow ft plugins
filetype plugin indent on

" turn on syntax highlighting
syntax on

set nocompatible                                   " disable compatability mode
set incsearch                                      " search as chars are entered
set hlsearch                                       " highlight search results
set ruler                                          " show the position
set history=100                                    " keep 100 lines of history
set enc=utf-8                                      " default to utf-8 encoding
set novisualbell                                   " stop beeps and alerts
set noerrorbells                                   " stop beeps and alerts
set t_vb=                                          " stop beeps and alerts
set nu                                             " turn on line number column
set rnu                                            " turn on relative line numbers
set shiftround                                     " always indent by multiple of shiftwidth
set splitbelow                                     " open new splits on the bottom
set ai                                             " auto indenting
set et                                             " expand tabs to spaces
set sts=2                                          " sets the soft tab stop
set ts=2                                           " tab stop to 4 spaces
set sw=2                                           " shift width, auto ind / shifting spaces
set shiftround                                     " always indent by multiple of shiftwidth
set cursorline                                     " highight line cursor is on
set list                                           " show special characters
set lcs=eol:¬,tab:>-,trail:.,extends:»,precedes:«  " special character labels
set ignorecase                                     " case insensitive searching
set smartcase                                      " except when there is an uc char in search
set scrolloff=5                                    " scroll before end of page
set shortmess+=I                                   " no intro text on plain vi start
set foldmethod=syntax                              " enable folding by syntax
set foldlevel=1                                    " fold second level and greater
set foldcolumn=2                                   " show the fold column
set laststatus=2                                   " enable statusline
set noshowmode                                     " dont show modes, statusline does it
set lazyredraw                                     " no redraw during macros etc
set backspace=2                                    " make bkspace work on line br & auto indent
set hidden                                         " allow buffer switching when unsaved
set confirm                                        " prompt to save modified hidden buffers
set completeopt=menu,preview                       " aka cot, preview needed for lsp lang help
set signcolumn=yes                                 " always show the sign column

" vim specific (not nvim)
if !has('nvim')
  set highlight+=N:DiffText                        " make current line number stand out a little
endif

" custom line break symbol
if has('linebreak')
  let &showbreak='»» '
  set breakindent
  if exists('&breakindentopt')
    set breakindentopt=shift:0
  endif
endif

" highlight when slopping over 80 columns
call matchadd('ColorColumn', '\%81v', 100)

"""""""""""""""
"             "
"   Folding   "
"             "
"""""""""""""""

" enable folding by file type (:help ??)
let g:markdown_folding=1                           " markdown
let g:tex_fold_enabled=1                           " tex
let g:javaScript_fold=1                            " javascript
let g:perl_fold=1                                  " perl
let g:perl_fold_blocks = 1                         " ??
let g:php_folding=1                                " php
let g:r_syntax_folding=1                           " r
let g:ruby_fold=1                                  " ruby
let g:sh_fold_enabled=7                            " sh
let g:vimsyn_folding='af'                          " vim script
let g:xml_syntax_folding=1                         " xml
let g:rust_fold=1                                  " rust

""""""""""""""""""""""""""
"                        "
"   Meta File Handling   "
"                        "
""""""""""""""""""""""""""

" don't create root owned files
if exists('$SUDO_USER')
  set noswapfile
  set nobackup
  set nowritebackup
  set noundofile
  set viminfo=
" else keep everything in vim/tmp
else
  set backupdir=~/.vim/tmp/backup
  set directory=~/.vim/tmp/swap
  if has('nvim')
    set viminfo+=n~/.vim/tmp/nviminfo
  else
    set viminfo+=n~/.vim/tmp/viminfo
  endif
  set viewdir=~/.vim/tmp/view
  set undodir=~/.vim/tmp/undo
  " set undofile
endif
