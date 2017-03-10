#include "function.ch"

***** если вдруг вызов без буквы 's' на конце
Function update_get(mname,k1)
return update_gets(mname,k1)

***** обновить поле GET с именем mname (без параметров обновляет все GET'ы)
Function update_gets(mname,k1)
Local i
if mname == NIL
  aeval(GetList, {|x| x:display() })
elseif valtype(mname) == "C"
  if k1 == NIL  // просто переменная
    if (i := ascan(GetList, {|x| upper(x:name) == upper(mname) })) > 0
      GetList[i]:display()
    endif
  else          // элемент одномерного массива
    if (i := ascan(GetList, {|x| upper(x:name) == upper(mname) .and. ;
                                 x:subscript[1] == k1 })) > 0
      GetList[i]:display()
    endif
  endif
endif
return .t.
