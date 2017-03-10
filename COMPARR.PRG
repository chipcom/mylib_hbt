#include "function.ch"
#include "inkey.ch"

***** сравнение двух массивов любой вложенности
FUNCTION compare_arrays(x1,x2)
LOCAL i, fl := .t.
SET EXACT ON
if equalany(NIL,x1,x2)
  RETURN .f.
endif
if LEN(x1) != LEN(x2) // если размерности по текущему измерению не равны
  RETURN .f.
endif
AEVAL(x1, {|x,i| IF(VALTYPE(x) != VALTYPE(x2[i]), fl := .f., NIL) })
if !fl            // если типы данных по текущему измерению не совпадают
  RETURN .f.
endif
FOR i := 1 TO LEN(x1)
  if VALTYPE(x1[i]) == "A"
    if !compare_arrays(x1[i],x2[i]) ; RETURN .f. ; endif
  elseif valtype(x1[i]) == valtype(x2[i])
    if valtype(x1[i]) == "C"
      if upper(x1[i]) != upper(x2[i]) ; RETURN .f. ; endif
    else
      if x1[i] != x2[i] ; RETURN .f. ; endif
    endif
  else
    RETURN .f.
  endif
NEXT
RETURN .T.
