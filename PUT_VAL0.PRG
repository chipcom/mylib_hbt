#include "function.ch"

***** заменить последние нули в дес.знаках на пробелы,
***** а если число == 0, то вернуть пробелы
Function put_val_0(v,l,d,p)
Local i, c, s := put_val(v,l,d)
DEFAULT d TO 0, p TO " "
if d > 0 .and. "." $ s
  for i := 1 to d+1
    if (c := substr(s,l-i+1,1)) == "0" .or. c == "."
      s := padr(left(s,l-i),l)
    else
      exit
    endif
  next
endif
if !empty(p)
  s := atrepl(" ",s,p)
endif
return s
