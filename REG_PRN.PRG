#include "function.ch"

***** вернуть режим печати по заголовку и переопределить ширину (@sh)
Function f_reg_print(_arr_title,_sh,_tip)
Local _reg_print
DEFAULT _tip TO 1
if (_sh := len(_arr_title[1])) <= 65
  _reg_print := 1
elseif _sh <= 85
  _reg_print := 2
else
  _reg_print := 3
endif
if _tip == 2
  _reg_print += 3   // 8 строк на дюйм
endif
return _reg_print
