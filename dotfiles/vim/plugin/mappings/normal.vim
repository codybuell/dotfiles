""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Normal Mode Mappings                                                         "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" overrides

" customizations
nnoremap          <enter>             @@
nnoremap          <tab>               za
nnoremap <silent> ,/                  :nohlsearch<CR>
nnoremap <silent> <leader>1           :set nowrap!<CR>
nnoremap <silent> <leader>q           :q<CR>
nnoremap <silent> <leader>w           :w<CR>
nnoremap <silent> <leader>z           :only<CR>
nnoremap <silent> <leader>c           :syntax sync fromstart<CR>

" nerdtree
nnoremap <silent> <leader>-           :NERDTreeToggle<CR>

" tagbar
nnoremap <silent> <leader>0           :TagbarToggle<CR>

" commandt
nnoremap <silent> <leader>t           :CommandT<CR>
nnoremap <silent> <leader>y           :CommandTBuffer<CR>
nnoremap <silent> <leader>T           :CommandTMRU<CR>
nnoremap <silent> <leader>Y           :CommandTTag<CR>
nnoremap <silent> <leader>j           :CommandTJump<CR>

" laravel
nnoremap          <leader>la          :!php artisan
nnoremap <silent> <leader>r           :!php artisan route:list<CR>
nnoremap <silent> <leader>lc          :tabnew composer.json<CR>
nnoremap <silent> <leader>lr          :tabnew app/Http/routes.php<CR>
nnoremap <silent> <leader>la          :tabnew config/app.php<CR>
nnoremap <silent> <leader>ld          :tabnew config/database.php<CR>

" markdown
nnoremap <silent> <leader>md          :%!markdown --html4tags<CR>
nnoremap <silent> <leader>mu          :%!markup<CR>

" quick navigation
nnoremap          <space><space>      <C-^>
nnoremap          <leader><leader>n   :CommandT ~/Google\ Drive/Notes/<CR>
nnoremap          <leader><leader>c   :CommandT app/Http/Controllers/<CR>
nnoremap          <leader><leader>r   :CommandT app/Http/Requests/<CR>
nnoremap          <leader><leader>m   :CommandT app/Models/<CR>
nnoremap          <leader><leader>v   :CommandT resources/views/<CR>
nnoremap          <leader><leader>s   :CommandT resources/assets/sass/<CR>
nnoremap          <leader><leader>j   :CommandT resources/assets/js/<CR>

" file shortcuts
nnoremap <silent> <leader>ev          :tabnew ~/.vimrc<CR>
nnoremap <silent> <leader>es          :tabnew ~/.vim/snippets/
nnoremap <silent> <leader>eu          :UltiSnipsEdit<CR>

" functions
nnoremap <silent> <leader>ra          :<C-U>call functions#RandomCharacters(v:count)<CR>
nnoremap <silent> <leader>9           :<C-U>call functions#ToggleErrors()<CR>
nnoremap <silent> <leader>u           :<C-U>call functions#Underline()<CR>
nnoremap <silent> <leader>`           :<C-U>call functions#NuListToggle()<CR>
nnoremap <silent> <leader>3           :call functions#ColorReference()<CR>
nnoremap <silent> <leader>4           :runtime syntax/hitest.vim<CR>
nnoremap <silent> <leader>8           :call functions#HighlightGroups()<CR>

" splits
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
