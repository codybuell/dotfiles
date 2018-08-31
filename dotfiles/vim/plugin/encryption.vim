if has('nvim')
  " hey, you should be using gpg or something
else
  if version >=703
    set cm=blowfish2
  else
    set cm=blowfish
  endif
endif
