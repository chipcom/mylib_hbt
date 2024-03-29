#include 'function.ch'
#include 'inkey.ch'

** ��� ��ப

** 14.06.22
Function arr2Slist(arr, lWithoutSort)
  Local i, sList := ''

  if valtype(arr) == 'A' .and. len(arr) > 0
    if ! hb_DefaultValue(lWithoutSort, .f.)
      asort(arr)
    endif
    for i := 1 to len(arr)
      sList += alltrim(arr[i]) + ','
    next
    sList := left(sList, len(sList) - 1)
  endif
  return sList

** 02.06.22
Function Slist2arr(sList)
  Local i, arr := {}

  if (valtype(sList) == 'C' .or. valtype(sList) == 'M') .and. !empty(sList)
    for i := 1 to numtoken(sList, ',')
      aadd(arr, alltrim(token(sList, ',', i)))
    next
  endif
  return arr
