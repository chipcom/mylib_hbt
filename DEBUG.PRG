#include "function.ch"

***** функция отладочной печати
Function my_debug(fl, param, n_file, is_append)
DEFAULT fl TO .t., n_file TO "ttt.ttt", is_append TO .t.
if fl
  // strfile(param+eos,n_file,is_append)
  strfile(AsString( param ) + eos, n_file, is_append)
  
endif
return NIL

***** на всякий случай (если ошибусь с именем)
Function mydebug(fl, s, n_file, is_append)
return my_debug(fl, s, n_file, is_append)
