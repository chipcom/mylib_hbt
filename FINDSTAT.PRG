#include "function.ch"
#include "inkey.ch"

***** ������ 梥� ��� ��ப� ���᪠ � ALPHA_BROWSE (�������)
Function color_find(mcolor)
return ntocolor(invertattr(mcolor))

***** 28.03.17 �뢥�� ��ப� ���᪠ � ALPHA_BROWSE
Function put_static(buf,s_find,mcolor)
Local r := val(substr(buf,1,3)), c := val(substr(buf,4,3))
rest_box(buf)
@ r,c+1 say "["+s_find+"]" color mcolor
return NIL
