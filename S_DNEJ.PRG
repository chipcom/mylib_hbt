#include "function.ch"

***** ᫮�� "����" (᪫������)
Function dnej(v,padeg)
Local t := str(v,15,0), s1, s2, s := "����"
DEFAULT padeg TO "i"
s1 := right(t,1)
s2 := left(right(t,2),1)
if s2 != "1"
  if s1 == "1"
    if padeg == "i"     ; s := "����"
    elseif padeg == "r" ; s := "���"
    endif
  elseif s1 == "2" .or. s1 == "3" .or. s1 == "4"
    if padeg == "i"     ; s := "���"
    elseif padeg == "r" ; s := "����"
    endif
  endif
endif
return s

***** ᫮�� "����楢" (᪫������)
Function mes_cev(v)
Local t := str(v,15,0), s1, s2, s := "����楢"
s1 := right(t,1)
s2 := left(right(t,2),1)
if s2 != "1"
  if s1 == "1"
    s := "�����"
  elseif s1 == "2" .or. s1 == "3" .or. s1 == "4"
    s := "�����"
  endif
endif
return s

***** ᫮�� "���" (᪫������)
Function s_let(v)
Local t := str(v,15,0), s1, s2, s := "���"
s1 := right(t,1)
s2 := left(right(t,2),1)
if s2 != "1"
  if s1 == "1"
    s := "���"
  elseif s1 == "2" .or. s1 == "3" .or. s1 == "4"
    s := "����"
  endif
endif
return s
