// Собственная реализация MENU TO
// Особенности:
//  - выделение цветом "горячей" клавиши (с возможностью ее нажатия)
//  - использование мыши
//  - возможность установления необходимого порядка обхода опций меню
//
#include "set.ch"
#include "inkey.ch"
#include "error.ch"
#include "function.ch"

Static AMenuTo := {}
Static MT_color1 := ""
Static MT_color2 := ""
Static MT_color3 := ""
Static MT_color4 := ""

#define MT_PROW        1
#define MT_PCOL        2
#define MT_PCOL2       3
#define MT_PROMPT      4
#define MT_HOTKEY      5
#define MT_HOTKEYPOS   6
#define MT_MROW        7
#define MT_MCOL        8
#define MT_MCOL2       9
#define MT_MESSAGE    10
#define MT_MCOLOR     11
#define MT_UP         12
#define MT_DOWN       13
#define MT_RIGHT      14
#define MT_LEFT       15

#define MT_LEN        15

***** установить цвета для MENU TO
Function SETMTCOLOR(scolor)
Local i, n := numtoken(scolor,",")
if n > 0
  MT_color1 := token(scolor,",",1)  // основной цвет
  MT_color2 := token(scolor,",",2)  // выделенный цвет
  MT_color3 := token(scolor,",",3)  // основной цвет горячей клавиши
  MT_color4 := token(scolor,",",4)  // выделенный цвет горячей клавиши
endif
RETURN NIL

***** сохранение массива MENU TO в локальном массиве
Function SaveMenuTo()
Local arr := {AMenuTo,MT_color1,MT_color2,MT_color3,MT_color4}
AMenuTo := {}
MT_color1 := MT_color2 := MT_color3 := MT_color4 := ""
Return arr

***** восстановление массива MENU TO из локального массива
Function RestMenuTo(arr)
AMenuTo   := arr[1]
MT_color1 := arr[2]
MT_color2 := arr[3]
MT_color3 := arr[4]
MT_color4 := arr[5]
Return NIL

***** реализация PROMPT
function FT_Prompt( nPRow, nPCol, cPrompt, ;
                    nMRow, nMCol, cMessage, cMColor, ;
                    nUp, nDown, nRight, nLeft )
// nPRow - ряд для prompt
// nPCol - колонка для prompt
// cPrompt - текст для prompt
// nMRow - ряд для message
// nMCol - колонка для message
// cMessage - текст message
// cMColor - цвет для message
// nUp, nDown, nRight, nLeft - номер prompt'а, к которому осуществляется
//                             переход при нажатии соответствующих клавиш
Local arr[MT_LEN], chotkey := 0, nhotkeypos := 0, i
//
VALDEFAULT nPRow,"N" TO 0, nPCol,"N" TO 0, cPrompt,"C" TO "",;
           cMessage,"C" TO "", nMRow,"N" TO set(_SET_MESSAGE),;
           nMCol,"N" TO if(set(_SET_MCENTER), int((80-len(cMessage))/2), 0),;
           cMColor,"C" TO "", ;
           nUp,"N" TO 0, nDown,"N" TO 0, nRight,"N" TO 0, nLeft,"N" TO 0
//
if (i := at('~', cPrompt)) > 0
  chotkey := asc(upper(substr(cPrompt,i+1,1)))
  nhotkeypos := i
  cPrompt := stuff(CPrompt,i,1,"")
endif
if len(cMessage) > 80
  cMessage := left(cMessage,80)
  nMcol := 0
endif
//
arr[MT_PROW]      := nPRow
arr[MT_PCOL]      := nPCol
arr[MT_PCOL2]     := nPCol+len(cPrompt)-1
arr[MT_PROMPT]    := cPrompt
arr[MT_HOTKEY]    := chotkey
arr[MT_HOTKEYPOS] := nhotkeypos
arr[MT_MROW]      := nMRow
arr[MT_MCOL]      := nMCol
arr[MT_MCOL2]     := nMCol+len(cMessage)-1
arr[MT_MESSAGE]   := cMessage
arr[MT_MCOLOR]    := cMColor
arr[MT_UP]        := nUp
arr[MT_DOWN]      := nDown
arr[MT_RIGHT]     := nRight
arr[MT_LEFT]      := nLeft
//
aadd(AMenuTo, aclone(arr))
return NIL

