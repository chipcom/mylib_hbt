#include "function.ch"

*****
*  IEval( <nCount>, <bBlock> ) --> valueLast
*  Выполняет блок кода (или функцию) bBlock nCount раз,
*  посылая ему номер текущей итерации (начиная с 1).
*  Возвращает результат последней итерации
*****
FUNCTION IEval( nCount, bBlock )
LOCAL i, valResult, flag
if valtype(bBlock) == "B"
  flag := .t.
elseif valtype(bBlock) == "C"
  flag := .f.
else
  return NIL
endif
FOR i := 1 TO nCount
  valResult := if(flag, EVAL(bBlock,i), &(bBlock+"("+lstr(i)+")") )
NEXT
RETURN valResult
