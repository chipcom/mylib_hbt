#include "function.ch"
#include "inkey.ch"

***** �㭪�� ��७�� ��ப� (ࠧ१��� �� ��᪮�쪮)
FUNCTION perenos(mas,s,n,symb)
// mas  - ��� ���ᨢ�, � ����� ���� ��������� ��१�� ��ப�
// s    - ��ப�, ����� �㤥� ࠧ१�����
// n    - ������⢮ ᨬ����� � ��१��� ��ப
// symb - ���������⢮ ᨬ������ �� " ,;-+/" (ࠧ����⥫� ��� ��७��)
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
  ELSEIF SUBSTR(s,n+1,1) == " " // �᫨ ��᫥ ��१���� �ࠧ� ���� �஡��
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
RETURN i       //  ������ ������⢮ ����稢���� ��ப
