""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
"   Configurations for Vim & Neovim                                            "
"                                                                              "
"   Debugging:                                                                 "
"                                                                              "
"     NVIM_PYTHON_LOG_FILE=nvim.log NVIM_NCM_LOG_LEVEL=DEBUG nvim              "
"                                                                              "
"   Mappings:                                                                  "
"                                                                              "
"     Stick to default mappings as much as possible in order to stay           "
"     effecient on other systems that don't have these configurations.         "
"                                                                              "
"     leader       ␣ (spacebar)                                                "
"     localleader  \                                                           "
"                                                                              "
"     normal mode                                                              "
"     -----------                                                              "
"                                                                              "
"             (      `1234567890 =abcdef hijklmnopqrstuvwxyz[];     )          "
"         ␣ + ( ↹←→↓↑ 1234567890 =   d    i k m opq    v xyz[];, /↵ )          "
"         \ + ( ↹←→↓↑`1234567890-=ab defghijklmno q st v xyz[];,./↵ )          "
"         C + ( ↹←→↓↑`1234567890-=abcdefg i   mnopqrstuvwxyz[];,./↵ )          "
"         S + ( ↹    `1234567890-=abcdefghijklmnopqrstuvwxyz[];,./↵ )          "
"                                                                              "
"                                                     command-t:               "
"     -  netrw                ␣` cycle views          ␣t start at (n)vim cwd   "
"     ,/ clear hl search      ␣1                      ␣. start at buffer dir   "
"     ←  ale prev             ␣2                      ␣b list buffers          "
"     →  ale next             ␣3                      ␣j list jump list        "
"     ↑  jump list nav        ␣4                      ␣h (n)vim help docs      "
"     ↓  jump list nav        ␣5                      ␣c ctags                 "
"     ␣␣ toggle buffers       ␣6                      ␣n notes                 "
"     ␣u underline text       ␣7                                               "
"     ␣m easymotion           ␣8                      ferret:                  "
"     ␣↵ re-run last macro    ␣9                      ␣a ack (quickfix list)   "
"     ↹  toggle fold          ␣0                      ␣s ack current word      "
"                             ␣- cycle sidebars       ␣r search & replace      "
"                             ␣=                                               "
"                             ␣␣                      scalpel:                 "
"                                                     ␣e change word @ cursor  "
"                                                                              "
"                                                     fugitive (git...):       "
"                             easymotion:             ␣gs status               "
"                             ␣f find a char & move   ␣gb blame                "
"     \c redo buffer syntax   ␣w move to word         ␣gp push orig mstr       "
"     \r gen random chars                             ␣ga add %:p              "
"     \w open work journal    fastfold:               ␣gc commit -v -q         "
"     \p open personal jrnl   zuz update folds        ␣gt commit -v -q %:p     "
"     \u edit ft's snippets                           ␣gd vdiff                "
"     \v vertical split       splitjoin:              ␣ge edit                 "
"     \h horizontal split     gS split oneliner       ␣gr read                 "
"                             gJ join multiliner      ␣gw write                "
"                                                     ␣gl log for cur file     "
"                             laravel:                ␣gm move                 "
"                             ␣lr edit routes.php     ␣go checkout             "
"    <C-h> split motion       ␣la laravel artisan:                             "
"    <C-j> split motion       ␣ll list routes         commentary:              "
"    <C-k> split motion       ␣le edit .env           gcc comment out block    "
"    <C-l> split motion       ␣lw edit webpack        gt  use with motion      "
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
"   Plugins:                                                                   "
"                                                                              "
"     vim-plug      plugin manager that allows direct cloning of repositories  "
"                   by modifying the runtimepath to inclede each bundle dir    "
"                                                                              "
"     deoplete      asynchronous completion utility                            "
"                                                                              "
"     deoplete-go   deoplete completion source for go language                 "
"                                                                              "
"     neco-syntax   deoplete completion source for various syntaxes            "
"                                                                              "
"     neco-vim      deoplete completion source for viml                        "
"                                                                              "
"     vim-go        improved go language support                               "
"                                                                              "
"     ale           asynchronous linting engine                                "
"                                                                              "
"     vinegar       netrw mapped to -, and - to navigate up to parent folder   "
"                                                                              "
"     command-t     fuzzy search file navigatio                                "
"                                                                              "
"     terminus      improved terminal and tmux integration                     "
"                                                                              "
"     loupe         improved search configurations                             "
"                                                                              "
"     ferret        multi-file search and search/replace                       "
"                                                                              "
"     scalpel       improved in file word replacement                          "
"                                                                              "
"     base16-vim    base16 color themes                                        "
"                                                                              "
"     nerdtree      tree-based file browser                                    "
"                                                                              "
"     tagbar        ctags of currently open buffer ordered by scope            "
"                                                                              "
"     ultisnips     snippet utility                                            "
"                                                                              "
"     markdown      improved support and wiki like features for markdown       "
"                                                                              "
"     goyo          writing room stylings for focused work                     "
"                                                                              "
"     limelight     darken all text but current paragraph for improved focus   "
"                                                                              "
"     repeat        add ability to repeat non atomic functions                 "
"                                                                              "
"     surround      ability to change surrounding enclosures                   "
"                                                                              "
"     fugitive      git integration to vim                                     "
"                                                                              "
"     speeddating   ctrl-a ctrl-x to also increment decrement dates            "
"                                                                              "
"     commentary    comment out blocks of text, add comment w motions          "
"                                                                              "
"     easymotion    improved movement around files                             "
"                                                                              "
"     hardtime      stop repeating basic movement keys                         "
"                                                                              "
"     fastfold      speed up folding by folding only when needed               "
"                                                                              "
"     splitjoin     toggle code between single and multi-line formats          "
"                                                                              "
"     expand-region grow or shrink visual selections                           "
"                                                                              "
"     pinnacle      highlight group manipulations                              "
"                                                                              "
"     emoji         deoplete completion source for emoji's                     "
"                                                                              "
"     vim-marked    open markdown documents in Marked2                         "
"                                                                              "
"     * settings in plugin/vim-plug.vim                                        "
"                                                                              "
"     (snippets)                                                               "
"     (syntax checker)                                                         "
"     (colors)                                                                 "
"                                                                              "
"   Tips:                                                                      "
"                                                                              "
"     execution    1. this file    ~/.vim/init.vim                             "
"                  2. plugin code  ~/.vim/plugin/*.vim                         "
"                  3. bundle code  ~/.vim/bundle/*/plugin/*.vim                "
"                  4. after/*      ~/.vim/after/*                              "
"                  * multiple matches are ordered alphabetically               "
"                                                                              "
"     structure    ~/.vim/after        loaded last, overriding other settings  "
"                  ~/.vim/autoload     functions loaded dynamically as needed  "
"                  ~/.vim/bundles      third party plugins, mngd by vim-plug   "
"                  ~/.vim/colors       color schemes                           "
"                  ~/.vim/ftdetect     file type identification modifications  "
"                  ~/.vim/ftplugin     plugins loaded on specific file types   "
"                  ~/.vim/plugin       configurations                          "
"                  ~/.vim/syntax       syntax definitions for file types       "
"                  ~/.vim/tmp          swap view and other temporary files     "
"                                                                              "
"     commands     :scriptnames        all scripts in order of evaluation      "
"                  :checkhealth        test for missing providers etc...       "
"                  : set runtimepath?  show all sourced dirs in order of op    "
"                                                                              "
"                                                                              "
"     profile application launch:                                              "
"       `vim --startuptime vim.log`                                            "
"                                                                              "
"     see all leader mappings:                                                 "
"       `vim -c 'set t_te=' -c 'set t_ti=' -c 'map <space> -c q | sort`        "
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

