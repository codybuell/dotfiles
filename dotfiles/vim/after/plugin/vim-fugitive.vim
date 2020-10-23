""""""""""""""""""""
"                  "
"   Vim-Fugitive   "
"                  "
""""""""""""""""""""

" bail if vim-fugitive is not installed
if !buell#helpers#PluginExists('vim-fugitive')
  finish
endif

" General Workflow
" 1. make code changes
" 2. show repo status:  ␣gs
" 3. craft commits via git status window:  ␣gs from any buffer
"    - use <C-n>, <C-p> to navigate next, previous files in list
"    - use s, u, - to stage, unstage or toggle stage/unstage 
"    - use > or < to expand and show diffs of file under cursor
"      - visual select changes then use s, u, - to craft patches
"    - dv to open up a 'Diff Vertical' of the file under the cursor
"    - p to open an interactive patch session with file under cursor
"    - enter to open the file under the cursor       
" 4. craft commits via vimdiff:  ␣gd from buffer you want to commit
"    - dp (diff put) / do (diff obtain) to move hunks between windows
"      note: index is on left and working copy is on right
"    - visual select to customize hunks, :diffg, or :.diffg from normal mode
"    - :diffupdate / :diffu to recaulculate the diffs if needed
"    - ]c / [c jump to next or previous hunk / change
" 5. commit (from within Gstatus):  cc
" 6. close window (from within Gstatus):  gq
" 7. push:  ␣gp  /  :GPush <remote> <branch>
"
" Merge Conflict Workflow
" 1. show three way diff for current buffer:  ␣gD
" 2. //2 //3????

" general buffer bindings
nnoremap  <silent>          <leader>gs        :Git<CR>:20wincmd_<CR>
nnoremap  <silent>          <leader>gb        :Git blame<CR>
nnoremap  <silent>          <leader>gp        :Git push<CR>
nnoremap  <silent>          <leader>gd        :Gvdiffsplit<CR>
nnoremap  <silent>          <leader>gD        :Gvdiffsplit!<CR>
nnoremap  <silent>          <leader>gl        :silent! Gclog!<CR>:bot copen<CR>
nnoremap                    <leader>gc        :Git checkout<Space>
nnoremap                    <leader>gg        :Ggrep<Space>
"nnoremap  <silent>          <leader>ge        :Gedit<CR>
"nnoremap  <silent>          <leader>gr        :Gread<CR>
"nnoremap  <silent>          <leader>gw        :Gwrite<CR><CR>Gdiffsplit!Gdiffsplit!

"au BufEnter gitcommit :17wincmd_<CR>
