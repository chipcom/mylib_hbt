#include "function.ch"

***** открытие файла базы данных в сети ТОЛЬКО ДЛЯ ЧТЕНИЯ
FUNCTION R_Use( cFile, cIndices, cAlias, lTryForever, lExcluUse)
return G_Use( cFile, cIndices, cAlias, lTryForever, lExcluUse, .T.)

***** монопольное открытие файла базы данных
FUNCTION E_Use( cFile, cIndices, cAlias)
return G_Use( cFile, cIndices, cAlias, , .T.)

***** открытие файла базы данных в сети
FUNCTION G_Use( cFile, cIndices, cAlias, lTryForever, lExcluUse, lREADONLY )
// cFile - файл БД
// cIndices - список индексов (или строка в случае одного индекса)
// cAlias - строка алиаса
// lTryForever - логическая величина (.T. - пытаться бесконечно)
// lExcluUse - логическая величина (.T. - монопольное открытие БД)
// lREADONLY - логическая величина (.T. - открытие БД только для чтения)
LOCAL cMessage, lRetValue, UpcFile, c1Array := {"Попытаться снова"}, cArray
if ".DBF" == Upper(right(cFile,4))
  cFile := substr(cFile,1,len(cFile)-4)
endif
UpcFile := StripPath(cFile)
// чтобы все файлы в данном модуле открывались только для чтения,
// определите PRIVATE-перемменную "PRIVATE use_readonly := .T."
if lREADONLY == NIL .and. type("use_readonly") == "L" .and. use_readonly
  lREADONLY := .t.
endif
DEFAULT cIndices TO {}, cAlias TO UpcFile, lTryForever TO .F., ;
        lExcluUse TO .F., lREADONLY TO .f.
IF !FILE(cFile + ".DBF") // проверка на наличие файла
  cMessage := "ОШИБКА: Файл "+UpcFile+" не существует!"
  cMessage += ";Операция прекращена"
  ALERT(cMessage,{"Завершить"},color0)
  lRetValue := .F.
ELSE
  // Попытки открытия базы данных до успеха или отказа
  DO WHILE lRetValue == NIL
    dbUseArea( .T.,;          // new
               , ;            // rdd
               cFile, ;       // db
               cAlias, ;      // alias
               !lExcluUse, ;  // if(<.sh.> .or. <.ex.>, !<.ex.>, NIL)
               lREADONLY, ;   // readonly
               "RU866")
    IF !NETERR()
      if EMPTY(cIndices)  // нет индексов при вызове ф-ии
        lRetValue := .T.
        DbClearIndex()  // все равно закрыть - для FOXPRO
      elseif !(lRetValue := G_Index(cIndices))
        Use  // закрыть БД при отсутствии индекса(ов)
      endif
    ELSE
      IF !lTryForever
        cMessage := "Невозможно открыть файл "+UpcFile
        cMessage += ";Он занят другим пользователем"
        cArray := aclone(c1Array)
        aadd(cArray,"Завершить")
        IF ALERT(cMessage,cArray,color0) != 1
          lRetValue := .F.
        ENDIF
      ENDIF
    ENDIF
  ENDDO
ENDIF
RETURN (lRetValue)
