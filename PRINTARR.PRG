#include "function.ch"

***** вернуть строку с содержимым многомерного массива
function print_array(m)
Local i, s := "", vt := valtype(m)
do case
  case vt == "A"
    s += "{"
    for i := 1 to len(m)
      s += print_array(m[i]) + iif(i < len(m), ",", "")
    next
    s += "}"
  case vt == "N"
    s += " "+lstr(m)
  case vt == "C"
    s += " "+alltrim(m)
    if empty(m)
      s += '""'
    endif
  case vt == "D"
    s += " "+dtoc(m)
  case vt == "L"
    s += " "+if(m, ".T.", ".F.")
  case vt == "B"
    s += " ■B■"
  case vt == "O"
    s += " <объект>"
  otherwise
    s += " NIL"
endcase
return s
