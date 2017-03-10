#include "function.ch"

***** удалить из массива _arr файл семафора (или другой указанный файл)
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
