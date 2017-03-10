#include "inkey.ch"
#include "function.ch"

*****
Function input_diapazon(r1,c1,r2,c2,mcolor,mmsg,mvalue,mpicture,blk_valid)
// r1,c1,r2,c2 - размеры box'а
// mcolor      - цвет
// mmsg        - массив из двух (или трех) элементов сообщения
// mvalue      - массив значений для инициализации GET'ов
// mpicture    - массив PICTURE для ввода значений
// blk_valid   - блок кода для проверки введенных значений, например:
//       blk_valid := {|x,y| if(x > y, ;
//                  func_error(4,"Начальная дата больше конечной!"), .t.) }
//       (здесь x и y - первое и второе введенные значения)
Local buf, buf24, tmp_color
DEFAULT mcolor TO color0, mpicture TO {NIL,NIL}, blk_valid TO {||.t.}
if valtype(mmsg) != "A" .or. valtype(mvalue) != "A" .or. ;
                                        valtype(mpicture) != "A"
  func_error(4,"Аргументами функции INPUT_DIAPAZON должны быть массивы")
  return NIL
endif
tmp_color := setcolor(mcolor)
Private p1value := mvalue[1], p2value := mvalue[2]
buf := box_shadow(r1,c1,r2,c2)
buf24 := save_maxrow()
do while .t.
  @ r1+1,c1+2 say mmsg[1] get p1value picture mpicture[1]
  @ row(),col()+1 say mmsg[2] get p2value picture mpicture[2]
  if len(mmsg) == 3
    @ row(),col()+1 say mmsg[3]
  endif
  status_key("^<Esc>^ - отказ от ввода;  ^<Enter>^ - подтверждение ввода")
  myread({"confirm"})
  if lastkey() == K_ESC .or. eval(blk_valid,p1value,p2value)
    exit
  endif
enddo
setcolor(tmp_color)
rest_box(buf24)
rest_box(buf)
return if(lastkey() == K_ESC, NIL, {p1value,p2value})
