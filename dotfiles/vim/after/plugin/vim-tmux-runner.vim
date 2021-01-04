"""""""""""""""""""""""
"                     "
"   vim-tmux-runner   "
"                     "
"""""""""""""""""""""""

" note that the runner and vim panes need to be run from the same path else
" VtrSendFile will try to execute from a bad path.

" bail if vim-obsession is not installed
if !buell#helpers#PluginExists('vim-tmux-runner')
  finish
endif

" for languages with syntactic whitespace, appends new line to lines sent
" needed for closing out contexts in python for example
let g:VtrAppendNewline = 1

" don't strip whitespace, needed for python
let g:VtrStripLeadingWhitespace = 0

" don't clear empty lines, needed for python
let g:VtrClearEmptyLines = 0

" language overrides
let g:vtr_filetype_runner_overrides = {
      \ 'python': 'python3 {file}',
      \ }

" don't send clear command before executing, want to easily compare output
let g:VtrClearBeforeSend = 0

" clear sequence to send <C-c> clear <CR>
" (insert mode -> ctrl-v -> desired ctrl sequence)
let g:VtrClearSequence = "clear"

" normal mode maps, mnemonics:
"   runner attach
"   run file
"   run line
"   runner execute
"   runner reset
"   runner clear
nnoremap                    <leader>ra        :VtrAttachToPane<CR>
nnoremap                    <leader>rf        :VtrSendFile<CR>
nnoremap                    <leader>rl        :VtrSendLinesToRunner<CR>
nnoremap                    <leader>re        :VtrSendCommandToRunner<CR>
nnoremap                    <leader>rr        :VtrFlushCommand<CR>
nnoremap                    <leader>rc        :VtrClearRunner<CR>

" visual mode maps, mnemonics:
"   run lines
vnoremap                    <leader>rl        :VtrSendLinesToRunner<CR>
