#include "function.ch"

***** ������ 㪠��⥫� �� GET-��ꥪ� � ������ mname (��� ����� get-��ꥪ�)
Function get_pointer(mname,fl_p)
Local i
DEFAULT fl_p TO .t.
if (i := ascan(GetList, {|x| upper(x:name) == upper(mname) })) > 0
  return if(fl_p, GetList[i], i)
endif
return NIL
