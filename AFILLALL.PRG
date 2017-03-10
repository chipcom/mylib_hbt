#include "function.ch"

***** заполняет массив любой вложенности заданным значением
FUNCTION afillall(_arr,z)
AEVAL(_arr, {|x,i| IF(VALTYPE(x) == "A", afillall(x,z), _arr[i] := z) } )
RETURN NIL

***** проверка элементов массива (выполнение блока кода)
Function ver_array(_arr,_blk,_i1,_i2)
Local fl := .t., i
DEFAULT _i1 TO 1, _i2 TO len(_arr)
for i := _i1 to _i2
  if !eval(_blk, _arr[i])
    fl := .f. ; exit
  endif
next
return fl

***** проверка всех элементов массива на пустоту
Function empty_array(_arr,_i1,_i2)
return ver_array(_arr,{|x|empty(x)},_i1,_i2)
