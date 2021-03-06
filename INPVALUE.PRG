#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"

***** 01.02.13
Function input_value(r1,c1,r2,c2,mcolor,mmsg,mvalue,mpicture)
// r1,c1,r2,c2 - ࠧ���� box'�
// mcolor      - 梥�
// mmsg        - ��ப� ᮮ�饭�� (��� ���ᨢ �� ���� ������⮢ ��ப�)
// mvalue      - ���祭�� ��� ���樠����樨 GET'�
// mpicture    - PICTURE ��� ����� ���祭�� ���
//               ���� ��� �롮� �� A__MENUVERT
//   �᫨ r2-r1 > 2 � � mmsg > 1 �������, � �뢮� �ந�������� � ��᪮�쪮
//   ��ப, � GET �뢮����� � ��᫥���� ��ப� ��᫥ ��᫥����� mmsg[i],;
//   �� ��ப�, �஬� ��᫥����, 業��������
Local buf, buf24, tmp_color, i, fl_menu := .f.
DEFAULT mcolor TO color0
if valtype(mmsg) == "C"
  mmsg := {mmsg}
endif
if valtype(mmsg) != "A"
  func_error(4,"������ ��㬥�� MMSG � �㭪樨 INPUT_VALUE")
  return NIL
endif
if valtype(mpicture) == "A"
  fl_menu := .t.
  Private m1name := mvalue, mname := inieditspr(A__MENUVERT,mpicture,mvalue)
else
  Private mname := mvalue
endif
tmp_color := setcolor(mcolor)
buf := box_shadow(r1,c1,r2,c2)
if r2 - r1 > 2
  for i := 1 to len(mmsg)
    if i == len(mmsg)
      if fl_menu
        @ r1+i,c1+2 say mmsg[i] get mname ;
                 reader {|x|menu_reader(x,mpicture,A__MENUVERT,,,.f.)}
      else
        @ r1+i,c1+2 say mmsg[i] get mname picture mpicture
      endif
    else
      @ r1+i,c1+2 say center(mmsg[i],c2-c1-1)
    endif
  next
else
  if fl_menu
    @ r1+1,c1+2 say mmsg[1] get mname ;
             reader {|x|menu_reader(x,mpicture,A__MENUVERT,,,.f.)}
  else
    @ r1+1,c1+2 say mmsg[1] get mname picture mpicture
  endif
  if len(mmsg) == 2
    @ row(),col()+1 say mmsg[2]
  endif
endif
buf24 := save_maxrow()
status_key("^<Esc>^ - �⪠� �� �����;  ^<Enter>^ - ���⢥ত���� �����")
myread({"confirm"})
setcolor(tmp_color)
rest_box(buf24)
rest_box(buf)
return iif(lastkey() == K_ESC, NIL, iif(fl_menu, m1name, mname))
