#include "function.ch"

***** �㭪�� �⫠��筮� ����
Function my_debug(fl, param, n_file, is_append)
DEFAULT fl TO .t., n_file TO "ttt.ttt", is_append TO .t.
if fl
  // strfile(param+eos,n_file,is_append)
  strfile(AsString( param ) + eos, n_file, is_append)
  
endif
return NIL

***** �� ��直� ��砩 (�᫨ �訡��� � ������)
Function mydebug(fl, s, n_file, is_append)
return my_debug(fl, s, n_file, is_append)
