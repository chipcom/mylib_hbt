#include "function.ch"

***** Блокирование файла
FUNCTION G_FLock( clPar1 )
LOCAL cMessage, lRetValue, nSec, lTryForever := .F.,;
      c1Array := {"Попытаться снова"}, cArray
IF PCOUNT() > 0
  lTryForever := (UPPER(clPar1) == "FOREVER")
ENDIF
DO WHILE lRetValue == NIL
  nSec := SECONDS() + 5
  // Зацикливание на более чем 5 секунд
  DO WHILE (SECONDS() < nSec) .AND. (lRetValue == NIL)
    IF FLOCK()
      lRetValue := .T.
    ENDIF
  ENDDO
  IF lRetValue == NIL
    // 5 секунд истекли
    cMessage := "ОШИБКА: Невозможно блокировать файл " + ALIAS()
    cArray := aclone(c1Array)
    IF ! lTryForever
      aadd(cArray, "Завершить")
    ENDIF
    IF (ALERT(cMessage,cArray,color0) != 1) .AND. ! lTryForever
      lRetValue := .F.
    ENDIF
  ENDIF
ENDDO
RETURN (lRetValue)
