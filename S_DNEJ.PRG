#include "function.ch"

***** слово "дней" (склонение)
Function dnej(v,padeg)
Local t := str(v,15,0), s1, s2, s := "дней"
DEFAULT padeg TO "i"
s1 := right(t,1)
s2 := left(right(t,2),1)
if s2 != "1"
  if s1 == "1"
    if padeg == "i"     ; s := "день"
    elseif padeg == "r" ; s := "дня"
    endif
  elseif s1 == "2" .or. s1 == "3" .or. s1 == "4"
    if padeg == "i"     ; s := "дня"
    elseif padeg == "r" ; s := "дней"
    endif
  endif
endif
return s

***** слово "месяцев" (склонение)
Function mes_cev(v)
Local t := str(v,15,0), s1, s2, s := "месяцев"
s1 := right(t,1)
s2 := left(right(t,2),1)
if s2 != "1"
  if s1 == "1"
    s := "месяц"
  elseif s1 == "2" .or. s1 == "3" .or. s1 == "4"
    s := "месяца"
  endif
endif
return s

***** слово "лет" (склонение)
Function s_let(v)
Local t := str(v,15,0), s1, s2, s := "лет"
s1 := right(t,1)
s2 := left(right(t,2),1)
if s2 != "1"
  if s1 == "1"
    s := "год"
  elseif s1 == "2" .or. s1 == "3" .or. s1 == "4"
    s := "года"
  endif
endif
return s
