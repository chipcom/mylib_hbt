#include "function.ch"

***** ��।������ ������⢠ ��� �� ��� (������ �᫠)
Function count_years(_mdate, _sys_date)
// _mdate    - ��� ��� ��।������ ������⢠ ���
// _sys_date - "��⥬���" ���
Local k := 0, md := _mdate
if !empty(_sys_date) .and. !empty(_mdate) .and. _sys_date > _mdate
  do while (md := addmonth(md,12)) <= _sys_date
    k++
  enddo
endif
return k

*

***** 14.06.13 ��।������ ������⢠ ��� �� ��� (������ ��ப�)
Function ccount_years(_mdate, _sys_date)
// _mdate    - ��� ��� ��।������ ������⢠ ������ ���
// _sys_date - "��⥬���" ���
Local ret_s := "", y
if (y := count_years(_mdate, _sys_date)) > 0
  ret_s := lstr(y)+" "+s_let(y)
endif
return ret_s
