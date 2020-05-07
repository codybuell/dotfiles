""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
"   Configurations for Vim & Neovim                                            "
"                                                                              "
"   Mappings:                                                                  "
"                                                                              "
"     Goal is to stick to default mappings as much as possible in order to     "
"     stay effecient on other systems that don't have these configurations.    "
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
"                                                     command-t:               "
"     -  netrw                ␣` cycle views          ␣t start at (n)vim cwd   "
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
"                             ␣␣                                               "
"                             ␣␣                      scalpel:                 "
"                                                     ␣s change word @ cursor  "
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
"                                                                              "
"   Lists:                                                                     "
"                                                                              "
"   QUICKFIX (global to one session)                                           "
"     - ack results from ferret                                                "
"                                                                              "
"   LOCATION LIST (local to current tab or window within a tab)                "
"                                                                              "
"                                                                              "
"     * difference relevant when running splits, vim windows are tmux panes    "
"       equivalents, note however that tabs are collections of windows, so     "
"       a tab is treated as a different window                                 "
"                                                                              "
"                                                                              "
"   Plugins:                                                                   "
"                                                                              "
"   COMPLETION                                                                 "
"     ultisnips         snippet utility                                        "
"     deoplete          asynchronous completion utility                        "
"     deoplete-go       deoplete completion source for go language             "
"     neco-vim          deoplete completion source for viml                    "
"     neco-syntax       deoplete completion source for various syntaxes        "
"     emoji             deoplete completion source for emoji's                 "
"     deoplete-vim-lsp  deoplete completion source for vim-lsp                 "
"                                                                              "
"                                                                              "
"   IDE (linting & heavier syntax / language plugins)                          "
"     vim-go            improved go language support                           "
"     tagbar            ctags of open buffer ordered by scope                  "
"     vim-lsp           language server support, req async.vim                 "
"   X ale               asynchronous linting engine                            "
"                                                                              "
"                                                                              "
"   NAVIGATION                                                                 "
"     vinegar           netrw mapped to -, and - to navigate up folders        "
"     nerdtree          tree-based file browser                                "
"     command-t         fuzzy search file navigatio                            "
"     loupe             improved search configurations                         "
"     easymotion        improved movement around files                         "
"                                                                              "
"                                                                              "
"   SYNTAX & LIGIBILITY                                                        "
"     pinnacle          highlight group manipulations                          "
"     base16-vim        base16 color themes                                    "
"     jsonc.vim         syntax support for cjson / jsonc                       "
"     markdown          improved support & wiki like features for markdown     "
"     typescript        typscript support for vim                              "
"     scss-syntax       fixes slow load times with native nvim sass syntax     "
"     vim-vue           syntax highlighting for vue components                 "
"     vim-blade         blade syntax highlighting                              "
"                                                                              "
"                                                                              "
"   EDITING                                                                    "
"     scalpel           improved in file word replacement                      "
"     surround          ability to change surrounding enclosures               "
"     speeddating       ctrl-a ctrl-x to also increment decrement dates        "
"     repeat            add ability to repeat non atomic functions             "
"     commentary        comment out blocks of text, add comment w motions      "
"     vim-camelsnek     case conversion util                                   "
"     ferret            multi-file search and search/replace                   "
"     expand-region     grow or shrink visual selections                       "
"     splitjoin         toggle code between single and multi-line formats      "
"                                                                              "
"                                                                              "
"   INTEGRATIONS                                                               "
"     terminus         improved terminal and tmux integration                  "
"     fugitive         git integration to vim                                  "
"     vim-marked       open markdown documents in Marked2                      "
"                                                                              "
"                                                                              "
"   MISCELLANEOUS                                                              "
"     vim-plug          plugin manager that allows direct cloning of           "
"                       repositories by modifying the runtimepath to           "
"                       inclede each bundle dir                                "
"     hardtime          stop repeating basic movement keys                     "
"     howmuch           perform math operations on visual selections           "
"     goyo              writing room stylings for focused work                 "
"     limelight         darken all text but current paragraph, focus mode      "
"     fastfold          speed up folding by folding only when needed           "
"     vim-vis           improved visual mode functionality                     "
"     vim-obsession     improved session management                            "
"     async.vim         job normalization btw vim8 & neovem                    "
"                                                                              "
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
"   Debugging:                                                                 "
"                                                                              "
"     NVIM_PYTHON_LOG_FILE=nvim.log NVIM_NCM_LOG_LEVEL=DEBUG nvim              "
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

if has('nvim')
  Plug 'Shougo/deoplete.nvim', {
  \   'do': ':UpdateRemotePlugins'
  \ }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

Plug 'zchee/deoplete-go', {
\   'do': 'make'
\ }

Plug 'fatih/vim-go', {
\   'do': ':GoInstallBinaries'
\ }

Plug 'wincent/command-t', {
\   'do': 'cd ruby/command-t/ext/command-t && ruby extconf.rb && make'
\ }

Plug 'junegunn/vim-plug'              " adding here for doc support
Plug 'Shougo/neco-syntax'
Plug 'Shougo/neco-vim'
Plug 'wincent/terminus'
Plug 'wincent/loupe'
Plug 'wincent/ferret'
Plug 'wincent/scalpel'
Plug 'tpope/vim-vinegar'
Plug 'chriskempson/base16-vim'
Plug 'scrooloose/nerdtree'
Plug 'majutsushi/tagbar'
Plug 'SirVer/ultisnips'
Plug 'plasticboy/vim-markdown'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-commentary'
Plug 'easymotion/vim-easymotion'
Plug 'takac/vim-hardtime'
Plug 'Konfekt/FastFold'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'terryma/vim-expand-region'
Plug 'codybuell/pinnacle'
Plug 'fszymanski/deoplete-emoji'
Plug 'itspriddle/vim-marked'
Plug 'jwalton512/vim-blade'
Plug 'posva/vim-vue'
Plug 'leafgarland/typescript-vim'
Plug 'codybuell/HowMuch'
Plug 'codybuell/vis'
Plug 'tpope/vim-obsession'
Plug 'cakebaker/scss-syntax.vim'
Plug 'nicwest/vim-camelsnek'
Plug 'neoclide/jsonc.vim'
Plug 'prabirshrestha/async.vim'
Plug 'codybuell/vim-lsp'
Plug 'lighttiger2505/deoplete-vim-lsp'

" Plug 'thomasfaingnaert/vim-lsp-snippets'
" Plug 'thomasfaingnaert/vim-lsp-ultisnips'
" Plug 'w0rp/ale'

" keep plug calls above this line
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

" use ctrl+l for ultisnips expansion and jumping, shift+tab jumping back
let g:UltiSnipsExpandTrigger = "<C-l>"
let g:UltiSnipsJumpForwardTrigger = "<C-l>"
let g:UltiSnipsJumpBackwardTrigger = "<S-Tab>"

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
