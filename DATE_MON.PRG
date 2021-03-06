#include "function.ch"

***** 08.12.19 �८�ࠧ����� ���� � ࠧ������� ��ப� ("5 ﭢ��� 2007�.")
Function date_month(md,is_full_year,is_zero_day,is_in_quotes)
// is_full_year = .t. -> ����� "�." ����� "����"
// is_zero_day  = .t. -> ����� "8 ﭢ���" ����� "08 ﭢ���"
// is_in_quotes = .t. -> ����� '08 ﭢ���' ����� '"08" ﭢ���'
Local s := ""
DEFAULT is_full_year TO .f., is_zero_day TO .f., is_in_quotes TO .f.
if valtype(md) == "C"
  md := ctod(md)
endif
if valtype(md) == "D" .and. !empty(md)
  s := iif(is_zero_day, strzero(day(md),2), lstr(day(md)))
  if is_in_quotes
    s := '"'+s+'"'
  endif
  s += " "+month_r(md)+" "+lstr(year(md))+iif(is_full_year, " ����", " �.")
else
  s := '"___" _________ 20___�.'
endif
return s
