#include "function.ch"

***** определение количества лет по дате (возврат числа)
Function count_years(_mdate, _sys_date)
// _mdate    - дата для определения количества лет
// _sys_date - "системная" дата
Local k := 0, md := _mdate
if !empty(_sys_date) .and. !empty(_mdate) .and. _sys_date > _mdate
  do while (md := addmonth(md,12)) <= _sys_date
    k++
  enddo
endif
return k

*

***** 14.06.13 определение количества лет по дате (возврат строки)
Function ccount_years(_mdate, _sys_date)
// _mdate    - дата для определения количества полных лет
// _sys_date - "системная" дата
Local ret_s := "", y
if (y := count_years(_mdate, _sys_date)) > 0
  ret_s := lstr(y)+" "+s_let(y)
endif
return ret_s
