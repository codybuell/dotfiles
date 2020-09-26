""""""""""""""""""""
"                  "
"   Vim-Fugitive   "
"                  "
""""""""""""""""""""

" bail if vim-fugitive is not installed
if !buell#helpers#PluginExists('vim-fugitive')
  finish
endif

" Workflow
" 1. make code changes
" 2. show repo status:  ␣gs  /  :Gstatus
" 3. navigate files in list:  <C-n> / <C-p>
"    |   |   |   |   |
"    |   |   |   |   `---- - > or < to show inline diffs of file
"    |   |   |   |         - use s, u, - to stage, unstage, toggle hunks
"    |   |   |   |         - visual select to be more specific then s,u, -
"    |   |   |   |
"    |   |   |   `---- - toggle adding file or hunk on line:  -
"    |   |   |
"    |   |   `----- - show diff of file on line:  <S-d>  /  dv
"    |   |
"    |   `---- - interactive patch add hunks:  p 
"    |         - repeat for desired files
"    |
"    `---- - hit enter to open the file on the line
"
" 4. craft commits via vimdiff
"    - open the diff: ␣gd  /  :Gvdiff
"    - dp (diff put) / do (diff obtain) to move hunks between index (on left)
"      and working copy (on right)
"    - visual select to customize hunks, :diffg, or :.diffg from normal mode
"    - :diffupdate / :diffu to recaulculate the diffs if needed
"    - ]c / [c jump to next or previous hunk / change
"    - find another file and repeat
" 5. commit (from within Gstatus):  cc
" 6. close window (from within Gstatus):  ␣q
" 7. push:  <space>gp  /  :GPush origin my-branch-name
"
" <https://www.reddit.com/r/vim/comments/6kfyae/vimfugitive_workflow/>

" fugitive handy git bindings (in fugitive split, - to stage/unstage, cc to commit)
nnoremap  <silent>          <leader>gs        :Gstatus<CR>:20wincmd_<CR>
nnoremap  <silent>          <leader>gb        :Gblame<CR>
nnoremap  <silent>          <leader>gp        :Gpush<CR>
nnoremap  <silent>          <leader>ga        :Git add %:p<CR><CR>
nnoremap  <silent>          <leader>gc        :Gcommit -v -q<CR>
nnoremap  <silent>          <leader>gt        :Gcommit -v -q %:p<CR>
nnoremap  <silent>          <leader>gd        :Gvdiff<CR>
nnoremap  <silent>          <leader>ge        :Gedit<CR>
nnoremap  <silent>          <leader>gr        :Gread<CR>
nnoremap  <silent>          <leader>gw        :Gwrite<CR><CR>
nnoremap  <silent>          <leader>gl        :silent! Glog<CR>:bot copen<CR>
nnoremap                    <leader>gm        :Gmove<Space>
nnoremap                    <leader>go        :Git checkout<Space>
nnoremap                    <leader>gg        :Ggrep<Space>
