#include "function.ch"
#include "inkey.ch"

***** функция переноса строки (разрезать на несколько)
FUNCTION perenos(mas,s,n,symb)
// mas  - имя массива, в который будут заноситься обрезки строки
// s    - строка, которая будет разрезаться
// n    - количество символов в обрезках строк
// symb - подмножество симоволов из " ,;-+/" (разделители для переноса)
Local i := 0, i1, i2, i3, i4, i5, i6, j, fl, s1
DEFAULT symb TO " ,;-"
if valtype(mas) == "A"
  AFILL(mas, "")
else
  mas := {}
endif
if empty(s := RTRIM(s))
  if len(mas) == 0
    asize(mas, 1)
  endif
  mas[1] := space(n)
  return 0
endif
DO WHILE .T.
  IF LEN(s) <= n
    if ++i > len(mas)
      asize(mas, i)
    endif
    mas[i] := padr(s,n)
    EXIT
  ELSEIF SUBSTR(s,n+1,1) == " " // если после отрезания сразу идет пробел
    if ++i > len(mas)
      asize(mas, i)
    endif
    mas[i] := SUBSTR(s,1,n)
    s := LTRIM(SUBSTR(s,n+1))
  ELSE
    s1 := SUBSTR(s,1,n)
    i1 := if(" " $ symb, RAT(" ",s1), 0)
    i2 := if("," $ symb, RAT(",",s1), 0)
    i3 := if(";" $ symb, RAT(";",s1), 0)
    i4 := if("-" $ symb, RAT("-",s1), 0)
    i5 := if("+" $ symb, RAT("+",s1), 0)
    i6 := if("/" $ symb, RAT("/",s1), 0)
    j := MAX(i2,i3,i4,i5,i6)
    fl := (i1 > j)
    j := MAX(j,i1)
    if ++i > len(mas)
      asize(mas, i)
    endif
    IF j > 0
      mas[i] := padr(SUBSTR(s1,1,IF(fl,j-1,j)),n)
      s := LTRIM(SUBSTR(s,j+1))
    ELSE
      mas[i] := SUBSTR(s,1,n)
      s := LTRIM(SUBSTR(s,n+1))
    ENDIF
  ENDIF
ENDDO
RETURN i       //  вернуть количество получившихся строк
