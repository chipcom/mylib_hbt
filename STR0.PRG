#include "function.ch"

***** заменить последние нули в дес.знаках (и дес.точку) на пробелы
Function str_0(n,l,d)
Local s, i, c
DEFAULT l TO 10, d TO 0
s := str(n,l,d)
if d > 0
  for i := 1 to d+1
    if (c := substr(s,l-i+1,1)) == "0" .or. c == "."
      s := padr(left(s,l-i),l)
    else
      exit
    endif
  next
endif
return s