" make sure everything is using the right pythons
"let g:python_host_prog = '/usr/local/bin/python'
"let g:python3_host_prog = '/usr/local/bin/python3'

"""""""""""""""
"             "
"   Plugins   "
"             "
"""""""""""""""

" define helper to prevent :PlugClean from removing plugins used by another
" variant of vi / vim / nvim since all use the same configuration here
" usage: Plug 'benekastah/neomake', Cond(has('nvim'))
"        Plug 'benekastah/neomake', Cond(has('nvim'), { 'on': 'Neomake' })
function! Cond(cond, ...)
  let opts = get(a:000, 0, {})
  return a:cond ? opts : extend(opts, { 'on': [], 'for': [] })
endfunction

" define / initialize plugins, this needs to reside here and be sourced first
call plug#begin('~/.vim/bundles')

" vim-plug: this plugin manager (adding here for doc support)
Plug 'junegunn/vim-plug'

" deoplete: asynchronous completion utility
if has('nvim')
  Plug 'Shougo/deoplete.nvim', {
  \   'do': ':UpdateRemotePlugins'
  \ }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

" deoplete-go: deoplete completion source for go (deps in scripts/go.sh)
Plug 'zchee/deoplete-go', {
\   'do': 'make'
\ }

" neco-syntax: deoplete completion source for various syntaxes
Plug 'Shougo/neco-syntax'

