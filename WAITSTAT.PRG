/***
*  �������� �������� �����-��������, ����� ����� �ᯮ�짮������
*  ��� ������樨 ⮣�, �� ����� ����⢨⥫쭮 �믮������.
*/

#include 'function.ch'

#define ST_LEN     5                       // ����� ���ᨢ�
#define ST_ROW     1                       // ��ப� �������� �� ��࠭�
#define ST_COL     2                       // ������� �������� �� ��࠭�
#define ST_COLOR   3                       // ���� ��������
#define ST_TEXT    4                       // ��ப� ��। �������஬
#define ST_CURRENT 5                       // ������ ������ � ���ᨢ� ��
                                           // ��������
STATIC aDisplay := { '|', '/', '-', '\' }  // ���ᨢ ᨬ����� - �� ��������
Static aStat := { 24, 0, '15/4', '��������, ࠡ��� ...', 1 }
Static OldSec := 0

/***
*  WaitStatus( [stroke], [<nRow>], [<nCol>], [<cColor>] ) --> aStat
*  �������� ������ ��������
*  ( �᫨ nCol == NIL, ��ப� stroke 業������� )
*/
FUNCTION WaitStatus( stroke, nRow, nCol, cColor )
  
  aStat[ ST_ROW     ] := 24
  aStat[ ST_COL     ] := 0
  aStat[ ST_COLOR   ] := cColorStMsg
  aStat[ ST_TEXT    ] := '��������, ࠡ��� ...'
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
    aStat[ST_TEXT] := center(alltrim(aStat[ST_TEXT]), 80) + ' '
    @ aStat[ST_ROW], 0 say space(80) color aStat[ST_COLOR]
  ELSE
    aStat[ ST_COL ] := nCol
  ENDIF
  IF !EMPTY(aStat[ ST_TEXT ])
    @ aStat[ST_ROW], aStat[ST_COL] say aStat[ST_TEXT] color aStat[ST_COLOR]
    aStat[ST_COL] += len( aStat[ST_TEXT] )
  ENDIF
  setcursor(0)
  RETURN NIL

//  ���������� ��������
FUNCTION UpdateStatus()
  Local s := seconds()

  if s - OldSec > 0.2
    OldSec := s
    Inc( aStat[ ST_CURRENT ] )
    IF aStat[ ST_CURRENT ] > 4
      aStat[ ST_CURRENT ] := 1
    ENDIF
    @ aStat[ST_ROW], aStat[ST_COL] SAY aDisplay[ aStat[ST_CURRENT] ] ;
                                                color aStat[ST_COLOR]
  endif
  RETURN NIL
