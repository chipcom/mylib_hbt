#include "function.ch"

***** ���� ��� �롮� ��᪮����
Function menu_disk( nTop, nLeft, nBottom, nRight, yes_floppy )
Local tmp_drv, ad := ret_arr_disk(yes_floppy), ret := "", r, i
DEFAULT yes_floppy TO .t.
tmp_drv := DISKNAME()
i := iif(yes_floppy, 1, ascan(ad,tmp_drv))
aeval(ad, {|x,k| ad[k] := " "+x+" " } )
r := nTop + (nBottom-nTop)/2 - 3
if (i := f_alert({"�롮� ��᪠"},ad,i,,,r)) > 0
  ret := alltrim(ad[i])
endif
return ret

***** ������ � ���ᨢ� ����� ����㯭�� ��᪮�
Function ret_arr_disk(yes_floppy)
Local arr := {}, k, i, d
DEFAULT yes_floppy TO .t.  // ����訢��� �� floppy-��᪮����
k := iif(yes_floppy, 65, 67)
for i := k to 90
  d := chr(i)
  if isdisk(d)
    aadd(arr,d)
  endif
next
return arr
