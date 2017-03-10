*  Правила вызова данных ф-ий:
*       use_base("klient")
*   !   akl := myfcount()  // заполним массив по БД, в которую копируем
*       ~~~
*       use tmp_kl new
*   !   akl := myfcount(akl)  // уточним по БД, из которой копируем
*       ~~~             ~~~
*       go top
*       do while !eof()
*         ...
*         select TMP_KL
*   !     myfieldget(akl)
*                    ~~~
*         select KLIENT
*         set order to 1
*         addrec(5)
*   !     myfieldput(akl)
*                    ~~~
*         klient->kod := klient->(recno())
*         UnLock
*         ...
******************************************************************************
#include "inkey.ch"
#include "function.ch"

*****
Function myfcount(arr)
Local i, j, k
if arr == NIL  // вызов по БД, в которую копируем
  k := fcount()
  arr := {}
  for i := 1 to k
    aadd(arr, {0,i,nil,fieldname(i)} )
  next
else           // вызов по БД, из которой копируем
  k := len(arr)
  for i := 1 to k
    if (j := fieldnum(arr[i,4])) > 0
      arr[i,1] := j
    endif
  next
endif
return arr

*****
Function myfieldget(arr)
Local i, j, k
k := len(arr)
for i := 1 to k
  if (j := arr[i,1]) > 0
    arr[i,3] := fieldget(j)
  endif
next
return NIL

*****
Function myfieldput(arr)
Local i, j, k
k := len(arr)
for i := 1 to k
  if arr[i,1] > 0 .and. (j := arr[i,2]) > 0
    fieldput(j,arr[i,3])
  endif
next
return NIL
