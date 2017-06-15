""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Ctrlsf.vim Plugin Configurations                                             "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" some mapping / function to toggle compact vs normal views to see context

" preferred search util ('ag' > 'ack' > 'rg' > 'pt' > 'ack-grep')
let g:ctrlsf_ackprg = '/usr/local/bin/ag'

" how many context lines to show before and after match
" ** breaks things if using comtact viefw mode! **
"let g:ctrlsf_context = 3

" compact (quickfix like) view or normal showing context
let g:ctrlsf_default_view_mode = 'compact'

" what to ignore (this seems to bork things)
let g:ctrlsf_ignore_dir = ['vendor','.git','dotfiles/vim/bundle']

" disable save confirmation
let g:ctrlsf_confirm_save = 0

" default to use regex searches
let g:ctrlsf_regex_pattern = 1

" uses cwd as search base, instead have it look for project root
"let g:ctrlsf_default_root = 'project'

" put the results in a bottom split
let g:ctrlsf_position = 'bottom'
