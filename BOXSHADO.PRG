#include "function.ch"
#include "inkey.ch"

***** рамка с тенью (и заголовком)
Function box_shadow(r1,c1,r2,c2,mcolor,mtitle,titl_color,frame)
Local buf := save_box(r1,c1,r2+1,c2+2), tmp_color := setcolor()
DEFAULT mtitle TO "", frame TO 2
PUT_SHADOW(r1,c1,r2,c2)
if mcolor != NIL
  setcolor(mcolor)
endif
@ r1,c1 clear to r2,c2
do case
  case frame == 0
    // без рамки
  case frame == 1  // одинарная рамка по краю
    @ r1,c1 to r2,c2
  case frame == 2  // двойная рамка по краю
    @ r1,c1 to r2,c2 double
  case frame == 3  // одинарная рамка со сдвигом
    @ r1,c1+1 to r2,c2-1
  case frame == 4  // двойная рамка со сдвигом
    @ r1,c1+1 to r2,c2-1 double
endcase
if !empty(mtitle)
  mtitle := " "+left(alltrim(mtitle),c2-c1-3)+" "
  if titl_color != NIL
    setcolor(titl_color)
  endif
  @ r1,c1+(c2-c1+1-len(mtitle))/2 SAY mtitle
endif
setcolor(tmp_color)
return buf

***** 28.02.17 сохранить область экрана с координатами
Function SAVE_BOX(r1,c1,r2,c2)
if r1 < 0 ; r1 := 0 ; endif
if c1 < 0 ; c1 := 0 ; endif
if r2 > maxrow() ; r2 := maxrow() ; endif
if c2 > maxcol() ; c2 := maxcol() ; endif
return STR(r1,3)+STR(c1,3)+STR(r2,3)+STR(c2,3)+SAVESCREEN(r1,c1,r2,c2)

***** 28.02.17 сохранить строку экрана
Function SAVE_ROW(r1)
return SAVE_BOX(r1,0,r1,maxcol())

***** 28.02.17 восстановить область, сохраненную функциями box_shadow(), SAVE_BOX(), SAVE_ROW()
Function REST_BOX(b)
return RESTSCREEN(VAL(SUBSTR(b, 1,3)),;
                  VAL(SUBSTR(b, 4,3)),;
                  VAL(SUBSTR(b, 7,3)),;
                  VAL(SUBSTR(b,10,3)),SUBSTR(b,13))

***** отрисовать тень внизу и справа от прямоугольника
Function PUT_SHADOW(r1,c1,r2,c2)
colorwin(r2+1,c1+2,r2+1,c2+2,c__cw)
colorwin(r1+1,c2+1,r2+1,c2+2,c__cw)
return NIL
