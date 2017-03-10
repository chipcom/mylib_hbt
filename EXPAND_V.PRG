#include "function.ch"

***** если число 0 - то вернуть "0", иначе alltrim()
Function lexpand0value(v,d)
Local s := expand0value(v,d)
return if(empty(s), "0", alltrim(s))

***** если число 0 - то вернуть пустую строку
Function expand0value(v,d)
Local fl := .f., i, s := expand_value(v,d,.f.)
for i := 1 to len(s)
  if !(substr(s,i,1) $ " 0.")
    fl := .t. ; exit
  endif
next
return if(fl, s, "")

***** преобразовать число в строку и разделить пробелами по разрядам
Function expand_value(v,d,fl_0)
// fl_0 - если .f., то вместо десятичных нулей вывести пробелы
Local s, s1, s2, i, k, c
DEFAULT d TO 0, fl_0 TO .t.
s := lstr(v,19,d)
if "." $ s
  s1 := beforatnum(".",s) ; s2 := afteratnum(".",s)
else
  s1 := s ; s2 := ""
endif
if len(s1) > 3
  s1 := charmirr(s1) ; s := ""
  for i := 1 to len(s1)
    s += substr(s1,i,1)
    if i % 3 == 0
      s += " "
    endif
  next
  s1 := charmirr(alltrim(s))
endif
if len(s2) > 3
  s := ""
  for i := 1 to len(s2)
    s += substr(s2,i,1)
    if i % 3 == 0
      s += " "
    endif
  next
  s2 := s
endif
s := s1
if len(s2) > 0
  if !fl_0
    k := len(s2)
    for i := k to 1 step -1
      if (c := substr(s2,i,1)) == "0" .or. c == " "
        s2 := padr(left(s2,i-1),k)
      else
        exit
      endif
    next
  endif
  if !fl_0 .and. empty(s2)
    s += " "+s2
  else
    s += "."+s2
  endif
endif
return s
