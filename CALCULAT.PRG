#include "function.ch"
#include "inkey.ch"

Static many_9 := 9999999999999999999999
Static st_x := 46
Static st_y := 10
Static x_max := 46
Static y_max := 10
Static val_result := 0
Static calc_stack

*****
PROCEDURE calc(_p1,_p2,_p3)
PRIVATE op_old := "", buf, x := st_x, y := st_y, op := "", result := 0,;
        noerr := .t., num := "0",;
        tmp_color := SETCOLOR(cCalcMain),;
        tmp_row := ROW(), tmp_col := COL(), tek_sost,;
        tmp_help, tmp_nhelp, tmp_cursor := setcursor(0),;
        fl_mouse := IS_MOUSE_ON_SCREEN(), blocks
//tek_sost := CSETALL()
blocks := MY_SAVEKEY()
tmp_help := if(type("chm_help_code")=="N", chm_help_code, help_code)
chm_help_code := 1 // т.к. в chm-help "0" не работает
help_code := 0
// для новой HELP-системы
tmp_nhelp := ret_nhelp_code()
nhelp_code := "Calc"
x := IF(x > x_max, xmax, x)
y := IF(y > y_max, ymax, y)
if valtype(calc_stack) != "A"
  calc_stack := {}
endif
FT_MHIDECRS(fl_mouse)
disp_calc()
DO WHILE !(op $ "XE")
  DO c_getnum WITH num,op,x,y,op # "="
  IF op $ "=XEC"
    IF (op == "X" .AND. op_old != "=") .OR. op == "="
      result := VAL(num)
    ENDIF
    op_old := op
    @ y+2,x+2 SAY STR(result,21,4)
    LOOP
  ENDIF
  if !(num == "0" .and. op_old == "=")
    result := VAL(num)
  endif
  DO WHILE .t.
    op_old := op
    DO c_getnum WITH num,op,x,y,.f.
    IF op $ "XEC"
      EXIT
    ENDIF
    result := calculate(result,num,op_old)
    noerr := (result != many_9)
    @ y+2,x+2 SAY STR(result,21,4)
    put_stack(STR(result,21,4))
    IF op == "="
      op_old := op
      EXIT
    ENDIF
  ENDDO
ENDDO
@ tmp_row,tmp_col SAY ""
SETCOLOR(tmp_color)
//CSETALL(tek_sost)
RESTSCREEN(y,x,y+14,x+33,buf)
chm_help_code := help_code := tmp_help
nhelp_code := tmp_nhelp
st_x := x
st_y := y
MY_RESTKEY(blocks)
IF op == "X"
  if empty(_p3)
    val_result := result
    keyboard chr(K_SH_F2)
  elseif valtype(&_p3) == "N" .or. valtype(&_p3) == "C"
    if valtype(&_p3) == "C"
      &_p3 := dellastnul(result,4)
    else
      &_p3 := result
    endif
  endif
ENDIF
if tmp_cursor != 0
  setcursor()
else
  FT_MSHOWCRS(fl_mouse)
endif
RETURN

*****
Function retcalcval(p)
DEFAULT p TO "N"
if p == "C"
  return dellastnul(val_result,4)
endif
return val_result

*******
Static FUNCTION calculate(result,num,operator)
DO CASE
  CASE operator == "+"
    RETURN (result + VAL(num))
  CASE operator == "-"
    RETURN (result - VAL(num))
  CASE operator == "*"
    RETURN (result * VAL(num))
  CASE operator == "/"
    IF VAL(num) == 0
      ?? CHR(7)
      RETURN (many_9)
      noerr := .f.
    ELSE
      RETURN (result / VAL(num))
      noerr := .t.
    ENDIF
ENDCASE
RETURN 0

*******
PROCEDURE c_getnum
PARAMETERS num,op,x,y,cl
PRIVATE inp_dec := .f., mant_len := 1, dec_len := 0, ch, k := .f.
num := "0"
IF cl
  @ y+2,x+2 SAY STR(VAL(num),16,0) + "     "
ENDIF
DO WHILE .t.
  ch := c_getkey()
  if k .and. ch $ "0123456789."  // после выбора числа из стека
    ?? chr(7)                    // допускается только ввод какой-нибудь
    loop                         // операции
  endif
  DO CASE
    CASE ch $ "+-*/=XCE"           // русские C,Х  и английские C,X
      op := ch
      @ y+2,x+27 SAY ch
      EXIT
    CASE ch == "P"
      if (k := get_stack()) == NIL
        k := .f.
        loop
      else
        num := k
        @ y+2,x+2 SAY STR(VAL(num),21,4)
        @ y+2,x+27 SAY "П"
        dec_len := 4
        inp_dec := .t.
        k := .t.
      endif
    CASE ch == "B"
      num := "0"
      mant_len := 1
      dec_len := 0
      inp_dec := .f.
      @ y+2,x+2 SAY STR(VAL(num),16,0) + "     "
    CASE ch == "I"
      num := IF((inp_dec .AND. dec_len == 0), ;
                 LSTR(-VAL(num),16,0) + ".", LSTR(-VAL(num),16,dec_len))
    CASE ch == "."
      IF inp_dec
        ?? CHR(7)
      ELSE
        num += "."
        inp_dec := .t.
      ENDIF
    OTHERWISE
      IF !inp_dec
        IF num == "0"
          num := ch
        ELSE
          IF mant_len == 10
            ?? CHR(7)
          ELSE
            num += ch
            mant_len++
          ENDIF
        ENDIF
      ELSE
        IF dec_len == 4
          ?? CHR(7)
        ELSE
          num += ch
          dec_len++
        ENDIF
      ENDIF
  ENDCASE
  IF inp_dec
    IF dec_len == 0
      @ y+2,x+2 SAY STR(VAL(num),16) + ".    "
    ELSE
      @ y+2,x+2 SAY STR(VAL(num),17+dec_len,dec_len) + SPACE(4-dec_len)
    ENDIF
  ELSE
    @ y+2,x+2 SAY STR(VAL(num),16) + "     "
  ENDIF
