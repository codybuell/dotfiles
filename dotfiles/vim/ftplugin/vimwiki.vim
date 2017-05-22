" override follow link <CR> => ctrl + l
nmap              <C-l>               :w<CR><Plug>VimwikiFollowLink

" prevent a number of inconvenient mappings: tab, backspace, =, -
nmap       <Plug>NoVimwikiNextLink            <Plug>VimwikiNextLink
nmap       <Plug>NoVimwikiGoBackLink          <Plug>VimwikiGoBackLink
nmap       <Plug>NoVimwikiAddHeaderLevel      <Plug>VimwikiAddHeaderLevel
nmap       <Plug>NoVimwikiRemoveHeaderLevel   <Plug>VimwikiRemoveHeaderLevel
