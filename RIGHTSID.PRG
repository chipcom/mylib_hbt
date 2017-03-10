***** отрисовка линейки (справа) в функциях popup и arrn_browse
Function right_side(fl, n, nlen, top, right, h)
// в вызывающей программе должна быть определена: Private last_k := 2
Local i, k
if fl
  if n == 1
    k := 2
  elseif n == nlen
    k := h - 1
  else
    k := int(n / nlen * (h-4)) + 3
    if k <= 2
      k := 3
    elseif k >= h-1
      k := h - 2
    endif
  endif
  if last_k != k
    @ top+last_k,right say chr(176)
    @ top+k,right say chr(8)
    last_k := k
  endif
endif
return n