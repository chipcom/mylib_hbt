#include "function.ch"

// Определение индексов массива
#define B_LEFT          1
#define B_BACKCOLOR     2
#define B_BARCOLOR      3
#define B_BARCHAR       4
#define B_PERCENT       5
#define B_SCREEN        6
#define B_LEN           6

***** определение индикатора
FUNCTION ThermoNew( nLeft, cColor )
LOCAL aHandle[B_LEN]
DEFAULT nLeft TO 68
aHandle[B_LEFT]       := nLeft
aHandle[B_BACKCOLOR]  := color0
aHandle[B_BARCOLOR]   := color0
aHandle[B_BARCHAR]    := CHR(219)
aHandle[B_PERCENT]    := 0

// Проверка передаваемых параметров
IF cColor <> NIL .and. valtype(cColor) == "A"
  aHandle[B_BARCOLOR]   := cColor[1]
  aHandle[B_BACKCOLOR]  := cColor[2]
ENDIF

// Проверка корректности границ окна для помещения на экране
IF aHandle[B_LEFT] > 68
  aHandle[B_LEFT] := 68
ENDIF
aHandle[B_SCREEN] := save_box(0, aHandle[B_LEFT], 24, aHandle[B_LEFT]+10)
RETURN( aHandle )

/***
*  ThermoDisplay( aGauge ) --> aGauge
*  Отображение индикатора на экране в соответствии со значениями из массива
*/
FUNCTION ThermoDisplay( aHandle )
LOCAL cOldColor := SETCOLOR( aHandle[ B_BACKCOLOR ] )
PUT_SHADOW(2,aHandle[B_LEFT],22,aHandle[B_LEFT]+8)
@  2,aHandle[B_LEFT] say "╔═══════╗"
@  3,aHandle[B_LEFT] say "║100%┬──╫"
@  4,aHandle[B_LEFT] say "║  . │──║"
@  5,aHandle[B_LEFT] say "║  . │──║"
@  6,aHandle[B_LEFT] say "║ 83%┼──╫"
@  7,aHandle[B_LEFT] say "║  . │──║"
@  8,aHandle[B_LEFT] say "║  . │──║"
@  9,aHandle[B_LEFT] say "║ 67%┼──╫"
@ 10,aHandle[B_LEFT] say "║  . │──║"
@ 11,aHandle[B_LEFT] say "║  . │──║"
@ 12,aHandle[B_LEFT] say "║ 50%┼──╫"
@ 13,aHandle[B_LEFT] say "║  . │──║"
@ 14,aHandle[B_LEFT] say "║  . │──║"
@ 15,aHandle[B_LEFT] say "║ 33%┼──╫"
@ 16,aHandle[B_LEFT] say "║  . │──║"
@ 17,aHandle[B_LEFT] say "║  . │──║"
@ 18,aHandle[B_LEFT] say "║ 17%┼──╫"
@ 19,aHandle[B_LEFT] say "║  . │──║"
@ 20,aHandle[B_LEFT] say "║  . │──║"
@ 21,aHandle[B_LEFT] say "║  0%┴──╫"
@ 22,aHandle[B_LEFT] say "╚═══════╝"
SETCOLOR( cOldColor )
// Разрисовка линии для отображения текущего процентного соотношения
ThermoUpdate( aHandle, aHandle[B_PERCENT] )
RETURN( aHandle )

/***
*  ThermoUpdate( aHandle, nPercent ) --> aGauge
*  Обновление индикатора в соответствии с новым процентным соотношением
*/
FUNCTION ThermoUpdate( aHandle, nPercent )
LOCAL cOldColor := SETCOLOR( aHandle[B_BARCOLOR] )
LOCAL nBarRatio := 18
LOCAL nRows := 0
IF nPercent > 1 ; nPercent := 1 ; ENDIF
IF nPercent < 0 ; nPercent := 0 ; ENDIF
nRows := ROUND( nPercent * nBarRatio, 0 )
for i := 0 to nRows
  @ 21-i,aHandle[B_LEFT]+6 say aHandle[B_BARCHAR]+aHandle[B_BARCHAR]
next
SETCOLOR( cOldColor )
RETURN( aHandle )

***** Закрытие (уничтожение) индикатора
Function CloseThermo(aHandle)
rest_box(ahandle[B_SCREEN])
Return NIL