***** реализация MENU TO
function FT_MenuTo( bReadvar, cReadVar, arr_mouse, bBlock  )
// bReadvar - {|_1| IIF( _1 == NIL, <var>, <var> := _1 ) }
// cReadVar - имя переменной в выражении MENU TO
// arr_mouse - массив областей для мыши
// bBlock - блок кода для обработки прочих клавиш
Local nKey, i, lwrap := set(_SET_WRAP), lCont := .t., fl_exit := .f., ;
      tmp_color := setcolor(), nActive := 1, nOld, bErrorsys, ;
      oError, COUNT := len(AMenuTo), buf, fl := .t., fl_mess, ;
      fl_mouse, x_mouse := 0, y_mouse := 0, km, old_i, ;
      nsec := seconds(), period := 300
Local cStdColor := token(tmp_color,",",1), cEnhColor := token(tmp_color,",",2)
if type("MenuTo_Minut") == "N"
  period := int(MenuTo_Minut * 60)
endif
if COUNT == 0
  return 0  // выход, если не было prompt'ов
endif
if empty(MT_color1)
  MT_color1 := cStdColor
endif
if empty(MT_color2)
  MT_color2 := cEnhColor
endif
if empty(MT_color3)
  MT_color3 := cStdColor
endif
if empty(MT_color4)
  MT_color4 := cEnhColor
endif
if valtype(bReadvar) != "B"
  nActive := 1
else
  bErrorsys := Errorblock( {|e| Break(e) } )
  BEGIN SEQUENCE
    nActive := Eval(bReadvar)
  RECOVER USING oError
    IF oError:gencode == EG_NOVAR
      nActive := 1
    ELSE
      Eval(bErrorsys,oError)
    ENDIF
  END SEQUENCE
  Errorblock(bErrorsys)
endif
if valtype(nActive) != "N" .or. nActive < 1 .or. nActive > COUNT
  nActive := 1
endif
for i := 1 to COUNT
  @ AMenuTo[i,MT_PROW],AMenuTo[i,MT_PCOL] ;
                  say AMenuTo[i,MT_PROMPT] color MT_color1
  if AMenuTo[i,MT_HOTKEYPOS] > 0
    colorwin(AMenuTo[i,MT_PROW],;
             AMenuTo[i,MT_PCOL]+AMenuTo[i,MT_HOTKEYPOS]-1,;
             AMenuTo[i,MT_PROW],;
             AMenuTo[i,MT_PCOL]+AMenuTo[i,MT_HOTKEYPOS]-1,;
             MT_color3)
  endif
  if empty(AMenuTo[i,MT_MCOLOR])
    AMenuTo[i,MT_MCOLOR] := MT_color1
  endif
