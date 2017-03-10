#include "inkey.ch"
#include "function.ch"

*****
Function need_index(blk)
Local i, k, arr_f := {}
Local fl := .f., buf, r1 := 8, r2 := 17
if valtype(blk) != "B"
  err_msg("Неверный вызов функции Need_Index()")
endif
scanfiles("", "*.", {| x | aadd(arr_f,x) } )
k := len(arr_f)
for i := k to 1 step -1
  if filesize(arr_f[i],32) != 0
    adel(arr_f,i) ; k--
  endif
next
if k > 0
  set cursor off
  FillScreen(p_char_screen,p_color_screen)
  buf := box_shadow(r1,5,r2,74,,"Предупреждение!",color8)
  setcolor(color8)
  str_center(r1+2,"Последний раз при выходе из задачи был сбой по питанию.")
  str_center(r1+3,"После подтверждения этого режима все базы данных")
  str_center(r1+4,"будут переиндексированы, т.к. вполне вероятно, что")
  str_center(r1+5,"некоторые индексные файлы были испорчены или разрушены.")
  setcolor(color1)
  str_center(r2-2,"Выберите действие:")
  setmtcolor("BG+/B,W+/R,GR+/B,GR+/R")
  @ r2-1,13 prompt " ~Выход из задачи "
  @ r2-1,32 prompt " ~Подтверждение переиндексирования "
  i := 2
  menu to i
  fl := (i == 2)
  setcolor(color0)
  if i == 2
    eval(blk)
    for i := 1 to k
      delete file (arr_f[i])
    next
  else
    f_end()
  endif
  FillScreen(p_char_screen,p_color_screen)
  setcolor(color0)
endif
return NIL
