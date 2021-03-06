*  �ࠢ��� �맮�� ������ �-��:
*       use_base("klient")
*   !   akl := myfcount()  // �������� ���ᨢ �� ��, � ������ �����㥬
*       ~~~
*       use tmp_kl new
*   !   akl := myfcount(akl)  // ��筨� �� ��, �� ���ன �����㥬
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
if arr == NIL  // �맮� �� ��, � ������ �����㥬
  k := fcount()
  arr := {}
  for i := 1 to k
    aadd(arr, {0,i,nil,fieldname(i)} )
  next
else           // �맮� �� ��, �� ���ன �����㥬
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
