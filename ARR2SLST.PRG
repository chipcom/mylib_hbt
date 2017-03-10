#include "function.ch"
#include "inkey.ch"

* Для строк

*****
Function arr2Slist(arr)
Local i, sList := ""
if valtype(arr)=="A" .and. len(arr) > 0
  asort(arr)
  for i := 1 to len(arr)
    sList += alltrim(arr[i])+","
  next
  sList := left(sList,len(sList)-1)
endif
return sList

*****
Function Slist2arr(sList)
Local i, arr := {}
if valtype(sList)=="C" .and. !empty(sList)
  for i := 1 to numtoken(sList,",")
    aadd(arr, alltrim(token(sList,",",i)) )
  next
endif
return arr
