#include "function.ch"

***** 㤠���� �� ���ᨢ� _arr 䠩� ᥬ��� (��� ��㣮� 㪠����� 䠩�)
Function DelArrSemaphore(_arr,_nfile)
Local i, k, fl
DEFAULT _nfile TO "SEMAPHOR.DBF"
if (k := len(_arr)) > 0
  for i := k to 1 step -1
    if upper(StripPath(_arr[i])) == _nfile
      Del_Array(_arr,i)
    endif
  next
  k := len(_arr)
endif
return k
