""""""""""""""
"            "
"   Ferret   "
"            "
""""""""""""""

" bail if ferret is not installed
if !buell#helpers#PluginExists('ferret')
  finish
endif

" [flags] [search]
" - flags get passed along to underlying tool (eg ack)
"    -i  for case insensitive search :Ack -i term

let g:FerretExecutableArguments = {
  \   'rg': '--hidden'
  \ }

nmap                        <leader>aa        <Plug>(FerretAck)
nmap                        <leader>aw        <Plug>(FerretAckWord)
nmap                        <leader>as        <Plug>(FerretAcks)
nnoremap                    <leader>a.        :Ack  %:p:h<C-B><RIGHT><RIGHT><RIGHT><RIGHT>
