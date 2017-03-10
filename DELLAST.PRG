#include "function.ch"

***** преобразовать число в строку и удалить последние нули в десятичных знаках
Function dellastnul(n,d)  // d должно быть больше нуля
Local s, c
DEFAULT d TO 4
if d <= 0
  d := 1
endif
s := lstr(n,19,d)
do while (c := right(s,1)) == "0" .or. c == "."
  s := substr(s,1,len(s)-1)
  if c == "." ; exit ; endif
enddo
RETURN s
