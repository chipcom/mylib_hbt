#include "function.ch"

*****
*  IEval( <nCount>, <bBlock> ) --> valueLast
*  �믮���� ���� ���� (��� �㭪��) bBlock nCount ࠧ,
*  ���뫠� ��� ����� ⥪�饩 ���樨 (��稭�� � 1).
*  �����頥� १���� ��᫥���� ���樨
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
