#include "function.ch"

***** в двумерном массиве удалить строку, если в ней на j-ой позиции стоит uVal
Function del_in_array(arr,j,uVal)
Local i := ascan(arr, {|x| x[j] == uVal })
if i > 0
  Del_Array(arr,i)
endif
return NIL
