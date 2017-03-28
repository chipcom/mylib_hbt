#include "inkey.ch"
#include "function.ch"

***** 27.03.17 бегущая строка
Function RunStr(CString,NRow,NCol1,NCol2,CColor,NInterval,NDelay)
//  CString   - содержание бегущей строки
//  NRow      - номер строки
//  NCol1     - левая граница (по умолчанию 0)
//  NCol2     - правая граница (по умолчанию 80)
//  CColor    - цвет для вывода строки (по умолчанию текущий цвет)
//  NInterval - скорость сдвига в миллисекундах (по умолчанию 254 мс)
//  NDelay    - время ожидания в секундах (по умолчанию 0 - бесконечность)
Local len_string, width, tmp_color := setcolor(), s, i := 1, j, k,;
      fl_exit := .f., fl_delay, t_delay := 0, buf
DEFAULT NCol1 TO 0, NCol2 TO maxcol(), NInterval TO 112, NDelay TO 0
CString := alltrim(CString)
width := NCol2 - NCol1 + 1
if (len_string := len(CString)) < width
  CString := padr(CString,width)
else
  CString += "   "
endif
len_string := len(CString)
setcursor(0)
if CColor != NIL
  setcolor(CColor)
endif
@ NRow,NCol1 say space(width)
fl_delay := (NDelay > 0)
do while if(fl_delay, (NDelay > t_delay), .t.)
  if inkey() != 0
    fl_exit := .t.
    exit
  endif
  buf := savescreen(NRow,NCol1+1,NRow,NCol2)
  restscreen(NRow,NCol1,NRow,NCol2-1,buf)
  @ NRow,NCol2 say substr(CString,i,1)
  i++
  if i > len_string ; i := 1 ; endif
  if fl_delay
    t_delay += (NInterval/1000)
  endif
  Millisec(NInterval)
enddo
setcolor(tmp_color)
return if(fl_exit, lastkey(), 27)  // возврат последней нажатой клавиши

***** 27.03.17 вывод прямоугольника с сообщением (последняя строка - бегущая)
FUNCTION N_MESSAGE(cLine,;      // массив строк (максимум 6 строк)
                   arr_dop,;    // дополнительный массив строк (максимум 2 строки)
                   cBorColor,;  // строка цвета для рамки
                   cBoxColor,;  // строка цвета для текста
                   nStartRow,;  // верхний ряд рамки (99 - центировать)
                   nStartCol,;  // левая колонка рамки (99 - центрировать)
                   cRunColor)   // строка цвета для бегущей строки
DEFAULT arr_dop TO {"","Нажмите любую клавишу"}
aeval(arr_dop, {|x| aadd(cLine,x) } )
return F_MESSAGE(cLine, "W", cBorColor, cBoxColor, nStartRow, nStartCol, .t., cRunColor)
