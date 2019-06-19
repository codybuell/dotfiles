" visual mode mappings
"
" {cmd} {attr} {lhs} {rhs}
"
" where
"
" {cmd}  is one of ':map', ':map!', ':nmap', ':vmap', ':imap',
"        ':cmap', ':smap', ':xmap', ':omap', ':lmap', etc.
" {attr} is optional and one or more of the following: <buffer>, <silent>,
"        <expr> <script>, <unique> and <special>.
"        More than one attribute can be specified to a map.
" {lhs}  left hand side, is a sequence of one or more keys that you will use
"        in your new shortcut.
" {rhs}  right hand side, is the sequence of keys that the {lhs} shortcut keys
"        will execute when entered.
"
" <C-O>  - enters normal mode for one command
" <C-R>= - insert the result of an expression at the cursor
" <C-B>  - go to the beginning of the command line
"
" verbose vmap [key]

" damian conways drag visul utility
vmap      <expr>            <Left>            DVB_Drag('left')
vmap      <expr>            <Right>           DVB_Drag('right')
vmap      <expr>            <Down>            DVB_Drag('down')
vmap      <expr>            <Up>              DVB_Drag('up')
vmap      <expr>            D                 DVB_Duplicate()

" vim-expand-region
vmap                        v                 <Plug>(expand_region_expand)
vmap                        <C-v>             <Plug>(expand_region_shrink)

" line sorting (length, alphabetical)
vmap      <silent>          <leader>sl        :'<,'>!awk '{print length(), $0 \| "sort -n \| cut -d\\  -f2-" }'<CR>
vmap      <silent>          <leader>sa        :'<,'>!sort<CR>

" override visual yank to overload with copying to system clipboard as well
vnoremap  <silent>          y                 :<C-u>exe 'call buell#helpers#YankOverride()'<CR>

" maths
"vmap      <silent><expr>    <leader>=         VMATH_YankAndAnalyse()
" print out the total of the summation at the bottom of your visual selection
"vmap       <silent>         <leader>=         :'<,'>!awk '1;{sum+=$1} END {print sum}'<CR>
" print out the total of the summation at the bottom of your visual selection, strip out commas, needs vim-vis plugin!
vmap       <silent>         <leader>=         :'<,'>B !awk '1;{sub(/,/, "");sum+=$1} END {print sum}'<CR>
" print out the total of the summation in a shell window
"vmap      <silent><expr>    <leader>=         :'<,'>w !awk '1;{sum+=$1} END {print sum}'
" capture the sum into the default register
"vmap      <silent><expr>    <leader>=         :'<,'>??????????????
