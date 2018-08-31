""""""""""""""""""""
"                  "
"   Vim-Fugitive   "
"                  "
""""""""""""""""""""

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
