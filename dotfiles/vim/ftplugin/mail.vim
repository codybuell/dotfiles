" see also after/ftplugin/mail.vim

" enable spell checking
setlocal spell

" add autocompletion for spell checking
setlocal complete+=kspell

" completion function to query lbdbq contact list (relies on lbdbq.vim)
fun! LBDBCompleteFn(findstart, base)
    if a:findstart
	" locate the start of the word
	let line = getline('.')
	let start = col('.') - 1
	while start > 0 && line[start - 1] =~ '[^:,]'
	  let start -= 1
	endwhile
	while start < col('.') && line[start] =~ '[:, ]'
	    let start += 1
	endwhile
	return start
    else
	let res = []
	let query = substitute(a:base, '"', '', 'g')
	let query = substitute(query, '\s*<.*>\s*', '', 'g')
	for m in LbdbQuery(query)
	    call add(res, printf('"%s" <%s>', escape(m[0], '"'), m[1]))
	endfor
	return res
    endif
endfun

" define above as our completion function for mail file types
set completefunc=LBDBCompleteFn
