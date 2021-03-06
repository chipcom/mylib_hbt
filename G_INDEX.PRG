#include "function.ch"

***** ����⨥ ᯨ᪠ �������� 䠩��� ��� ࠡ��� � ��
FUNCTION G_Index( cIndex )
LOCAL nIndexNum, cMessage, nRecNo, lRetValue
DEFAULT cIndex TO {}
if valtype(cIndex) == "C"
  cIndex := {cIndex}
endif
IF Len(cIndex) == 0
  // �᫨ ������ �� 㪠���, � �����⨥ ��� �������� 䠩���
  nRecNo := RECNO()
  dbClearIndex()
  GO nRecNo
  lRetValue := .T.
ELSE
  FOR nIndexNum := 1 TO len(cIndex)
    // �஢�ઠ ������ �����᭮�� 䠩��
    IF !FILE(cIndex[nIndexNum]+if("." $ cIndex[nIndexNum], "", ".??x"))
      cMessage := "������: ������� 䠩� "+StripPath(cIndex[nIndexNum])+;
                  " �� �������"
      ALERT(cMessage,{"��������"},color0)
      lRetValue := .F.
      EXIT
    ENDIF
  NEXT
  IF lRetValue == NIL
    // ���࠭���� 㪠��⥫� �����
    nRecNo := RECNO()
    dbClearIndex()
    FOR nIndexNum := 1 TO min(len(cIndex),15)
      dbSetIndex( cIndex[nIndexNum] )
    NEXT
    // ����⠭������� 㪠��⥫� �����
    GO nRecNo
    lRetValue := .T.
  ENDIF
ENDIF
RETURN (lRetValue)
