#include "function.ch"

***** ������ ����� LSTR (��� �ᯮ�짮����� � 蠡�����)
Function FLSTR(n,l,d)
DEFAULT l TO 19, d TO 0
return ltrim(str(n,l,d))
