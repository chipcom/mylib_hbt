#include "inkey.ch"
#include "function.ch"

***** 21.05.21 popup_prompt �� 2-��୮�� ���ᨢ� {{"name","kod"},...}
Function popup_2array(arr,r1,c1,k,i_element,/*@*/ret_arr,ltitle,ltitle_color,lcolor, n_func, status_message)
  // arr - ��㬥�� ���ᨢ
  // r1,c1 - ���न���� ������ ���孥�� 㣫� ����
  //   �᫨ r1 ����� ��� - � �� �맮� �� GET-� � ��८�।������� r1 � r2
  // k - �室�騩 ��� ��� ���᪠ �� ��஬� ����������� ���ᨢ�
  // i_element = 1 {"name","kod"}, i_element = 2 {"kod","name"}
  // ret_arr - � ��� ������� �������� �����頥�� ���ᨢ {"kod","name"}
  // n_func - ��� �㭪樨 ���짮��⥫� (����⨥ ������)

  Local i, mas_pmt := {}, ret := 0, i2 := 2, r, r2, c2, nr, nl := 0, buf, buf1

  DEFAULT k TO 0, i_element TO 1
  default n_func to ''
  default status_message to '^<Esc>^ - �⪠�;  ^<Enter>^ - �롮�'

  if i_element == 2
    i2 := 1
  endif
  nr := len(arr)
  for i := 1 to nr
    aadd(mas_pmt,arr[i,i_element])
    nl := max(nl,len(arr[i,i_element]))
  next
  nl += 2
  if r1 < 0
    r := abs(r1)
    if (r1 := r+1) > int(maxrow()/2)
      r2 := r-1
      if (r1 := r2-nr-1) < 2
        r1 := 2
      endif
    else
      r2 := r1 + nr + 1
    endif
  else
    r2 := r1 + nr + 1
  endif
  c2 := c1 + nl + 1
  if c2 > maxcol()-2
    c2 := maxcol()-2 ; c1 := maxcol()-3 - nl
  endif

  if c1 < 0 ; c1 := 0 ; endif
  if r2 > maxrow()-2 ; r2 := maxrow()-2 ; endif

  buf := save_box(r1,c1,r2+1,c2+2)
  buf1 := save_maxrow()

  i := ascan(arr, {|x| x[i2] == k })
  status_key( status_message )
  if (i := popup(r1,c1,r2,c2,mas_pmt,i,lcolor,.t.,n_func,,ltitle,ltitle_color)) > 0
    ret := arr[i,i2]
    ret_arr := aclone(arr[i])
  endif

  rest_box(buf)
  rest_box(buf1)
  return ret

  