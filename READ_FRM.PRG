#include "fileio.ch"
#include "function.ch"
#include "edit_spr.ch"

***** считать экранную форму (.scr) из файла (.frm) и отобразить ее на экране
Function f_read_frm(mas_name,file_screen,clear_area)
// mas_name - указатель на массив
// file_screen - наименование файла экранного формата
Local i, k, fp, j, i1, i2, i3, tmp_color := setcolor()
DEFAULT clear_area TO {1,0,23,79,0}
Private tmp
if !("." $ file_screen)
  file_screen += ".frm"
endif
if (file_screen := search_file(file_screen)) == NIL
  return {}
endif
fp := fopen(file_screen, FO_READ + FO_SHARED)
read_int(fp)  //  кол-во экранов
k := read_int(fp)  // кол-во переменных
Private scr__1 := array(k)
tmp := space(10)
for j := 1 to k
  fread(fp, @tmp, 10)
  if (i1 := ascan(mas_name, ;
                  {|x| padr(upper(x[A__NAME]),10) == tmp})) == 0
    err_msg("В массиве нет поля базы данных - "+tmp)
  endif
  i2 := read_int(fp)  //  row
  i3 := read_int(fp)  //  col
  scr__1[j] := {i1,i2,i3}
next
k := read_int(fp)     //  кол-во процедур
Private proc__1 := {}
if k > 0
  proc__1 := array(k)
  afill(proc__1, "")
endif
for j := 1 to k
  if (i1 := read_int(fp)) > 0
    tmp := space(i1)
    fread(fp, @tmp, i1)
    proc__1[j] := tmp
  endif
next
k := read_int(fp)  //  кол-во строк в экранной форме
Private say__1 := array(k)
afill(say__1, "")
for j := 1 to k
  if (i1 := read_int(fp)) > 0
    tmp := space(i1)
    fread(fp, @tmp, i1)
    say__1[j] := tmp
  endif
next
fclose(fp)
setcolor(cDataCScr)
@ clear_area[1],clear_area[2] clear to clear_area[3],clear_area[4]
for i := 1 to len(say__1)
  @ i+clear_area[1],clear_area[2] say say__1[i]
next
for i := 1 to len(proc__1)
  tmp := proc__1[i]
  k := &tmp
next
setcolor(tmp_color)
return {scr__1,proc__1}

***** отобразить поля базы данных в соответствии с экранной формой
Function f_view_frm(mas_name, mas_two, clear_area)
Local scr__1 := mas_two[1], proc__1 := mas_two[2], i,j, ;
      tmp_color := setcolor(), shirina, vysota
DEFAULT clear_area TO {1,0,23,79,0}
Private tmp, tmp1, tmp2, mpic
shirina := clear_area[4]-clear_area[2]
vysota  := clear_area[3]-clear_area[1]-1
setcolor(cDataCSay)
for i := 1 to len(scr__1)
  j := scr__1[i,1]
  tmp1 := shirina + 1 - scr__1[i,3]
  tmp := mas_name[j,A__NAME]
  if (tmp2 := is_element(mas_name[j],A__FIND)) != NIL
    @ scr__1[i,2]+clear_area[1],clear_area[2]+scr__1[i,3]-1 say eval(tmp2,&tmp)
  else
    if mas_name[j,A__PICTURE] == NIL
      if type(tmp) == "C"
        mpic := if(len(&tmp) > tmp1, "@S"+lstr(tmp1), "")
      elseif mas_name[j,A__TYPE] == "N"
        mpic := replicate("9",mas_name[j,A__LEN])
        if mas_name[j,A__DEC] > 0
          mpic := stuff(mpic,len(mpic)-mas_name[j,A__DEC],1,".")
        endif
      else
        mpic := ""
      endif
    else
      mpic := mas_name[j,A__PICTURE]
    endif
    @ scr__1[i,2]+clear_area[1],clear_area[2]+scr__1[i,3]-1 say &tmp picture mpic
  endif
next
for i := 1 to len(proc__1)
  tmp := proc__1[i]
  k := &tmp
next
setcolor(tmp_color)
return NIL
