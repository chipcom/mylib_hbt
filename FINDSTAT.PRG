#include "function.ch"
#include "inkey.ch"

***** вернуть цвет для строки поиска в ALPHA_BROWSE (инверсия)
Function color_find(mcolor)
return ntocolor(invertattr(mcolor))

***** вывести строку поиска в ALPHA_BROWSE
Function put_static(buf,s_find,mcolor)
Local r := val(substr(buf,1,2)), c := val(substr(buf,3,2))
rest_box(buf)
@ r,c+1 say "["+s_find+"]" color mcolor
return NIL
