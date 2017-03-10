#include "function.ch"

/*  образец ф-ии f_first()
FUNCTION f_first()
Public key_gas := K_SH_F10, sec_gas := 480, blk_gas
#ifdef PAROL
  blk_gas := {|| inp_password() }
#endif
//
SetKey( key_gas, {|p,l,v| gasilka(p, l, v, key_gas, sec_gas, blk_gas )} )
KeySec(key_gas,sec_gas,-1,.T.)
//
ksetnum(.t.)
RETURN NIL*/

***** гашение экрана
PROCEDURE gasilka(_p1,_p2,_p3,nKey,nsec,post_blk)
local flag1 := 0, bum := 0, trow, tcol, i, buf,;
      aaa := { '∙','.','+','*','.','.'},;
      BotRow := MaxRow(), BotCol := MaxCol()
Local CrVer := (botrow * botcol) / 32, tmp_color := setcolor(),;
      tmp_row := ROW(), tmp_col := COL(), tek_sost,;
      tmp_cursor := setcursor(0), fl_mouse := IS_MOUSE_ON_SCREEN(),;
      blocks := MY_SAVEKEY()
//tek_sost := CSETALL()
FT_MHIDECRS(fl_mouse)
KeySec()
buf := savescreen()
FillScreen(" ","W/N")
keyboard chr(0)
do while inkey() == 0
  trow:=random() % BotRow + 1
  tcol:=random() % BotCol + 1
  if screenstr(TROW,TCOL,1) == CHR(249)+chr(3)
    if bum < 5
      strscreen(CHR(249)+Chr(11),trow,tcol)
      millisec(150)
      strscreen(' '+Chr(0),trow,tcol)
      flag1++ ; bum++
    else
      for i := 1 to 6
        strscreen(aaa[i]+Chr(15),trow,tcol)
        millisec(150)
      next
      millisec(150)
      strscreen(' '+Chr(0),trow,tcol)
      flag1++ ; bum := 0
    endif
  else
    flag1++
  endif
  if flag1 > CrVer
    strscreen(CHR(249)+Chr(3),trow,tcol)
    flag1 := 0
  endif
enddo
if post_blk != NIL
  eval(post_blk)  // выполнить блок кода (например, ввод пароля)
endif
KeySec(nKey,nsec,-1,.T.)
restscreen(buf)
@ tmp_row,tmp_col SAY ""
SETCOLOR(tmp_color)
//CSETALL(tek_sost)
MY_RESTKEY(blocks)
if tmp_cursor != 0
  setcursor()
else
  FT_MSHOWCRS(fl_mouse)
endif
RETURN