next
fl_mouse := SETPOSMOUSE()
old_i := nActive
setcursor(0)
DO WHILE lCont
  if fl
    colorwin(AMenuTo[nActive,MT_PROW],AMenuTo[nActive,MT_PCOL],;
             AMenuTo[nActive,MT_PROW],AMenuTo[nActive,MT_PCOL2],MT_color2)
    if AMenuTo[nActive,MT_HOTKEYPOS] > 0
      colorwin(AMenuTo[nActive,MT_PROW],;
               AMenuTo[nActive,MT_PCOL]+AMenuTo[nActive,MT_HOTKEYPOS]-1,;
               AMenuTo[nActive,MT_PROW],;
               AMenuTo[nActive,MT_PCOL]+AMenuTo[nActive,MT_HOTKEYPOS]-1,;
               MT_color4)
    endif
    if (fl_mess := !empty(AMenuTo[nActive,MT_MESSAGE]))
      buf := savescreen(AMenuTo[nActive,MT_MROW],AMenuTo[nActive,MT_MCOL], ;
                        AMenuTo[nActive,MT_MROW],AMenuTo[nActive,MT_MCOL2])
      @ AMenuTo[nActive,MT_MROW],AMenuTo[nActive,MT_MCOL] ;
          say AMenuTo[nActive,MT_MESSAGE] color AMenuTo[nActive,MT_MCOLOR]
    endif
    FT_MSHOWCRS(fl_mouse)
  endif
  if fl_exit
    exit
  endif
  nOld := nActive
  nKey := 0
  /*if fl_mouse
    if (km := FT_MGETPOS()) == 2
      nKey := K_ESC
    elseif km == 1
      x_mouse := FT_MGETX() ; y_mouse := FT_MGETY()
      if (i := ascan(AMenuTo, {|x| x[MT_PCOL] <= x_mouse .and. ;
                 x_mouse <= x[MT_PCOL2] .and. y_mouse == x[MT_PROW]})) > 0
        nActive := i ; nKey := 256
        clear_mouse()
        if old_i == nActive
          fl_exit := .t.
        else
          old_i := nActive
        endif
      elseif arr_mouse != NIL
        if (i := ascan(arr_mouse, {|x| between(x_mouse,x[2],x[4]) .and. ;
                                         between(y_mouse,x[1],x[3])})) > 0
          clear_mouse()
          //aeval(arr_mouse[i,5], {|x| keysend(x,.t.)})
        endif
      endif
    endif
  endif*/
  if nKey == 0
    nKey := INKEYTRAP()
  endif
  if nKey == 0
    if period > 0 .and. seconds() - nsec > period
      // если не трогали клавиатуру [period] сек., то выйти из функции
      nKey := K_ESC
    endif
  else
    nsec := seconds()
  endif
  do case
    case nKey == K_UP .or. nKey == K_SH_TAB
      if AMenuTo[nActive,MT_UP] > 0 .and. AMenuTo[nActive,MT_UP] <= COUNT
        nActive := AMenuTo[nActive,MT_UP]
      else
        Dec(nActive)
        if nActive == 0
          nActive := if(lwrap, COUNT, 1)
        endif
      endif
    case nKey == K_DOWN .or. nKey == K_TAB
      if AMenuTo[nActive,MT_DOWN] > 0 .and. AMenuTo[nActive,MT_DOWN] <= COUNT
        nActive := AMenuTo[nActive,MT_DOWN]
      else
        Inc(nActive)
        if nActive > COUNT
          nActive := if(lwrap, 1, COUNT)
        endif
      endif
    case nKey == K_LEFT
      if AMenuTo[nActive,MT_LEFT] > 0 .and. AMenuTo[nActive,MT_LEFT] <= COUNT
        nActive := AMenuTo[nActive,MT_LEFT]
      else
        Dec(nActive)
        if nActive == 0
          nActive := if(lwrap, COUNT, 1)
        endif
      endif
    case nKey == K_RIGHT
      if AMenuTo[nActive,MT_RIGHT] > 0 .and. AMenuTo[nActive,MT_RIGHT]<=COUNT
        nActive := AMenuTo[nActive,MT_RIGHT]
      else
        Inc(nActive)
        if nActive > COUNT
          nActive := if(lwrap, 1, COUNT)
        endif
      endif
    case nKey == K_PGUP .or. nKey == K_HOME
      nActive := 1
    case nKey == K_PGDN .or. nKey == K_END
      nActive := COUNT
    case nKey == K_ENTER .or. nKey == K_ESC
      lCont := .f.
    case between(nKey,48,255)
      nKey := asc(upper(chr(nKey)))
      if (i := ascan(AMenuTo, {|x| x[MT_HOTKEY] == nKey})) > 0
        nActive := i
        fl_exit := .t.
      endif
    case bBlock != NIL
      FT_MHIDECRS(fl_mouse)
      lCont := eval(bBlock,nKey,nActive)
  endcase
  if (fl := (lCont .and. nOld != nActive))
    FT_MHIDECRS(fl_mouse)
    colorwin(AMenuTo[nOld,MT_PROW],AMenuTo[nOld,MT_PCOL],;
             AMenuTo[nOld,MT_PROW],AMenuTo[nOld,MT_PCOL2],MT_color1)
    if AMenuTo[nOld,MT_HOTKEYPOS] > 0
      colorwin(AMenuTo[nOld,MT_PROW],;
               AMenuTo[nOld,MT_PCOL] + AMenuTo[nOld,MT_HOTKEYPOS] - 1,;
               AMenuTo[nOld,MT_PROW],;
               AMenuTo[nOld,MT_PCOL] + AMenuTo[nOld,MT_HOTKEYPOS] - 1,;
               MT_color3)
    endif
    if fl_mess
      restscreen(AMenuTo[nOld,MT_MROW],AMenuTo[nOld,MT_MCOL], ;
                        AMenuTo[nOld,MT_MROW],AMenuTo[nOld,MT_MCOL2],buf)
    endif
  endif
ENDDO
if fl_mouse
  clear_mouse()
  FT_MHIDECRS()
endif
AMenuTo := {}
MT_color1 := MT_color2 := MT_color3 := MT_color4 := ""
setcolor(tmp_color)
return if(nKey == K_ESC, 0, nActive)

*

*****
Function inkeytrap(nSec,nEvent)
Local nKey := 0
DEFAULT nSec TO 0 // теперь больше не выходим из меню через 5 минут
do while nKey == 0
  nKey := inkey(nSec,nEvent)
  if nKey != 0 .and. valtype(setkey(nKey)) == "B"
    nKey := eval(setkey(nKey))
    if !(valtype(nKey) == "N")
      nKey := 0 // и снова опрос inkey
    endif
  endif
enddo
return nKey
