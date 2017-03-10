#include "function.ch"

*****
function yn_Read_arhiv()
Local buf, r1 := 6, r2 := 17, i, tmp_color := setcolor(color1)
buf := box_shadow(r1,5,r2,74,,"Чтение резервной копии с дискеты","W/B")
setcolor(color8)
str_center(r1+2,"Предупреждение!")
str_center(r1+3,"Этот режим предназначен для чтения с дискеты резервной копии")
str_center(r1+4,'всех баз данных, сохраненных ранее в режиме "Запись на дискету".')
str_center(r1+5,"После подтверждения этого режима все базы данных в текущем")
str_center(r1+6,"каталоге на жестком диске будут стерты, а затем с дискеты")
str_center(r1+7,"будут считаны старые базы данных.")
mark_keys({'"Запись на дискету"'},"G+/B")
setcolor(color1)
str_center(r2-2,"Выберите действие:")
setmtcolor("BG+/B,W+/R,GR+/B,GR+/R")
@ r2-1,15 prompt " ~Отказ от операции "
@ r2-1,36 prompt " ~Подтверждение копирования "
menu to i
setcolor(tmp_color)
rest_box(buf)
return (i == 2)