" neco-vim: deoplete completion source for viml
Plug 'Shougo/neco-vim'

" vim-go: improved go language support (occasionally run :GoUpdateBinaries)
Plug 'fatih/vim-go', {
\   'do': ':GoInstallBinaries'
\ }

" command-t: fuzzyfinding file and buffer navigation
Plug 'wincent/command-t', {
\   'do': 'cd ruby/command-t/ext/command-t && ruby extconf.rb && make'
\ }

" terminus: improved terminal and tmux integration
Plug 'wincent/terminus'

" loupe: improved search configruations
Plug 'wincent/loupe'

" ferret: multi-file search and search/replace
Plug 'wincent/ferret'

" scalpel: improved in file word replacement
Plug 'wincent/scalpel'

" ale: asynchronous file syntax linting
Plug 'w0rp/ale'

" vim vinegar: netrw improvements
Plug 'tpope/vim-vinegar'

" base16-vim: base16 color themes
Plug 'chriskempson/base16-vim'

" nerdtree: tree-based file browser
Plug 'scrooloose/nerdtree'

" tagbar: ctags of currently open buffer ordered by scope
Plug 'majutsushi/tagbar'

" ultisnips: snippet utility
Plug 'SirVer/ultisnips'

" vim-markdown: improved support and wiki like features for markdown
Plug 'plasticboy/vim-markdown'

" goyo: writing room stylings for focused work
Plug 'junegunn/goyo.vim'

" limelight: darken all text but current paragraph for improved focus
Plug 'junegunn/limelight.vim'

" vim-repeat: add ability to repeat non atomic functions
Plug 'tpope/vim-repeat'

" vim-surround: ability to change surrounding enclosures
Plug 'tpope/vim-surround'

" vim-fugitive: git integration to vim
Plug 'tpope/vim-fugitive'

" vim-speeddating: ctrl-a ctrl-x to also increment decrement dates
Plug 'tpope/vim-speeddating'

" vim-commentary: comment out blocks of text, add comment w motions
Plug 'tpope/vim-commentary'

" easymotion: improved movement around files
Plug 'easymotion/vim-easymotion'

" vim-hardtime: stop repeating basic movement keys
Plug 'takac/vim-hardtime'

" fastfold: speed up folding on large documents, fold only when needed
Plug 'Konfekt/FastFold'

" splitjoin: toggle code between single and multi-line formats
Plug 'AndrewRadev/splitjoin.vim'

" vim-expand-region: grow or shrink visual selections
Plug 'terryma/vim-expand-region'

" pinnacle: highlight group manipulations
Plug 'codybuell/pinnacle'

" deoplete-emoji: deoplete completion source for emoji's
Plug 'fszymanski/deoplete-emoji'

" vim-marked: open markdown documents in Marked2
Plug 'itspriddle/vim-marked'

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""
"                                           "
"   Order Sensitive Plugin Configurations   "
"                                           "
"""""""""""""""""""""""""""""""""""""""""""""

" shorten command from :Scalpel to :S
let g:ScalpelCommand = 'S'

" don't override vim-vinegar's mapping of -
let g:NERDTreeHijackNetrw = 0

" ultisnips expansion and jumping, we'll handle tab mapping with an
" autocommand in after/plugin/deoplete.vim
let g:UltiSnipsExpandTrigger = "<C-l>"
let g:UltiSnipsJumpForwardTrigger = "<C-j>"
let g:UltiSnipsJumpBackwardTrigger = "<C-k>"

" disable default easymotion mappings
let g:EasyMotion_do_mapping = 0

" disable default ferret mappings
let g:FerretMap = 0

" dont center results
let g:LoupeCenterResults=0

"""""""""""""""""""""""
"                     "
"   Initializations   "
"                     "
"""""""""""""""""""""""

" turn on deoplete
call buell#autocomplete#deoplete_init()

" turn on the hardtimes
let g:hardtime_default_on = 0

""""""""""""""""
"              "
"   Mappings   "
"              "
""""""""""""""""

" actual mappings are stored in plugin/mappings/*
" this section just contains settings pertaining to mappings

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
