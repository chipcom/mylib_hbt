#include "function.ch"

***** �����஢���� ����� (��� ���������� � �����஢�����)
// G_RLock() - ����ࠧ���� ����⪠ �����஢��� ������
// G_RLock("forever") - ��᪮��筠� ����⪠ �����஢��� ������
// G_RLock(.t.) - ����ࠧ���� ����⪠ �������� ������
// G_RLock("forever",.t.) - ��᪮��筠� ����⪠ �������� ������
// G_RLock(.t.,"forever") - ��᪮��筠� ����⪠ �������� ������
***** 09.01.17
FUNCTION G_RLock( ... )
LOCAL lAppend := .F., cMessage, i, lRetValue, nSec, lTryForever := .F., cArray := hb_AParams()
// ��ࠡ�⪠ ��।����� ��ࠬ��஢
FOR i := 1 TO len(cArray)
  IF VALTYPE(cArray[i]) == "L"
    lAppend := cArray[i]
  ELSE
    lTryForever := (UPPER(cArray[i]) == "FOREVER")
  ENDIF
NEXT // i
DO WHILE lRetValue == NIL
  nSec := SECONDS() + 3
  // ��横������� �� �� ����� 3 ᥪ㭤
  DO WHILE (SECONDS() < nSec) .AND. (lRetValue == NIL)
    IF lAppend
      // �믮������ APPEND BLANK �᫨ 㪠����
      APPEND BLANK
      IF !NETERR()
        lRetValue := .T.
      ENDIF
    ELSE
      // �����஢�� ⥪�饩 �����
      IF RLOCK()
        lRetValue := .T.
      ENDIF
    ENDIF
  ENDDO
  IF lRetValue == NIL
    // 3 ᥪ㭤� ��⥪��
    cMessage := "���������� �����஢��� ������ � �� " + ALIAS()
    cMessage += ";����⭥� �ᥣ�, ��� ����� ��㣨� ���짮��⥫��"
    IF lTryForever
      cArray := {"<Enter> - ��������� ᭮��"}
    else
      cArray := {"��������� ᭮��","��������"}
    ENDIF
    IF (ALERT(cMessage,cArray,color0) != 1) .AND. !lTryForever
      lRetValue := .F.
    ENDIF
  ENDIF
ENDDO
RETURN (lRetValue)
