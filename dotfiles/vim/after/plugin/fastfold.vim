""""""""""""""""
"              "
"   FastFold   "
"              "
""""""""""""""""

" mappings are defined in plugin/mappings/normal.vim

" update folds on file save
let g:fastfold_savehook = 1

" dont intercept changes of fold methods (easymotion compat)
let g:fastfold_fdmhook = 0

" update folds when the following fold suffixes or fold movements are used
let g:fastfold_fold_command_suffixes =  ['x','X','a','A','o','O','c','C','i']
let g:fastfold_fold_movement_commands = [']z', '[z', 'zj', 'zk']
