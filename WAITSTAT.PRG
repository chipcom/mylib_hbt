/***
*  Реализует подвижный статус-индикатор, который может использоваться
*  для индикации того, что процесс действительно выполняется.
*/

#include "function.ch"

#define ST_LEN     5                       // Длина массива
#define ST_ROW     1                       // Строка индикатора на экране
#define ST_COL     2                       // Колонка индикатора на экране
#define ST_COLOR   3                       // Цвет индикатора
#define ST_TEXT    4                       // Строка перед индикатором
#define ST_CURRENT 5                       // Текущая позиция в массиве форм
                                           // индикатора
STATIC aDisplay := { "|", "/", "-", "\" }  // Массив символов - форм индикатора
Static aStat := { 24, 0, "15/4", "Подождите, работаю ...", 1 }
Static OldSec := 0

/***
*  WaitStatus( [stroke], [<nRow>], [<nCol>], [<cColor>] ) --> aStat
*  Создание нового индикатора
*  ( Если nCol == NIL, строка stroke центрируется )
*/
FUNCTION WaitStatus( stroke, nRow, nCol, cColor )
aStat[ ST_ROW     ] := 24
aStat[ ST_COL     ] := 0
aStat[ ST_COLOR   ] := cColorStMsg
aStat[ ST_TEXT    ] := "Подождите, работаю ..."
aStat[ ST_CURRENT ] := 1
OldSec := seconds()
IF cColor != NIL
  aStat[ ST_COLOR ] := cColor
ENDIF
IF stroke != NIL
  aStat[ ST_TEXT ] := stroke
ENDIF
IF nRow != NIL
  aStat[ ST_ROW ] := nRow
ENDIF
IF nCol == NIL
  aStat[ST_TEXT] := center(alltrim(aStat[ST_TEXT]), 80) + " "
  @ aStat[ST_ROW],0 say space(80) color aStat[ST_COLOR]
ELSE
  aStat[ ST_COL ] := nCol
ENDIF
IF !EMPTY(aStat[ ST_TEXT ])
  @ aStat[ST_ROW], aStat[ST_COL] say aStat[ST_TEXT] color aStat[ST_COLOR]
  aStat[ST_COL] += len( aStat[ST_TEXT] )
ENDIF
setcursor(0)
RETURN NIL

*****  Обновление индикатора
FUNCTION UpdateStatus()
Local s := seconds()
if s - OldSec > 0.2
  OldSec := s
  Inc( aStat[ ST_CURRENT ] )
  IF aStat[ ST_CURRENT ] > 4
    aStat[ ST_CURRENT ] := 1
  ENDIF
  @ aStat[ST_ROW],aStat[ST_COL] SAY aDisplay[ aStat[ST_CURRENT] ] ;
                                                color aStat[ST_COLOR]
endif
RETURN NIL
