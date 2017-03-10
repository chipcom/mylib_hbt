#include "function.ch"
#include "inkey.ch"

***** 14.06.14 вывести окно с сообщением и ожидание нажатия <Esc> или <Enter>
FUNCTION f_Esc_Enter(j,fl)
LOCAL buf, i := 0, s := "", s1, s2, r1, r2, c1, c2, tmp_color := SETCOLOR(),;
      tmp_mas := { "записи", "удаления", "исправления"}
DEFAULT fl TO .f.
r1 := maxrow()-4 ; r2 := r1+3
c1 := 8 ; c2 := maxcol()-8
buf := box_shadow(r1,c1,r2,c2,cColorText)
SETCOLOR(cColorText)
if valtype(j) == "N" .and. between(j,1,len(tmp_mas))
  s := " "+tmp_mas[j]
elseif valtype(j) == "C"
  s := " "+alltrim(j)
endif
s1 := "Для подтверждения"+s+" нажмите <Enter>"
s2 := "<Esc> - отказ от"+s
str_center(r1+1,s1)
str_center(r1+2,s2)
if fl
  for j := 1 to 5
    keyboard ""     //  на всякий случай
    inkey(0.1)      //  для особо ответственных операций
  next
else
  keyboard ""
endif
SETCURSOR(0)
DO WHILE !(i == K_ENTER .OR. i == K_ESC)
  i := inkey(0)
ENDDO
if fl .and. type("p_f_Esc_Enter") == "L" .and. p_f_Esc_Enter
  box_shadow(r1,c1,r2,c2,cColorSt2Msg)
  SETCOLOR(cColorStMsg)
  s1 := "Для подтверждения"+s+" нажмите <Ctrl+F12>"
  s2 := "<Esc> - отказ от"+s
  str_center(r1+1,s1)
  str_center(r1+2,s2)
  j := 0
  DO WHILE !(j == K_CTRL_F12 .OR. j == K_ESC)
    j := inkey(0)
  ENDDO
  if j == K_CTRL_F12
    i := K_ENTER
  else
    i := K_ESC
  endif
endif
SETCOLOR(tmp_color)
REST_BOX(buf)
RETURN (i == K_ENTER)

***** 29.01.14
Function str_center(nline, cmsg, mcolor)
Local mdelay := 6, tmp_color := setcolor(mcolor)
if type("DELAY_SPRD") == "N"   // если определена переменная "DELAY_SPRD",
  mdelay := DELAY_SPRD         // установить новое время задержки
endif                          // при развертывании строки
if mdelay == 0
  @ nline,(maxcol()+1-len(cmsg))/2+1 SAY cmsg
else
  sayspread(cmsg, mdelay, nline)
endif
setcolor(tmp_color)
return NIL
