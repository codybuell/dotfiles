" Vim plugin for summing numbers
" (in select mode or in operator-pending mode)
" Last Change:	February 25, 2017 01:36
" Maintainer:	GrepSuzette (https://github.com/emugel/vim-sum)
" License:	    This file is placed in the public domain.

if exists("g:loaded_vimsum")
  finish
endif
let g:loaded_vimsum = 1

" Sum of numbers
" .look for all supported number types in selection/g@
" .print the result (echomsg)
" .also put the result in unnamed register (can be paste with p etc)
"
" Note: primary usage for this is with textobj-word-column,
"       you select a column with viC and run the shortcut to process the sum.
" Note: use :match none to clear the highlight
"
" Example of SUPPORTED VALID numbers:
"
"   52         Positive integer
"   92.25      Float
"   .525       Here can omit the leading 0
"   -.226      Can be negative
"   92,25      A coma is similar to a dot (french etc use that in text & docs)
"   -,63
"
" NOT SUPPORTED:
"
" - Scientific numbers such as 42.352e23
" - Hexadecimal, octal, binary numbers (Would be nice though)
" - Numbers not separated by a space, this is to minimize risks of error e.g.:
"   45min    will be discarded
"   100-35   will be discarded. "100 -35" OTOH will add 100 with -35
"   1. 2. 3. will all be discarded (while .1 is accepted)
"
" February 25, 2017 00:56 GrepSuzette
function! s:SumSelectedText(type)
    let s:sel_save = &selection
    let &selection = "inclusive"
    let s:saved_unnamed_register = @@

    if a:type ==# 'V'
        normal! gv"_y
        match Search /\(^\|\s\|\n\)\%V\zs-\?[0-9]*[,.]\?[0-9]\+\%V\ze\($\|\s\|\n\)/
        normal! `>
    elseif a:type ==# ''
        normal! gvy
        match Search /\(^\|\s\|\n\)\zs\%V-\?[0-9]*[,.]\?[0-9]\+\%V[0-9]\?\ze\($\|\s\|\n\)/
        normal! `>
    elseif a:type ==# 'v'
        normal! `<v`>y
        match Search /\(^\|\s\|\n\)\%V\zs-\?[0-9]*[,.]\?[0-9]\+\%V.\ze\($\|\s\|\n\)/
        normal! `>
    elseif a:type ==# 'char'
        normal! `[v`]y
        match Search /.\%<'\]\zs-\?[0-9]*[,.]\?[0-9]\+\ze\%>'\[/
        normal! `>
    elseif a:type ==# 'line'
        match Search /\(^\|\s\|\n\)\%<'\]\zs-\?[0-9]*[,.]\?[0-9]\+\ze\%>'\[\($\|\s\|\n\)/
        normal! '[y']
        normal! `]
    else
       echo "Unknown type:" . a:type . " @@: " . @@ . " &selection: " . &selection
       return
    endif

    " echomsg "type:" . a:type . " new@@:" . @@ . " &selection: " . &selection

    let s:idx = 0
    let s:sum = 0
    " echomsg @@
    while s:idx != -1
        let s:a = matchstrpos(@@, '\(^\|\s\|\n\)\zs-\?[0-9]*[,.]\?[0-9]\+\ze\($\|\s\|\n\)', s:idx)
        " echomsg s:a[0] . "  " . s:a[1] . "  " . s:a[2]
        if s:a[1] > -1
            let s:sum += str2float(substitute(s:a[0], ',', '.', ""))
            let s:idx = s:a[2]
        else
            break
        endif
    endwhile

    if (floor(s:sum) == s:sum)
        let s:ssum = printf("%d", float2nr(s:sum))
    else
        let s:ssum = printf("%f", s:sum)
    endif

    echohl MoreMsg
    redraw
    echomsg "Sum: " . s:ssum . " (paste with 'p', ':match None' to hide)"
    echohl None

	let &selection = s:sel_save
    let @@ = s:saved_unnamed_register
    let @" = s:ssum
endfunction

vnoremap <silent> <Plug>VimSumVisual          :<C-U>call <SID>SumSelectedText(visualmode())<CR>
nnoremap <silent> <Plug>VimSumOperatorPending :echomsg "Operator-pending mode for summing numbers (} for EOParag., etc)"<CR>:set opfunc=<SID>SumSelectedText<CR>g@
