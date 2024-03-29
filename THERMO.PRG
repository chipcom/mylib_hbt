#include 'function.ch'

// ��।������ �����ᮢ ���ᨢ�
#define B_LEFT          1
#define B_BACKCOLOR     2
#define B_BARCOLOR      3
#define B_BARCHAR       4
#define B_PERCENT       5
#define B_SCREEN        6
#define B_LEN           6

// ��।������ ��������
FUNCTION ThermoNew( nLeft, cColor )
  LOCAL aHandle[B_LEN]

  DEFAULT nLeft TO 68
  aHandle[B_LEFT]       := nLeft
  aHandle[B_BACKCOLOR]  := color0
  aHandle[B_BARCOLOR]   := color0
  aHandle[B_BARCHAR]    := CHR(219)
  aHandle[B_PERCENT]    := 0

  // �஢�ઠ ��।������� ��ࠬ��஢
  IF cColor <> NIL .and. valtype(cColor) == 'A'
    aHandle[B_BARCOLOR]   := cColor[1]
    aHandle[B_BACKCOLOR]  := cColor[2]
  ENDIF

  // �஢�ઠ ���४⭮�� �࠭�� ���� ��� ����饭�� �� ��࠭�
  IF aHandle[B_LEFT] > 68
    aHandle[B_LEFT] := 68
  ENDIF
  aHandle[B_SCREEN] := save_box(0, aHandle[B_LEFT], 24, aHandle[B_LEFT] + 10)
  RETURN( aHandle )

/***
*  ThermoDisplay( aGauge ) --> aGauge
*  �⮡ࠦ���� �������� �� ��࠭� � ᮮ⢥��⢨� � ���祭�ﬨ �� ���ᨢ�
*/
FUNCTION ThermoDisplay( aHandle )
  LOCAL cOldColor := SETCOLOR( aHandle[ B_BACKCOLOR ] )
  PUT_SHADOW(2, aHandle[B_LEFT], 22, aHandle[B_LEFT] + 8)
  @  2, aHandle[B_LEFT] say '�������ͻ'
  @  3, aHandle[B_LEFT] say '�100%����'
  @  4, aHandle[B_LEFT] say '�  . ��ĺ'
  @  5, aHandle[B_LEFT] say '�  . ��ĺ'
  @  6, aHandle[B_LEFT] say '� 83%����'
  @  7, aHandle[B_LEFT] say '�  . ��ĺ'
  @  8, aHandle[B_LEFT] say '�  . ��ĺ'
  @  9, aHandle[B_LEFT] say '� 67%����'
  @ 10, aHandle[B_LEFT] say '�  . ��ĺ'
  @ 11, aHandle[B_LEFT] say '�  . ��ĺ'
  @ 12, aHandle[B_LEFT] say '� 50%����'
  @ 13, aHandle[B_LEFT] say '�  . ��ĺ'
  @ 14, aHandle[B_LEFT] say '�  . ��ĺ'
  @ 15, aHandle[B_LEFT] say '� 33%����'
  @ 16, aHandle[B_LEFT] say '�  . ��ĺ'
  @ 17, aHandle[B_LEFT] say '�  . ��ĺ'
  @ 18, aHandle[B_LEFT] say '� 17%����'
  @ 19, aHandle[B_LEFT] say '�  . ��ĺ'
  @ 20, aHandle[B_LEFT] say '�  . ��ĺ'
  @ 21, aHandle[B_LEFT] say '�  0%����'
  @ 22, aHandle[B_LEFT] say '�������ͼ'
  SETCOLOR( cOldColor )
// ����ᮢ�� ����� ��� �⮡ࠦ���� ⥪�饣� ��業⭮�� ᮮ⭮襭��
  ThermoUpdate( aHandle, aHandle[B_PERCENT] )
  RETURN( aHandle )

/***
*  ThermoUpdate( aHandle, nPercent ) --> aGauge
*  ���������� �������� � ᮮ⢥��⢨� � ���� ��業�� ᮮ⭮襭���
*/
FUNCTION ThermoUpdate( aHandle, nPercent )
  LOCAL cOldColor := SETCOLOR( aHandle[B_BARCOLOR] )
  LOCAL nBarRatio := 18
  LOCAL nRows := 0

  IF nPercent > 1
    nPercent := 1
  ENDIF
  IF nPercent < 0
    nPercent := 0
  ENDIF
  nRows := ROUND( nPercent * nBarRatio, 0 )
  for i := 0 to nRows
    @ 21 - i, aHandle[B_LEFT] + 6 say aHandle[B_BARCHAR] + aHandle[B_BARCHAR]
  next
  SETCOLOR( cOldColor )
  RETURN( aHandle )

// �����⨥ (㭨�⮦����) ��������
Function CloseThermo(aHandle)
  rest_box(ahandle[B_SCREEN])
  Return NIL
