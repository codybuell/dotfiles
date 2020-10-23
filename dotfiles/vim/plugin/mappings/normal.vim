" normal mode mappings
"
" {cmd} {attr} {lhs} {rhs}
"
" where
"
" {cmd}  is one of ':map', ':map!', ':nmap', ':vmap', ':imap',
"        ':cmap', ':smap', ':xmap', ':omap', ':lmap', etc.
" {attr} is optional and one or more of the following: <buffer>, <silent>,
"        <expr> <script>, <unique> and <special>.
"        More than one attribute can be specified to a map.
" {lhs}  left hand side, is a sequence of one or more keys that you will use
"        in your new shortcut.
" {rhs}  right hand side, is the sequence of keys that the {lhs} shortcut keys
"        will execute when entered.
"
" <C-O>  - enters normal mode for one command
" <C-R>= - insert the result of an expression at the cursor
" <C-B>  - go to the beginning of the command line
" <C-U>  - remove range / count after hitting :, but still available v:count / v:count1
"
" verbose nmap [key]

" toggle current and previous buffers
nnoremap                    <leader><leader>  <C-^>

" jump list navigation
"nnoremap  <silent>          <Left>            <C-O>
"nnoremap  <silent>          <Right>           <C-I>

" navigate quickfix (up/down: item in list, left/right: file in list)
nnoremap  <silent>          <Up>              :<C-U> call buell#helpers#ListNav('c', 'prev')<CR>
nnoremap  <silent>          <Down>            :<C-U> call buell#helpers#ListNav('c', 'next')<CR>
nnoremap  <silent>          <Left>            :cpfile<CR>
nnoremap  <silent>          <Right>           :cnfile<CR>

" navigate jumplist (up/down: item in list, left/right: file in list)
nnoremap  <silent>          <S-Up>            :<C-U> call buell#helpers#ListNav('l', 'prev')<CR>
nnoremap  <silent>          <S-Down>          :<C-U> call buell#helpers#ListNav('l', 'next')<CR>
nnoremap  <silent>          <S-Left>          :lpfile<CR>
nnoremap  <silent>          <S-Right>         :lnfile<CR>

" autoload helper functions
nnoremap  <silent>          <C-u>             :<C-U>call buell#helpers#Underline()<CR>
nnoremap  <silent>          <leader>-         :<C-U>call buell#helpers#CycleSidebars()<CR>
nnoremap  <silent>          <leader>`         :<C-U>call buell#helpers#CycleViews()<CR>
nnoremap  <silent>          <leader>0         :<C-U>call buell#helpers#CycleLists()<CR>
nnoremap  <silent>          <leader>1         :<C-U>call buell#helpers#ToggleSyntaxHL()<CR>
nnoremap  <silent>          <leader>2         :<C-U>call buell#helpers#SyncSplit()<CR>
nnoremap  <silent>          <leader>3         :<C-U>call buell#helpers#ToggleSpecialChars()<CR>
nnoremap  <silent>          <leader>4         :<C-U>call buell#helpers#HighlightGroups()<CR>
nnoremap  <silent>          <leader>5         :so $VIMRUNTIME/syntax/hitest.vim<CR>

" movement between splits
nmap                        <C-h>             <C-w>h
nmap                        <C-j>             <C-w>j
nmap                        <C-k>             <C-w>k
nmap                        <C-l>             <C-w>l

" creation of splits
nnoremap  <silent>          <localleader>v    :vsplit<CR>
nnoremap  <silent>          <localleader>h    :split<CR>

" improved copy & paste
nnoremap  <silent>          p                 p`]

" search for non-ascii characters
nnoremap  <silent>          ,,                /[^\x00-\x7F]<CR>

" re-run last macro
nnoremap                    <leader><enter>   @@

" toggle current fold
nnoremap                    <tab>             za

" zap white space
nnoremap  <silent>          <localleader>z    :<C-U>call buell#helpers#ZapWhitespace()<CR>

" redo buffer syntax
nnoremap  <silent>          <localleader>c    :syntax sync fromstart<CR>

" laravel helpers
" laravel (artisan -V | sed 's/[^[:digit:].]//g')
" 5.3 and greater /routes/web.php
" 5.0 - 5.2 /app/Http/routes.php
" 3.0 /application/routes.php
if filereadable("routes/web.php")
  nnoremap <silent>         <leader>lr        :tabnew routes/web.php<CR>
elseif filereadable("app/Http/routes.php")
  nnoremap <silent>         <leader>lr        :tabnew app/Http/routes.php<CR>
else
  nnoremap <silent>         <leader>lr        :tabnew application/routes.php<CR>
endif

nnoremap                    <leader>la        :!php artisan
nnoremap  <silent>          <leader>ll        :!php artisan route:list<CR>
nnoremap  <silent>          <leader>le        :tabnew .env<CR>
nnoremap  <silent>          <leader>lw        :tabnew webpack.mix.js<CR>

" quick navigation to journals
nnoremap  <silent>          <localleader>w    :<C-U>call buell#helpers#OpenJournal('work')<CR>
nnoremap  <silent>          <localleader>p    :<C-U>call buell#helpers#OpenJournal('personal')<CR>

" generate random characters
nnoremap  <silent>          <localleader>r    :<C-U>call buell#helpers#RandomCharacters(v:count)<CR>
