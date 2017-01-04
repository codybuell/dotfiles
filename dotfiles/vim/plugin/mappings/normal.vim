""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Normal Mode Mappings                                                         "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" colemak hjkl workaround
"COLEMAKnoremap  h                            k
"COLEMAKnoremap  j                            h
"COLEMAKnoremap  k                            j

"COLEMAKnoremap  <C-w>h                       <C-w>k
"COLEMAKnoremap  <C-w>j                       <C-w>h
"COLEMAKnoremap  <C-w>k                       <C-w>j
"COLEMAKnoremap  <C-w>H                       <C-w>K
"COLEMAKnoremap  <C-w>J                       <C-w>H
"COLEMAKnoremap  <C-w>K                       <C-w>J

" overrides
nnoremap <silent> <Up>                :<C-u>exe 'call functions#LocationListNav("prev")'<CR>
nnoremap <silent> <Down>              :<C-u>exe 'call functions#LocationListNav("next")'<CR>
nnoremap <silent> <Left>              <C-O>
nnoremap <silent> <Right>             <C-I>

" improved copy & paste
nnoremap <silent> p                   p`]

" customizations
nnoremap          <enter>             @@
nnoremap          <tab>               za
nnoremap <silent> ,/                  :nohlsearch<CR>
nnoremap <silent> <leader>1           :set nowrap!<CR>
nnoremap <silent> <leader>q           :q<CR>
nnoremap <silent> <leader>w           :w<CR>
nnoremap <silent> <leader>z           :only<CR>
nnoremap <silent> <localleader>c      :syntax sync fromstart<CR>

" comceal
nnoremap <silent> <leader>2           :Comceal<CR>

" nerdtree
nnoremap <silent> <leader>-           :NERDTreeToggle<CR>

" tagbar
nnoremap <silent> <leader>0           :TagbarToggle<CR>

" commandt
nnoremap <silent> <leader>t           :CommandT<CR>
nnoremap <silent> <leader>.           :CommandT %:p:h<CR>
nnoremap <silent> <leader>y           :CommandTBuffer<CR>
nnoremap <silent> <leader>T           :CommandTMRU<CR>
nnoremap <silent> <leader>Y           :CommandTTag<CR>
nnoremap <silent> <leader>j           :CommandTJump<CR>
nnoremap <silent> <leader>h           :CommandTHelp<CR>

" laravel
nnoremap          <leader>la          :!php artisan
nnoremap <silent> <leader>lr          :!php artisan route:list<CR>
nnoremap <silent> <leader>lc          :tabnew composer.json<CR>
nnoremap <silent> <leader>er          :tabnew app/Http/routes.php<CR>
nnoremap <silent> <leader>ec          :tabnew config/app.php<CR>
nnoremap <silent> <leader>ed          :tabnew config/database.php<CR>

" file shortcuts
nnoremap <silent> <leader>ev          :tabnew ~/.vimrc<CR>
nnoremap <silent> <leader>es          :tabnew ~/.vim/snippets/
nnoremap <silent> <leader>eu          :UltiSnipsEdit<CR>

" quick navigation
nnoremap          <leader><leader>    <C-^>
nnoremap          <leader>n           :CommandT {{ NotesFolder }}<CR>
nnoremap          <leader>m           :CommandT app/Models/<CR>
nnoremap          <leader>v           :CommandT resources/views/<CR>
nnoremap          <leader>c           :CommandT app/Http/Controllers/<CR>
nnoremap          <leader>st          :CommandT resources/assets/sass/<CR>
nnoremap          <leader>sc          :CommandT resources/assets/js/<CR>

" functions
nnoremap <silent> <C-u>               :<C-U>call functions#Underline()<CR>
nnoremap <silent> <leader>r           :<C-U>call functions#RandomCharacters(v:count)<CR>
nnoremap <silent> <leader>`           :<C-U>call functions#NuListToggle()<CR>
nnoremap <silent> <leader>3           :call functions#ToggleSyntaxHL()<CR>
nnoremap <silent> <leader>6           :runtime syntax/hitest.vim<CR>
nnoremap <silent> <leader>7           :call functions#ColorReference()<CR>
nnoremap <silent> <leader>8           :call functions#HighlightGroups()<CR>
nnoremap <silent> <leader>9           :<C-U>call functions#ToggleErrors()<CR>

" splits
nnoremap <silent> <leader>sp          :<C-U>call functions#SyncSplit()<CR>
nmap <C-]>                            :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
nmap <C-h>                            <C-w>h
nmap <C-j>                            <C-w>j
nmap <C-k>                            <C-w>k
nmap <C-l>                            <C-w>l
nmap <A-j>                            :resize +5<cr>
nmap <A-l>                            :vertical resize +5<cr>
nmap <A-k>                            <c-w>=
nmap ∆                                :resize +5<cr>
nmap ¬                                :vertical resize +5<cr>
nmap ˚                                <c-w>=
