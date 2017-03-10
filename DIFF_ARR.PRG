#include "function.ch"

Static loc_error := 0

***** сравнение двух массивов любой вложенности
***** и возврат % несовместимости (доли несовместимости)
Function ret_diff_arrays(x1,x2)
// Возвращает 0, если размерности массивов не совпадают
// Иначе возвращает долю несовпадений (по отношению к 1), например: 0.21 и т.п.
Local kol_k := 0, koln_sovpad := 0
if __comp_arr(x1,x2,@kol_k,@koln_sovpad) == 0 .or. kol_k <= 0
  return 0
endif
return (koln_sovpad/kol_k)

*****
Function __comp_arr(x1,x2,kol_poz,kol_nsovp)
// Возвращаемое значение:
// 0 - если в массивах имеются различия в типах данных или размерности
// 1 - нормальный проход => в переменных kol_poz (длина массива) и
//   kol_nsovp (кол-во несовпадений) по адресу возвращаются найденные значения
LOCAL i, fl := .t., vr
SET EXACT ON
if LEN(x1) != LEN(x2) // если размерности по текущему измерению не равны
  RETURN loc_error
endif
FOR i := 1 TO LEN(x1)
  if VALTYPE(x1[i]) == "A"
    vr := __comp_arr(x1[i],x2[i],@kol_poz,@kol_nsovp)
    if vr == (loc_error)
      RETURN loc_error
    endif
  elseif valtype(x1[i]) == valtype(x2[i])
    ++kol_poz
    if valtype(x1[i]) == "C"
      if upper(x1[i]) != upper(x2[i]) ; ++kol_nsovp ; endif
    else
      if x1[i] != x2[i] ; ++kol_nsovp ; endif
    endif
  else      // если типы данных по текущему измерению не совпадают
    RETURN loc_error
  endif
NEXT
RETURN (1)
