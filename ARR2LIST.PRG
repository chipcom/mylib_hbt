#include "function.ch"
#include "inkey.ch"

** Для чисел

** 02.06.22
Function arr2list(arr, lWithoutSort)
  Local i, sList := '', lSort

  if valtype(arr) == 'A' .and. len(arr) > 0
    lSort	:= hb_DefaultValue(lWithoutSort, .f.)

    if ! lWithoutSort
      asort(arr)
    endif
    for i := 1 to len(arr)
      sList += lstr(arr[i]) + ','
    next
    sList := left(sList, len(sList) - 1)
  endif
  return sList

** 02.06.22
Function list2arr(sList)
 Local i, arr := {}

  if (valtype(sList) == 'C' .or. valtype(sList) == 'M') .and. !empty(sList)
    for i := 1 to numtoken(sList, ',')
      aadd(arr, token(sList, ',', i))
      if '.' $ arr[i]
        arr[i] := val(arr[i])
      else
        arr[i] := int(val(arr[i]))
      endif
    next
  endif
  return arr
