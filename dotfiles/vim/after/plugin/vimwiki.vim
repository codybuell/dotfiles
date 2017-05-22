""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Vimwiki Plugin Configurations                                                "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" wiki 1, notes
let wiki_1 = {}
let wiki_1.ext = '.txt'                           " file extensions
let wiki_1.path = '{{ NotesFolder }}'             " wiki root path
let wiki_1.index = 'index'                        " file minus ext of start page
let wiki_1.syntax = 'markdown'                    " default / markdown / media

" wiki 2, projects
let wiki_2 = {}
let wiki_2.ext = '.txt'                           " file extensions
let wiki_2.path = '{{ ProjectsFolder }}'          " wiki root path
let wiki_2.index = 'index'                        " file minus ext of start page
let wiki_2.syntax = 'markdown'                    " default / markdown / media

" wiki 3, codex
let wiki_3 = {}
let wiki_3.ext = '.txt'                           " file extensions
let wiki_3.path = '{{ CodexFolder }}'             " wiki root path
let wiki_3.index = 'index'                        " file minus ext of start page
let wiki_3.syntax = 'markdown'                    " default / markdown / media

" define wiki's
let g:vimwiki_list = [wiki_1, wiki_2, wiki_3]

" override default global mappings
nmap <Leader>w <Plug>VimwikiIndex

" overrides for local mappings are found in ~/.vim/ftplugin/vimwiki.vim

" map extensions and syntaxes
let g:vimwiki_ext2syntax = {
  \ '.md': 'markdown',
  \ '.txt': 'markdown',
  \ '.mkd': 'markdown',
  \ '.wiki': 'media'
  \ }

" use other plugin for folding
let g:vimwiki_folding = 'custom'
