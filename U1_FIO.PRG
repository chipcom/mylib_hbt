#include "function.ch"

***** преобразовать строку Ф.И.О. (в GET'е) к нормальному виду :
***** т.е. первая буква в слове заглавная, остальные маленькие
Function upper1_fio(i_var)
Local i, l, tmp, s := "", c, fl := .t.
if i_var == NIL  // т.е. преобразование переменной в GET'е
  tmp := &(readvar())
else
  tmp := i_var
endif
l := len(tmp)
tmp := lower(alltrim(tmp))  // все в нижний регистр
tmp := charone(" ",tmp)     // оставить по одному пробелу
for i := 1 to len(tmp)
  c := substr(tmp,i,1)
  if isletter(c)
    if fl  // т.е. это первая буква в слове
      c := upper(c)
    endif
    fl := .f.
  else
    fl := .t.
  endif
  s += c
next
if i_var == NIL  // т.е. преобразование переменной в GET'е
  &(readvar()) := padr(s,l)
  return .t.
endif
return padr(s,l)
