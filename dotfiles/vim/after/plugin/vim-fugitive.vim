""""""""""""""""""""
"                  "
"   Vim-Fugitive   "
"                  "
""""""""""""""""""""

" bail if vim-fugitive is not installed
if !buell#helpers#PluginExists('vim-fugitive')
  finish
endif

" General Workflow (use g? to show mappings in any fugitive split)
" 1. make code changes
" 2. show repo status:  ␣gs
" 3. craft commits via git status window:  ␣gs from any buffer
"    - use <C-n>, <C-p> to navigate next, previous files in list
"    - alternatively (, and ) will perform similar movement
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
" 2. navigate to merge conflict and place cursor somewhere within the markers
"    - ␣gh to select changes from left split, mnemonic Get left movement
"    - ␣gl to select changes from right split, mnemonic Get right movement
"
" Git Blame Workflow
" 1. show the git blame window: ␣gb
" 2. resize the blame window:
"    - A -> to author
"    - C -> to commit
"    - D -> to datetime
" 2. navigate lineage of commit under cursor
"    - o to open the commit details in a horizontal split
"    - - to reblame at commit under cursor (loads that commit and runs gblame)
"    - P to reblame at the parent of commit under cursor
" 3. close the gblame window: ␣gq
" 4. return to working tree version: ␣ge

" general buffer bindings
nnoremap  <silent>          <leader>gs        :Git<CR>:20wincmd_<CR>
nnoremap  <silent>          <leader>gb        :Git blame<CR>
nnoremap  <silent>          <leader>gp        :Git push<CR>
nnoremap  <silent>          <leader>gl        :silent! Gclog!<CR>:bot copen<CR>
nnoremap  <silent>          <leader>gd        :Gvdiffsplit!<CR>
nnoremap  <silent>          <leader>gh        :diffget //2<CR>
nnoremap  <silent>          <leader>gm        :diffget //3<CR>
nnoremap                    <leader>gc        :Git checkout<Space>
nnoremap                    <leader>gg        :Ggrep<Space>
nnoremap  <silent>          <leader>ge        :Gedit<CR>
"nnoremap  <silent>          <leader>gr        :Gread<CR>
"nnoremap  <silent>          <leader>gw        :Gwrite<CR><CR>Gdiffsplit!Gdiffsplit!

"au BufEnter gitcommit :17wincmd_<CR>
