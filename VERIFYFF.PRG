#include "inkey.ch"
#include "function.ch"

*****
Function Add_string(stroke)
DEFAULT stroke TO ""
Inc(tek_stroke)
fwrite(fp, stroke+eos)
return NIL

*****
Function next_list(n)
DEFAULT n TO 80
if n_list > 1
  add_string(padl("Лист "+lstr(n_list),n))
  add_string("")
endif
return NIL

*****
Function verify_FF(h, f_next_list, width, blk)
// проверить и, если необходимо, поставить символ перевода формата
// h           - кол-во строк на листе
// f_next_list - флаг, указывающий на необходимость вызова ф-ии next_list()
// width       - параметр для ф-ии next_list()
if tek_stroke > h
  DEFAULT f_next_list TO .f.
  VALDEFAULT blk,"B" TO {|| .t. }
  eval(blk)
  add_string(chr(12))
  tek_stroke := 0 ; Inc(n_list)
  if f_next_list
    next_list(width)
  endif
  return .t.
endif
return .f.
