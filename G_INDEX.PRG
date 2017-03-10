#include "function.ch"

***** Открытие списка индексных файлов для работы в сети
FUNCTION G_Index( cIndex )
LOCAL nIndexNum, cMessage, nRecNo, lRetValue
DEFAULT cIndex TO {}
if valtype(cIndex) == "C"
  cIndex := {cIndex}
endif
IF Len(cIndex) == 0
  // Если индекс не указан, то закрытие всех индексных файлов
  nRecNo := RECNO()
  dbClearIndex()
  GO nRecNo
  lRetValue := .T.
ELSE
  FOR nIndexNum := 1 TO len(cIndex)
    // Проверка наличия индексного файла
    IF !FILE(cIndex[nIndexNum]+if("." $ cIndex[nIndexNum], "", ".??x"))
      cMessage := "ОШИБКА: Индексный файл "+StripPath(cIndex[nIndexNum])+;
                  " не существует"
      ALERT(cMessage,{"Завершить"},color0)
      lRetValue := .F.
      EXIT
    ENDIF
  NEXT
  IF lRetValue == NIL
    // Сохранение указателя записи
    nRecNo := RECNO()
    dbClearIndex()
    FOR nIndexNum := 1 TO min(len(cIndex),15)
      dbSetIndex( cIndex[nIndexNum] )
    NEXT
    // Восстановление указателя записи
    GO nRecNo
    lRetValue := .T.
  ENDIF
ENDIF
RETURN (lRetValue)
