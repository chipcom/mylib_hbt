#include "function.ch"

***** �����஢���� 䠩��
FUNCTION G_FLock( clPar1 )
LOCAL cMessage, lRetValue, nSec, lTryForever := .F.,;
      c1Array := {"��������� ᭮��"}, cArray
IF PCOUNT() > 0
  lTryForever := (UPPER(clPar1) == "FOREVER")
ENDIF
DO WHILE lRetValue == NIL
  nSec := SECONDS() + 5
  // ��横������� �� ����� 祬 5 ᥪ㭤
  DO WHILE (SECONDS() < nSec) .AND. (lRetValue == NIL)
    IF FLOCK()
      lRetValue := .T.
    ENDIF
  ENDDO
  IF lRetValue == NIL
    // 5 ᥪ㭤 ��⥪��
    cMessage := "������: ���������� �����஢��� 䠩� " + ALIAS()
    cArray := aclone(c1Array)
    IF ! lTryForever
      aadd(cArray, "��������")
    ENDIF
    IF (ALERT(cMessage,cArray,color0) != 1) .AND. ! lTryForever
      lRetValue := .F.
    ENDIF
  ENDIF
ENDDO
RETURN (lRetValue)
