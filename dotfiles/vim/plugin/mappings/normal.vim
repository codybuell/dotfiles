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
"
" verbose nmap [key]

" toggle current and previous buffers
nnoremap                    <leader><leader>  <C-^>

" loupe mappings
nmap                        ,/                <Plug>(LoupeClearHighlight)

" command t mappings
nmap                        <Leader>t         <Plug>(CommandT)
nmap                        <Leader>b         <Plug>(CommandTBuffer)
nmap                        <Leader>j         <Plug>(CommandTJump)
nmap                        <leader>h         <Plug>(CommandTHelp)
nmap                        <leader>c         <Plug>(CommandTTag)
nnoremap  <silent>          <leader>.         :CommandT %:p:h<CR>
nnoremap  <silent>          <leader>n         :CommandT {{ NotesFolder }}<CR>

" cycle quickfix and location lists
nnoremap  <silent>          <leader>0         :<C-U>call buell#helpers#CycleLists()<CR>

" jump list navigation
nnoremap  <silent>          <Up>              <C-O>
nnoremap  <silent>          <Down>            <C-I>

" scalpen mappings
nmap                        <leader>s         <Plug>(Scalpel)

" ale mappings
nmap                        <Right>           <Plug>(ale_next_wrap)
nmap                        <Left>            <Plug>(ale_previous_wrap)

" autoload helper functions
nnoremap  <silent>          <C-u>             :<C-U>call buell#helpers#Underline()<CR>
nnoremap  <silent>          <leader>-         :<C-U>call buell#helpers#CycleSidebars()<CR>
nnoremap  <silent>          <leader>`         :<C-U>call buell#helpers#CycleViews()<CR>

" fastfold update folds
nmap                        zuz               <Plug>(FastFoldUpdate)

" easymotion convenience mappings
nmap                        <leader>f         <Plug>(easymotion-overwin-f)
nmap                        <leader>w         <Plug>(easymotion-overwin-w)

" fugitive handy git bindings
nnoremap                    <leader>gs        :Gstatus<CR>
nnoremap                    <leader>gb        :Gblame<CR>
nnoremap                    <leader>gp        :Gpush origin master<CR>
nnoremap                    <leader>ga        :Git add %:p<CR><CR>
nnoremap                    <leader>gc        :Gcommit -v -q<CR>
nnoremap                    <leader>gt        :Gcommit -v -q %:p<CR>
nnoremap                    <leader>gd        :Gvdiff<CR>
nnoremap                    <leader>ge        :Gedit<CR>
nnoremap                    <leader>gr        :Gread<CR>
nnoremap                    <leader>gw        :Gwrite<CR><CR>
nnoremap                    <leader>gl        :silent! Glog<CR>:bot copen<CR>
nnoremap                    <leader>gm        :Gmove<Space>
nnoremap                    <leader>go        :Git checkout<Space>

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

" re-run last macro
nnoremap                    <leader><enter>   @@

" toggle current fold
nnoremap                    <tab>             za

" redo buffer syntax
nnoremap  <silent>          <localleader>c    :syntax sync fromstart<CR>

" ack mappings
nmap                        <leader>aa        <Plug>(FerretAck)
nmap                        <leader>aw        <Plug>(FerretAckWord)
nmap                        <leader>as        <Plug>(FerretAcks)
nnoremap                    <leader>a.        :Ack  %:p:h<C-B><RIGHT><RIGHT><RIGHT><RIGHT>

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

" quick navigation to edit ultisnips
nnoremap                    <localleader>u    :UltiSnipsEdit<CR>

" generate random characters
nnoremap  <silent>          <localleader>r    :<C-U>call buell#helpers#RandomCharacters(v:count)<CR>
