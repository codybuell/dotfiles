" see also after/ftplugin/mail.vim

" enable spell checking
setlocal spell

" add autocompletion for spell checking
setlocal complete+=kspell

" queries lbdb with a query string and return a list of pairs:
" [['full name', 'email'], ['full name', 'email'], ...]
fun! LBDBQueryEmail(qstring)
  let output = system("lbdbq '" . a:qstring . "'")
  let results = []
  for line in split(output, "\n")[1:] " skip first line (lbdbq summary)
    let fields = split(line, "\t")
    let results += [ [fields[1], fields[0]] ]
  endfor
  return results
endfunction

" completion function to query lbdbq contact list
fun! LBDBCompleteFn(findstart, base)
  " complete functions are called twice, first run needs to return the col
  " where the completion starts...

  " if first run
  if a:findstart
    " locate the start of the word
    let line = getline('.')
    let start = col('.') - 1
    " decrement start var to the beginning of the email address
    while start > 0 && line[start - 1] =~ '[^:,]'
      let start -= 1
    endwhile
    while start < col('.') && line[start] =~ '[:, ]'
        let start += 1
    endwhile
    return start
  " subsequent runs
  else
    " initialize results array
    let res = []
    " strip out quotes and angle brackets? from query
    let query = substitute(a:base, '"', '', 'g')
    let query = substitute(query, '\s*<.*>\s*', '', 'g')
    " query lbdbquery and append results to array
    for m in LBDBQueryEmail(query)
      " format results
      call add(res, printf('"%s" <%s>', escape(m[0], '"'), m[1]))
    endfor
    return res
  endif
endfun

" define above as our completion function for mail file types
sendency et completefunc=LBDBCompleteFn
