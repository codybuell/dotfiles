""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                              "
" Wiki Autoload Functions                                                      "
"                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" create or follow a wiki link
function! functions#CreateFollowWikiLink() abort

  " is text under cursor in a link format?
  "  standard formats
  "  ](....:[a-Z0-9]+)  ===> link to an entry in another wiki
  "  ](#[a-Z0-9]+)      ===> link to section in current doc
  "  ]([a-Z0-9]+)       ===> link to wiki entry
  "  ](http[s]?://.*)   ===> link to external resource
  "  ](.*.\(com|net|us...\)$)
  "
  "  automatic links format??
  "  <#[a-Z0-9]+>   ===> link to section in current doc

  " if text is not a link, make it a link in standard format

  " if text is a link, follow it if file exists, else create it
  " if link is external url open it in browser window
  " if local link, move cursor to location
  " if other wiki doc, prompt for save if necessary and move to other
endfunction

