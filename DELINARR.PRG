#include "function.ch"

***** � ��㬥୮� ���ᨢ� 㤠���� ��ப�, �᫨ � ��� �� j-�� ����樨 �⮨� uVal
Function del_in_array(arr,j,uVal)
Local i := ascan(arr, {|x| x[j] == uVal })
if i > 0
  Del_Array(arr,i)
endif
return NIL
