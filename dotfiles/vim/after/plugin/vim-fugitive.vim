""""""""""""""""""""
"                  "
"   Vim-Fugitive   "
"                  "
""""""""""""""""""""

" bail if vim-fugitive is not installed
if !buell#helpers#PluginExists('vim-fugitive')
  finish
endif

" mappings are defined in plugin/mappings/normal.vim

" Workflow
" 1. make code changes
" 2. show repo status:  <-g>  /  :Gstatus
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
" 8. push:  <space>gp  /  :GPush origin my-branch-name
"
" <https://www.reddit.com/r/vim/comments/6kfyae/vimfugitive_workflow/>

" fugitive handy git bindings (in fugitive split, - to stage/unstage, c to commit)
nnoremap                    <leader>gs        :Gstatus<CR>
nnoremap                    <leader>gb        :Gblame<CR>
nnoremap                    <leader>gp        :Gpush origin master<CR>
nnoremap                    <leader>ga        :Git add %:p<CR><CR>
nnoremap                    <leader>gc        :Gcommit -v -q<CR>
nnoremap                    <leader>gt        :Gcommit -v -q %:p<CR>
nnoremap                    <leader>gd        :Gvdiff<CR>
nnoremap                    <leader>ge        :Gedit<CR>
" nnoremap                    <leader>gr        :Gread<CR>
nnoremap                    <leader>gw        :Gwrite<CR><CR>
nnoremap                    <leader>gl        :silent! Glog<CR>:bot copen<CR>
nnoremap                    <leader>gm        :Gmove<Space>
nnoremap                    <leader>go        :Git checkout<Space>