ENDDO
put_stack(num)
RETURN

******
Static FUNCTION c_getkey
Local i, c, ch
DO WHILE .t.
  DO WHILE .t.
    c := INKEYTRAP(0)
    IF eq_any(c,K_UP,K_DOWN,K_LEFT,K_RIGHT,K_CTRL_LEFT,K_CTRL_RIGHT,K_HOME,K_END)
      mov_calc(c)
    ELSEIF c == K_F1
      if (i := ascan(blocks,{|x| x[1]==K_F1 })) > 0
        setkey(blocks[i,1],blocks[i,2])
      endif
    ELSEIF c == K_ALT_F2
      ?? CHR(7)
    ELSE
      EXIT
    ENDIF
  ENDDO
  ch := upper(CHR(c))
  do case // проверим нажатие на русские аналоги клавиш
    case ch == "Х"
      ch := "X"
    case ch == "С"
      ch := "C"
    case ch == "И"
      ch := "I"
    case ch == "П" .or. ch == "Р"
      ch := "P"
  endcase
  DO CASE
    CASE ch $ "0123456789+-*/=IXCP."
      RETURN ch
    CASE c == K_BS .or. c == K_DEL
      RETURN "B"
    CASE ch == ","
      RETURN "."
    CASE c == K_ENTER
      RETURN "="
    CASE c == K_ESC
      RETURN "E"
    OTHERWISE
      ?? CHR(7)
  ENDCASE
ENDDO
return "E"

*******
Static Function disp_calc()
buf := SAVESCREEN(y,x,y+14,x+33)
put_shadow(y,x,y+13,x+31)
@ y+ 0,x SAY "╔══════════════════════════════╗"
@ y+ 1,x SAY "╟───────────────────────┬─────┐║"
@ y+ 2,x SAY "║                0      │     │║"
@ y+ 3,x SAY "╟─────────────────┬─────┴─────┤║"
@ y+ 4,x SAY "║  <Esc> - выход  │ BackSpace │║"
@ y+ 5,x SAY "╟─────┬─────┬─────┼─────┬─────┤║"
@ y+ 6,x SAY "║  7  │  8  │  9  │  +  │   │║"
@ y+ 7,x SAY "╟─────┼─────┼─────┼─────┼─────┤║"
@ y+ 8,x SAY "║  4  │  5  │  6  │  -  │   │║"
@ y+ 9,x SAY "╟─────┼─────┼─────┼─────┼─────┤║"
@ y+10,x SAY "║  1  │  2  │  3  │  *  │=+-*/│║"
@ y+11,x SAY "╟─────┼─────┼─────┼─────┼─────┤║"
@ y+12,x SAY "║  0  │  .  │  П  │  /  │Enter│║"
@ y+13,x SAY "╚═════╧═════╧═════╧═════╧═════╧╝"
RETURN NIL

******
Static FUNCTION mov_calc(c)
Local x1 := x, y1 := y, fl := .t., buf2 := savescreen(y+2,x,y+2,x+30)
DO CASE
  CASE c == K_UP .AND. y > 0
    Dec(y1)
  CASE c == K_DOWN .AND. y < y_max
    Inc(y1)
  CASE c == K_LEFT .AND. x > 0
    Dec(x1)
  CASE c == K_RIGHT .AND. x < x_max
    Inc(x1)
  CASE c == K_CTRL_LEFT .and. x != 0
    x1 := 0
  CASE c == K_CTRL_RIGHT .and. x != x_max
    x1 := x_max
  CASE c == K_HOME .and. y != 0
    y1 := 0
  CASE c == K_END .and. y != y_max
    y1 := y_max
  OTHERWISE
    fl := .f.
ENDCASE
if fl
  RESTSCREEN(y,x,y+14,x+33,buf)
  x := x1 ; y := y1
  disp_calc()
  restscreen(y+2,x,y+2,x+30,buf2)
endif
RETURN NIL

******
Static Function put_stack(mnum)
if mnum != "0" .and. ascan(calc_stack,num_size20(mnum)) == 0
  mnum := num_size20(mnum)
  if (ch := len(calc_stack)) == 0
    aadd(calc_stack,mnum)
  else
    if ch < 10
      aadd(calc_stack,"")
    endif
    ains(calc_stack,1)
    calc_stack[1] := mnum
    if ch < 10
      asize(calc_stack,ch+1)
    endif
  endif
endif
RETURN NIL

*****
Static Function get_stack()
Local k, arr := {}, arr1 := {{1,"Выбор числа из стека"}}
if (k := len(calc_stack)) > 0
  aeval(calc_stack, { | x | aadd(arr,{x}) } )
  if (k := Arrn_Browse(0,0,k+3,21,arr,arr1,1,,cCalcMain)) > 0
    return calc_stack[k]
  endif
endif
RETURN NIL

*****
Static Function num_size20(mn)
Local c, s := str(val(mn),20,4)
do while (c := right(s,1)) == "0" .or. c == "."
  s := substr(s,1,len(s)-1)
  if c == "." ; exit ; endif
enddo
return padr(s,20)
