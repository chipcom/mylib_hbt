#include "function.ch"

***** �㭪�� ����� ��஫� �� �ணࠬ��
Function get_parol(r1,c1,r2,c2,ltip,color_say,color_get)
Local s := space(10), buf, buf24, tmp_color
DEFAULT r1 TO maxrow()-5, c1 TO int((maxcol()-36)/2), r2 TO maxrow()-3
DEFAULT ltip TO 0, c2 TO c1+36, color_say TO "W+/B", color_get TO "W+/R"
tmp_color := setcolor(color_say+","+color_get)
buf := box_shadow(r1,c1,r2,c2,,,,ltip)
buf24 := save_maxrow()
status_key("^<Esc>^ - ��室 �� �����;  ^<Enter>^ - ���⢥ত���� ����� ��஫�")
set confirm on
setcursor()
@ r1+1,c1+18 say s color color_get  // �.�. �� ࠡ�⠥� get � �뤥������ 梥�
s := upper(getsecret(s,r1+1,c1+10,,"��஫�:"))
setcursor(0)
set confirm off
rest_box(buf)
rest_box(buf24)
setcolor(tmp_color)
return s

***** ������ � ���ᨢ� ��� ��஫� � ���᪮� � ������᪮� �᪫����
Function my_parol(k)
Local ret := {"����Eg��","jSǓ��i"}
DEFAULT k TO 1
if k == 2  // ��ன ��⥬�� ��஫�
  //ret := {"��w)uӵ"}
  ret := {"����u'â"}
endif
return ret
