#include "inkey.ch"
#include "function.ch"

*****
Function calendar()
Local buf := savescreen(), tmp_color := setcolor(), myear := year(date()),;
      nKey := 0, fl_mouse := IS_MOUSE_ON_SCREEN(), tek_sost, ;
      tmp_help, tmp_nhelp, tek_row := ROW(), tek_col := COL(), ;
      blocks, k, tmp_gets
SAVE GETS TO tmp_gets
blocks := MY_SAVEKEY()
FT_MHIDECRS(fl_mouse)
//tek_sost := CSETALL()
// для старой HELP-системы
tmp_help := if(type("chm_help_code")=="N", chm_help_code, help_code)
chm_help_code := help_code := 11
// для новой HELP-системы
tmp_nhelp := ret_nhelp_code()
nhelp_code := "Calendar"
set cursor off
do while .t.
  if nKey != K_F1
    put_calendar(myear)
  endif
  nKey := inkeytrap(0)
  keyboard ""
  if nKey == K_UP .or. nKey == K_PGUP
    myear--
  elseif nKey == K_DOWN .or. nKey == K_PGDN
    myear++
  elseif nKey == K_F2
    if (k := input_value(18,20,20,59,color1,;
             "    Введите необходимый год",myear,"9999")) != NIL .and. k > 0
      myear := k
    endif
  elseif nKey != 0
    exit
  endif
  if !between(myear,1,2999)
    func_error(4,"Недопустимый год!")
    myear := year(date())
  endif
enddo
chm_help_code := help_code := tmp_help
nhelp_code := tmp_nhelp
restscreen(buf) ; setcolor(tmp_color)
@ tek_row,tek_col SAY ""
//CSETALL(tek_sost)
FT_MSHOWCRS(fl_mouse)
MY_RESTKEY(blocks)
RESTORE GETS FROM tmp_gets
return NIL

/*****
Function input_nedel(myear,ldate)
Local buf := savescreen(), tmp_color := setcolor()
Local ret_arr, mdate, i, arr := put_calendar(myear)
setcolor("N/W,GR+/R")
for i := 1 to len(arr)
  nw := arr[i,3] ; m := arr[i,4]
  if between(m,1,4)     ; r := 1
  elseif between(m,5,8) ; r := 9
  else                  ; r := 17
  endif
  if m % 4 == 1     ; c := 1
  elseif m % 4 == 2 ; c := 21
  elseif m % 4 == 3 ; c := 41
  else              ; c := 61
  endif
  @ r+1,c+2+(nw-1)*3 PROMPT put_val(arr[i,1,1],2) UP arr[i,5] DOWN arr[i,6]
next
ldate := Rbow(ldate)
i := ascan(arr, {|x| x[2] == ldate } )
menu to i
if i > 0
  mdate := arr[i,2]
  ret_arr := {mdate,mdate+6}
endif
restscreen(buf) ; setcolor(tmp_color)
return ret_arr*/

*****
Static Function put_calendar(myear)
Local arr := {}, mdate := ctod("01.01."+lstr(myear)), edate,;
      t_arr := {{0,0,0,0,0,0,0},nil,0,0,nil,nil,0}, t1_arr, d, w, m,;
      old_m := 0, nw, r, c, i, j, k, k1, k2, lcolor, is_red, bSaveHandler,;
      arr_d := {"Пн","Вт","Ср","Чт","Пт","Сб","Вс"},;
      mstr := "│                  │                   │                   │"
mywait()
edate := eoy(mdate)
t1_arr := aclone(t_arr)
do while mdate <= edate
  d := day(mdate)
  w := dow(mdate) ; w := if(w == 1, 7, w-1) // русский формат дней недели
  m := month(mdate)
  if old_m != m
    nw := 1 ; old_m := m
  endif
  t1_arr[1,w] := d
  if mdate == date()  // если это сегодняшняя дата
    t1_arr[7] := w
  endif
  // если Воскресенье или последний день месяца
  if w == 7 .or. d == lastdayom(mdate)
    t1_arr[2] := Rbow(mdate)
    t1_arr[3] := nw
    t1_arr[4] := m
    aadd(arr, aclone(t1_arr))
    t1_arr := aclone(t_arr)
    nw++  // номер недели в месяце
  endif
  mdate++
enddo
setcolor("B/W")
dispbegin()
cls
@ 0,0 say padc("Календарь на "+lstr(myear)+" год",80) color color0
@  1,0 say "──┬───── январь ─────┬───── февраль ─────┬─────── март ──────┬───── апрель ─────"
for i := 1 to 7
  @ 1+i,0 say arr_d[i]+mstr
next
@  9,0 say "──┼────── май ───────┼────── июнь ───────┼─────── июль ──────┼───── август ─────"
for i := 1 to 7
  @ 9+i,0 say arr_d[i]+mstr
next
@ 17,0 say "──┼──── сентябрь ────┼───── октябрь ─────┼────── ноябрь ─────┼──── декабрь ─────"
for i := 1 to 7
  @ 17+i,0 say arr_d[i]+mstr
next
t1_arr := array(12,2) ; afillall(t1_arr,0)
for i := 1 to len(arr)
  m := arr[i,4]
  t1_arr[m,1]++
next
for i := 1 to 12
  m := 0
  for j := 1 to i-1
    m += t1_arr[j,1]
  next
  t1_arr[i,2] := m
next
for i := 1 to len(arr)
  t_arr := arr[i,1] ; nw := arr[i,3] ; m := arr[i,4]
  if between(m,1,4)     ; r := 1
  elseif between(m,5,8) ; r := 9
  else                  ; r := 17
  endif
  if m < 9
    k := t1_arr[m+4]
    k1 := if(k[1] > nw, nw, k[1])
    arr[i,6] := k[2] + k1
  endif
  if m > 4
    k := t1_arr[m-4]
    k1 := if(k[1] > nw, nw, k[1])
    arr[i,5] := k[2] + k1
  endif
  if m % 4 == 1     ; c := 1
  elseif m % 4 == 2 ; c := 21
  elseif m % 4 == 3 ; c := 41
  else              ; c := 61
  endif
  for j := 1 to 7
    is_red := equalany(j,6,7)
    if type("p_arr_prazdnik") == "A"
     bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
     BEGIN SEQUENCE
       if (k := ascan(p_arr_prazdnik, {|x| x[1] == myear })) > 0 // год
         is_red := .f.
         for k1 := 1 to len(p_arr_prazdnik[k,2])
           if p_arr_prazdnik[k,2,k1,1] == m   // месяц
             for k2 := 1 to len(p_arr_prazdnik[k,2,k1,2])
               if p_arr_prazdnik[k,2,k1,2,k2] == t_arr[j]
                 is_red := .t.
               elseif p_arr_prazdnik[k,2,k1,2,k2] == -t_arr[j]
                 is_red := .f.
               endif
             next
           endif
         next
       endif
     END
     // Восстановление начальной программы обработки ошибок
     ERRORBLOCK(bSaveHandler)
    endif
    lcolor := if(is_red,"R/W","N/W")
    if arr[i,7] == j  // подсветить сегодня
      lcolor := "W+/B"
    endif
    @ r+j,c+2+(nw-1)*3 say put_val(t_arr[j],2) color lcolor
  next
next
dispend()
mark_keys(arr_d,"N/W")
mark_keys({"Вс"},"R/W")
return arr

***** вернуть дату дня начала недели (Понедельника)
Static Function Rbow(mdate)
Local n
do while dow(mdate) != 2
  mdate--
enddo
return mdate
