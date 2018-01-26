#include "function.ch"
#include "inkey.ch"

* Для чисел

*****
Function arr2list(arr)
Local i, sList := ""
if valtype(arr)=="A" .and. len(arr) > 0
  asort(arr)
  for i := 1 to len(arr)
    sList += lstr(arr[i])+","
  next
  sList := left(sList,len(sList)-1)
endif
return sList

***** 24.01.18
Function list2arr(sList)
Local i, arr := {}
if valtype(sList)=="C" .and. !empty(sList)
  for i := 1 to numtoken(sList,",")
    aadd(arr, token(sList,",",i))
    if "." $ arr[i]
      arr[i] := val(arr[i])
    else
      arr[i] := int(val(arr[i]))
    endif
  next
endif
return arr
