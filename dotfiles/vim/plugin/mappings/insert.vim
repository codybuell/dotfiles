" insert mode mappings
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
" verbose imap [key]

" map esc to keep hand on home-row
inoremap                    hh                <esc>

" allow us to map <C-Space> elsewhere (some terms interpret it as <C-@>
inoremap                    <C-@>             <C-Space>

" autoload helper functions
inoremap  <silent>          <C-u>             <C-O>:call buell#helpers#Underline()<CR>

" correct syntax highlighting
inoremap  <silent>          <localleader>c    <C-O>:syntax sync fromstart<CR>
