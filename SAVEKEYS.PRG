#include "function.ch"

***** запомнить все вызовы по SET KEY (и запретить их)
Function my_savekey()
Local arr_keys := {}, b
for i := -47 to 422
  if i != 0 .and. i != 28
    if setkey(i) != NIL
      b := setkey(i,NIL)
      aadd(arr_keys, {i,b} )
    endif
  endif
next
return arr_keys

***** восстановить все вызовы по SET KEY
Function my_restkey(arr_keys)
Local i
for i := 1 to len(arr_keys)
  setkey(arr_keys[i,1],arr_keys[i,2])
next
return NIL
