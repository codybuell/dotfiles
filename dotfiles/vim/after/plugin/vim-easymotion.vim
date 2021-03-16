""""""""""""""""""""""
"                    "
"   Vim-EasyMotion   "
"                    "
""""""""""""""""""""""

" bail if vim-easymotion is not installed
if !buell#helpers#PluginExists('vim-easymotion')
  finish
endif

" mappings are defined in plugin/mappings/normal.vim

"   <Plug>(easymotion-f)  | <localleader><localleader>f{char}
"   <Plug>(easymotion-F)  | <localleader><localleader>F{char}
"   <Plug>(easymotion-t)  | <localleader><localleader>t{char}
"   <Plug>(easymotion-T)  | <localleader><localleader>T{char}
"   <Plug>(easymotion-w)  | <localleader><localleader>w
"   <Plug>(easymotion-W)  | <localleader><localleader>W
"   <Plug>(easymotion-b)  | <localleader><localleader>b
"   <Plug>(easymotion-B)  | <localleader><localleader>B
"   <Plug>(easymotion-e)  | <localleader><localleader>e
"   <Plug>(easymotion-E)  | <localleader><localleader>E
"   <Plug>(easymotion-ge) | <localleader><localleader>ge
"   <Plug>(easymotion-gE) | <localleader><localleader>gE
"   <Plug>(easymotion-j)  | <localleader><localleader>j
"   <Plug>(easymotion-k)  | <localleader><localleader>k
"   <Plug>(easymotion-n)  | <localleader><localleader>n
"   <Plug>(easymotionp-N)  | <localleader><localleader>N
"   <Plug>(easymotion-s)  | <localleader><localleader>s

" turn on case insensitive feature
let g:EasyMotion_smartcase  = 1

" don't use space space, want that for toggling buffers
map <localleader><localleader>        <Plug>(easymotion-prefix)

" easymotion convenience mappings
"nmap                        <leader>f         <Plug>(easymotion-overwin-f)
nmap                        <leader>w         <Plug>(easymotion-overwin-w)
