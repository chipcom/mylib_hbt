#include "function.ch"

***** 08.12.19 преобразовать дату в развернутую строку ("5 января 2007г.")
Function date_month(md,is_full_year,is_zero_day,is_in_quotes)
// is_full_year = .t. -> вместо "г." писать "года"
// is_zero_day  = .t. -> вместо "8 января" писать "08 января"
// is_in_quotes = .t. -> вместо '08 января' писать '"08" января'
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
  s += " "+month_r(md)+" "+lstr(year(md))+iif(is_full_year, " года", " г.")
else
  s := '"___" _________ 20___г.'
endif
return s
