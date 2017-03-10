#include "function.ch"

***** слово "рублей" (склонение)
Function rublej(rub)
Local t, s1, s2, s := "рублей"
if valtype(rub) == "C"
  rub := val(rub)
endif
t := str(int(rub),15,0)
s1 := right(t,1)
s2 := left(right(t,2),1)
if s2 != "1"
  if s1 == "1"
    s := "рубль"
  elseif s1 == "2" .or. s1 == "3" .or. s1 == "4"
    s := "рубля"
  endif
endif
return s
