#include "function.ch"

***** функция ввода пароля из программы
Function get_parol(r1,c1,r2,c2,ltip,color_say,color_get)
Local s := space(10), buf, buf24, tmp_color
DEFAULT r1 TO maxrow()-5, c1 TO int((maxcol()-36)/2), r2 TO maxrow()-3
DEFAULT ltip TO 0, c2 TO c1+36, color_say TO "W+/B", color_get TO "W+/R"
tmp_color := setcolor(color_say+","+color_get)
buf := box_shadow(r1,c1,r2,c2,,,,ltip)
buf24 := save_maxrow()
status_key("^<Esc>^ - выход из задачи;  ^<Enter>^ - подтверждение ввода пароля")
set confirm on
setcursor()
@ r1+1,c1+18 say s color color_get  // т.к. не работает get в выделенном цвете
s := upper(getsecret(s,r1+1,c1+10,,"Пароль:"))
setcursor(0)
set confirm off
rest_box(buf)
rest_box(buf24)
setcolor(tmp_color)
return s

***** вернуть в массиве мой пароль в русской и английской раскладке
Function my_parol(k)
Local ret := {"вЕ█╞Eg▒├","jS╟У╢╬i"}
DEFAULT k TO 1
if k == 2  // второй системный пароль
  //ret := {"└єажw)u╙╡"}
  ret := {"├·енu'├в"}
endif
return ret
