#include "function.ch"

***** ����� � த�⥫쭮� ������
function month_r(md)
Local mas := {"ﭢ���","䥢ࠫ�","����","��५�","���","���",;
              "���","������","ᥭ����","������","�����","�������"}
if valtype(md) == "C"
  md := ctod(md)
endif
if valtype(md) == "D"
  return mas[month(md)]
endif
return ""
