#include "inkey.ch"
#include "function.ch"

***** 27.03.17 вывод прямоугольника с сообщением
FUNCTION F_MESSAGE(cLine,;      // массив строк (максимум 8 строк)
                   cRetWait, ;  // "W" - ждать нажатия любой клавиши (цифры - сколько секунд)
                   cBorColor,;  // строка цвета для рамки
                   cBoxColor,;  // строка цвета для текста
                   nStartRow,;  // верхний ряд рамки (99 - центрировать)
                   nStartCol,;  // левая колонка рамки (99 - центрировать)
                   fl_runstr,;  // последняя строка бегущая или нет
                   cRunColor)   // строка цвета для бегущей строки
LOCAL nLLen := 40, cOldColor, nLCol, nRCol, nTRow, nBRow, cSayStr, ;
      nSayRow, nSayCol, nNumRows, buf, icur := SetCursor(0), count_s, ;
      ndelay := 0, cMaxRow := maxrow(), cMaxCol := maxcol()
// определение параметров по умолчанию
cRetWait  := iif(ischar(cRetWait),   Upper(cRetWait), '')
cBorColor := iif(ischar(cBorColor),  cBorColor,       color0)
cBoxColor := iif(ischar(cBoxColor),  cBoxColor,       color0)
nStartRow := iif(isnumber(nStartRow),nStartRow,       99)
nStartCol := iif(isnumber(nStartCol),nStartCol,       99)
cLine     := iif(isarray(cLine),     cLine,           {cLine})
fl_runstr := iif(islogic(fl_runstr), fl_runstr,       .f.)
// если вместо буквы "W" второй параметр - цифра (в кавычках)
if !empty(cRetWait) .and. !(cRetWait == "W")
  ndelay := val(cRetWait)
  cRetWait := "W"
endif

nNumRows := Min(len(cLine),8)
cLine := asize(cLine,nNumRows)
aeval(cLine, {|x,i| cLine[i] := AllTrim(Left(x,cMaxCol-5))})
AEVAL(cLine, {|x,i| nLLen := Max(nLLen,Len(x))})
// вычисление координат углов
nLCol := if(nStartCol==99,Int((cMaxCol-3-nLLen)/2),Min(nStartCol,cMaxCol-5-nLLen))
nRCol := nLCol+nLLen+3
nTRow := if(nStartRow==99,INT((cMaxRow-nNumRows)/2),Min(nStartRow,cMaxRow-2-nNumRows))
nBRow := nTRow+nNumRows+1
count_s := len(cLine)
if fl_runstr
  Dec( count_s )
endif

cOldColor := SetColor(cBoxColor)
buf := save_box(nTRow,nLCol,nBRow+1,nRCol+2)
PUT_SHADOW(nTRow,nLCol,nBRow,nRCol)
@ nTRow,nLCol Clear to nBRow,nRCol
DispBox(nTRow,nLCol,nBRow,nRCol,2,cBorColor)
AEVAL(cLine, { |cSayStr,i| nSayRow := nTRow+i, nSayCol := nLCol+2+(nLLen-Int(Len(cSayStr)))/2,;
                           setpos(nSayRow,nSayCol), dispout(cSayStr);
             }, 1, count_s)
set cursor off
IF cRetWait == 'W'
  mybell(0.1,OK)
  if fl_runstr
    setcolor(cRunColor)
    nLLen := RUNSTR(atail(cLine),nTRow+count_s+1,nLCol+1,nRCol-1)
  else
    nLLen := Inkey_Mouse(ndelay)
  endif
  rest_box(buf)
ENDIF
SetColor(cOldColor)
if icur > 0
  SETCURSOR()
endif
RETURN nLLen
