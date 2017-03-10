#include "function.ch"

***** слово "копеек" (склонение)
Function kopeek(kop)
Local t, s1, s2, s := "копеек"
if valtype(kop) == "C"
  kop := val(kop)
endif
t := str(kop,15,0)
s1 := right(t,1)
s2 := left(right(t,2),1)
if s2 != "1"
  if s1 == "1"
    s := "копейка"
  elseif s1 == "2" .or. s1 == "3" .or. s1 == "4"
    s := "копейки"
  endif
endif
return s
