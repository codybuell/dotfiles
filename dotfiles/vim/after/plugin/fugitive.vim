""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Vim Fugitive Configurations                                                  "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Workflow
" 1. make code changes
" 2. show repo status:  <C-g>  /  :Gstatus
" 3. go to first file in list
"    |   |   |   |
"    |   |   |   `---- - add file on line:  -
"    |   |   |
"    |   |   `----- - show diff of file on line:  <S-d>  /  dv
"    |   |
"    |   `---- - patch add hunks:  p 
"    |         - repeat for desired files
"    |
"    - hit enter to open the file on the line
"    - (do the patch add for that file)
"      <space>gd  /  :Gvdiff
"    - find another file and repeat
" 7. commit (from within status):  cc
" 8. push:  <C-p>  /  :GPush origin my-branch-name
"
" <https://www.reddit.com/r/vim/comments/6kfyae/vimfugitive_workflow/>

" fugitive handy git bindings
nnoremap <C-G>     :Gstatus<CR>
nnoremap <C-P>     :Gpush origin master<CR>
nnoremap <space>ga :Git add %:p<CR><CR>
nnoremap <space>gs :Gstatus<CR>
nnoremap <space>gc :Gcommit -v -q<CR>
nnoremap <space>gt :Gcommit -v -q %:p<CR>
nnoremap <space>gd :Gvdiff<CR>
nnoremap <space>ge :Gedit<CR>
nnoremap <space>gr :Gread<CR>
nnoremap <space>gw :Gwrite<CR><CR>
nnoremap <space>gl :silent! Glog<CR>:bot copen<CR>
nnoremap <space>gp :Ggrep<Space>
nnoremap <space>gm :Gmove<Space>
nnoremap <space>gb :Git branch<Space>
nnoremap <space>go :Git checkout<Space>
nnoremap <space>gps :Dispatch! git push<CR>
nnoremap <space>gpl :Dispatch! git pull<CR>
