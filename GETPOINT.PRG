#include "function.ch"

***** вернуть указатель на GET-объект с именем mname (или номер get-объекта)
Function get_pointer(mname,fl_p)
Local i
DEFAULT fl_p TO .t.
if (i := ascan(GetList, {|x| upper(x:name) == upper(mname) })) > 0
  return if(fl_p, GetList[i], i)
endif
return NIL
