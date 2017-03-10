#include "function.ch"
#include "edit_spr.ch"

***** битовое меню по двумерному массиву
Function bit_popup(r1,c1,in_array,ast_array,lcolor,i_element,titul,titul_color)
Local r2, c2, nr := 0, nl := 0, t_mas := {}, buf, buf1, i, out_array
DEFAULT r1 TO T_ROW, c1 TO T_COL+5, i_element TO 1
nr := len(in_array)
aeval(in_array, {|x| aadd(t_mas,x[i_element]), nl := max(nl,len(x[i_element])) } )
if ast_array == NIL
  ast_array := array(nr)
  aeval(in_array, {|x,i| ast_array[i] := .t. } )
endif
nl += 5
r2 := r1 + nr + 1
c2 := c1 + nl + 1
if c2 > 77
  c2 := 77 ; c1 := 76 - nl
  if c1 < 0 ; c1 := 0 ; endif
endif
if r2 > 22 ; r2 := 22 ; endif
buf := save_box(r1,c1,r2+1,c2+2)
buf1 := save_maxrow()
aeval(t_mas, {|x,i| t_mas[i] := if(ast_array[i], " * ", "   ")+t_mas[i] } )
status_key("^<Esc>^ отказ; ^<Enter>^ выбор; ^<Ins,+,->^ смена признака включения данной строки")
if popup(r1,c1,r2,c2,t_mas,,lcolor,.t.,"fmenu_reader",,titul,titul_color) > 0
  out_array := {}
  FOR i := 1 TO nr
    IF "*" == substr(t_mas[i],2,1)
      aadd(out_array,in_array[i])
    ENDIF
  NEXT
  if empty(out_array)
    out_array := NIL
  endif
endif
rest_box(buf)
rest_box(buf1)
return out_array
