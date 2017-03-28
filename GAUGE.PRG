#include "function.ch"

// Определение индексов массива
#define B_TOP           1
#define B_LEFT          2
#define B_BOTTOM        3
#define B_RIGHT         4
#define B_BACKCOLOR     5
#define B_BARCOLOR      6
#define B_DISPLAYNUM    7
#define B_BARCHAR       8
#define B_PERCENT       9
#define B_TITUL        10
#define B_TITULCOLOR   11
#define B_SCREEN       12
#define B_CENTER       13
#define B_RATIO        14
#define B_LEN          14

#define B_BOXLINES      "┌─┐│┘─└│"

***** 27.03.17 определение индикатора
FUNCTION GaugeNew( nTop, nLeft, cColor, cTitul, cProcent )
LOCAL aHandle[B_LEN]
DEFAULT nTop TO maxrow()-4, nLeft TO 10, ctitul TO "", cProcent TO .f.
aHandle[B_TOP]        := nTop
aHandle[B_LEFT]       := nLeft
aHandle[B_BOTTOM]     := nTop+2
aHandle[B_RIGHT]      := maxcol()-nLeft
aHandle[B_BACKCOLOR]  := color0
aHandle[B_BARCOLOR]   := color0
aHandle[B_TITULCOLOR] := color0
aHandle[B_DISPLAYNUM] := .T.
aHandle[B_BARCHAR]    := CHR(219)
aHandle[B_PERCENT]    := 0
aHandle[B_TITUL]      := ctitul

// Проверка передаваемых параметров
IF cColor <> NIL .and. valtype(cColor) == "A"
  aHandle[B_BARCOLOR]   := cColor[1]
  aHandle[B_BACKCOLOR]  := cColor[2]
  aHandle[B_TITULCOLOR] := cColor[3]
ENDIF

// Проверка корректности границ окна для помещения на экране
IF aHandle[B_RIGHT] < aHandle[B_LEFT] + 4
  aHandle[B_RIGHT] := aHandle[B_LEFT] + 4
ENDIF
IF aHandle[B_BOTTOM] < aHandle[B_TOP] + 2
  aHandle[B_BOTTOM] := aHandle[B_TOP] + 2
ENDIF
// Проверка возможности расположения величины в скобках в вершине графы
IF aHandle[B_RIGHT] < aHandle[B_LEFT] + 9
  aHandle[B_DISPLAYNUM] := .F.
ENDIF
if aHandle[B_DISPLAYNUM]
  aHandle[B_DISPLAYNUM] := cProcent
endif
aHandle[B_SCREEN] := save_box(aHandle[B_TOP], 0, aHandle[B_TOP]+3, maxcol())
RETURN( aHandle )

***** 27.03.17 Отображение индикатора на экране в соответствии со значениями из массива
FUNCTION GaugeDisplay( aHandle )
LOCAL nCenter := (aHandle[B_RIGHT]-aHandle[B_LEFT]+1-8)/2+aHandle[B_LEFT]
LOCAL cOldColor := SETCOLOR( aHandle[ B_BACKCOLOR ] )
@ aHandle[B_TOP], aHandle[B_LEFT] CLEAR TO aHandle[B_BOTTOM], aHandle[B_RIGHT]
put_shadow(aHandle[B_TOP],aHandle[B_LEFT],aHandle[B_BOTTOM],aHandle[B_RIGHT])
@ aHandle[B_TOP], aHandle[B_LEFT], aHandle[B_BOTTOM], aHandle[B_RIGHT] BOX B_BOXLINES
@ aHandle[B_TOP]+1, aHandle[B_LEFT]+1 say ;
             replicate(chr(176),aHandle[B_RIGHT]-aHandle[B_LEFT]-1) ;
             color aHandle[B_BARCOLOR]
IF aHandle[B_DISPLAYNUM]
  @ aHandle[B_BOTTOM],nCenter SAY "[      ]"
ENDIF
IF !empty(aHandle[B_TITUL])
  setcolor(aHandle[B_TITULCOLOR])
  str_center(aHandle[B_TOP]," "+alltrim(aHandle[B_TITUL])+" ")
ENDIF
SETCOLOR( cOldColor )
// Разрисовка линии для отображения текущего процентного соотношения
aHandle[B_CENTER]  := nCenter+2
aHandle[B_RATIO]   := (aHandle[B_RIGHT]) - (aHandle[B_LEFT] + 1)
GaugeUpdate( aHandle, aHandle[B_PERCENT] )
RETURN( aHandle )

***** 27.03.17 Обновление индикатора в соответствии с новым процентным соотношением
FUNCTION GaugeUpdate( aHandle, nPercent )
LOCAL cOldColor := SETCOLOR( aHandle[B_BARCOLOR] ), nRow, nCols
if nPercent != aHandle[B_PERCENT]
  IF nPercent > 1 ; nPercent := 1 ; ENDIF
  IF nPercent < 0 ; nPercent := 0 ; ENDIF
  aHandle[B_PERCENT] := nPercent
  IF aHandle[B_DISPLAYNUM]
    @ aHandle[B_BOTTOM],aHandle[B_CENTER] SAY STR(nPercent*100,3)+"%"
  ENDIF
  nCols := ROUND( nPercent * aHandle[B_RATIO], 0 )
  FOR nRow := 1 TO (aHandle[B_BOTTOM]-aHandle[B_TOP]-1)
    @ nRow+aHandle[B_TOP],aHandle[B_LEFT]+1 SAY REPLICATE(aHandle[B_BARCHAR],nCols)
  NEXT
endif
SETCOLOR( cOldColor )
RETURN( aHandle )

***** Закрытие (уничтожение) индикатора
Function CloseGauge(aHandle)
rest_box(ahandle[B_SCREEN])
Return NIL
