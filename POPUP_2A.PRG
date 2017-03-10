#include "inkey.ch"
#include "function.ch"

***** 17.01.14 popup_prompt по 2-мерному массиву {{"name","kod"},...}
Function popup_2array(arr,r1,c1,k,i_element,/*@*/ret_arr,ltitle,ltitle_color,lcolor)
// arr - двумерный массив
// r1,c1 - координаты левого верхнего угла меню
//   если r1 меньше нуля - то это вызов из GET-а с переопределением r1 и r2
// k - входящий код для поиска по второму подэлементу массива
// i_element = 1 {"name","kod"}, i_element = 2 {"kod","name"}
// ret_arr - в этот элемент заносится возвращаемый массив {"kod","name"}
Local i, mas_pmt := {}, ret := 0, i2 := 2, r, r2, c2, nr, nl := 0, buf, buf1
DEFAULT k TO 0, i_element TO 1
if i_element == 2
  i2 := 1
endif
nr := len(arr)
for i := 1 to nr
  aadd(mas_pmt,arr[i,i_element])
  nl := max(nl,len(arr[i,i_element]))
next
nl += 2
if r1 < 0
  r := abs(r1)
  if (r1 := r+1) > int(maxrow()/2)
    r2 := r-1
    if (r1 := r2-nr-1) < 2
      r1 := 2
    endif
  else
    r2 := r1 + nr + 1
  endif
else
  r2 := r1 + nr + 1
endif
c2 := c1 + nl + 1
if c2 > maxcol()-2
  c2 := maxcol()-2 ; c1 := maxcol()-3 - nl
endif
if c1 < 0 ; c1 := 0 ; endif
if r2 > maxrow()-2 ; r2 := maxrow()-2 ; endif
buf := save_box(r1,c1,r2+1,c2+2)
buf1 := save_maxrow()
i := ascan(arr, {|x| x[i2] == k })
status_key("^<Esc>^ - отказ;  ^<Enter>^ - выбор")
if (i := popup(r1,c1,r2,c2,mas_pmt,i,lcolor,.t.,,,ltitle,ltitle_color)) > 0
  ret := arr[i,i2]
  ret_arr := arr[i]
endif
rest_box(buf)
rest_box(buf1)
return ret
