#include "inkey.ch"
#include "function.ch"

*****
Function input_diapazon(r1,c1,r2,c2,mcolor,mmsg,mvalue,mpicture,blk_valid)
// r1,c1,r2,c2 - ࠧ���� box'�
// mcolor      - 梥�
// mmsg        - ���ᨢ �� ���� (��� ���) ������⮢ ᮮ�饭��
// mvalue      - ���ᨢ ���祭�� ��� ���樠����樨 GET'��
// mpicture    - ���ᨢ PICTURE ��� ����� ���祭��
// blk_valid   - ���� ���� ��� �஢�ન ��������� ���祭��, ���ਬ��:
//       blk_valid := {|x,y| if(x > y, ;
//                  func_error(4,"��砫쭠� ��� ����� ����筮�!"), .t.) }
//       (����� x � y - ��ࢮ� � ��஥ �������� ���祭��)
Local buf, buf24, tmp_color
DEFAULT mcolor TO color0, mpicture TO {NIL,NIL}, blk_valid TO {||.t.}
if valtype(mmsg) != "A" .or. valtype(mvalue) != "A" .or. ;
                                        valtype(mpicture) != "A"
  func_error(4,"��㬥�⠬� �㭪樨 INPUT_DIAPAZON ������ ���� ���ᨢ�")
  return NIL
endif
tmp_color := setcolor(mcolor)
Private p1value := mvalue[1], p2value := mvalue[2]
buf := box_shadow(r1,c1,r2,c2)
buf24 := save_maxrow()
do while .t.
  @ r1+1,c1+2 say mmsg[1] get p1value picture mpicture[1]
  @ row(),col()+1 say mmsg[2] get p2value picture mpicture[2]
  if len(mmsg) == 3
    @ row(),col()+1 say mmsg[3]
  endif
  status_key("^<Esc>^ - �⪠� �� �����;  ^<Enter>^ - ���⢥ত���� �����")
  myread({"confirm"})
  if lastkey() == K_ESC .or. eval(blk_valid,p1value,p2value)
    exit
  endif
enddo
setcolor(tmp_color)
rest_box(buf24)
rest_box(buf)
return if(lastkey() == K_ESC, NIL, {p1value,p2value})
