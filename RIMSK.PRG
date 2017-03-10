#include "function.ch"

***** вернуть число в "римском" формате (пока до 39)
Function rimsk(n)
Local s, k1, k2, arr := {"I","II","III","IV","V","VI","VII","VIII","IX"}
if n <= 0 .or. n > 39
  s := lstr(n)
elseif between(n,1,9)
  s := arr[n]
else
  k1 := int(val(left(lstr(n),1)))
  s := replicate("X",k1)
  if (k2 := n % 10) > 0
    s += arr[k2]
  endif
endif
return s
