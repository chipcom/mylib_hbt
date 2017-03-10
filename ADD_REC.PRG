#include "set.ch"
#include "function.ch"
#include "inkey.ch"

Static sforever := "FOREVER"

***** добавление с повторным использованием удаленных записей (есть индекс)
FUNCTION AddRec
LOCAL lOldDeleted := SET(_SET_DELETED, .F.), fl := .t., fl_f := .f.
Parameters k, is_forever, is_only_0
// k    - длина цифрового ключа
//        или наименование поля для поиска кода (для locate)
// is_forever - если .t. - пытаться бесконечно блокировать запись
// is_only_0  - .t. искать просто нулевой код, .f. - нулевой код + deleted()
DEFAULT is_forever TO .f., is_only_0 TO .f.
if valtype(k) == "N"
  FIND (STR(0,k))
  IF FOUND()  // если найдено значение "нуль" - проверить на DELETED()
    fl_f := .t.
    IF DELETED()
      IF (fl := iif(is_forever,G_RLock(sforever),G_RLock()))
        RECALL
      ENDIF
    ELSEIF is_only_0
      fl := iif(is_forever,G_RLock(sforever),G_RLock())
    ELSE
      fl_f := .f.
    ENDIF
  ENDIF
else
  go top
  do while !eof()
    if DELETED() .and. iif(is_forever,G_RLock(sforever),G_RLock())
      RECALL ; fl := fl_f := .t. ; exit
    ENDIF
    skip
  enddo
endif
if !fl_f
  fl := if(is_forever,G_RLock(.t.,sforever),G_RLock(.t.))
ENDIF
SET(_SET_DELETED, lOldDeleted)  // Восстановление среды
RETURN fl

*

***** добавление с повторным использованием удаленных записей (нет индекса)
FUNCTION AddRecN(is_forever)
LOCAL lOldDeleted := SET(_SET_DELETED, .F.), fl := .f.
DEFAULT is_forever TO .t. // если .t. - пытаться бесконечно блокировать запись
go top
do while !eof()
  if DELETED() .and. iif(is_forever,G_RLock(sforever),G_RLock())
    RECALL ; fl := .t. ; exit
  ENDIF
  skip
enddo
if !fl
  fl := if(is_forever,G_RLock(.t.,sforever),G_RLock(.t.))
ENDIF
SET(_SET_DELETED, lOldDeleted)  // Восстановление среды
RETURN fl

*

***** Очистить запись и пометить для удаления
FUNCTION DeleteRec(is_cycle,is_delete,is_lock)
// is_cycle  - (.f.) .f. - делать COMMIT, .t. - не делать
// is_delete - (.t.) .t. - помечать на удаление, .f. - не помечать
// is_lock   - (.t.) .t. - блокировать запись, .f. - нет (уже заблокирована)
LOCAL nNumberofFields := FCOUNT(), nCurField, mtype, fl := .t.
DEFAULT is_cycle TO .f., is_delete TO .t., is_lock TO .t.
if (fl := iif(is_lock, G_RLock(sforever), .t.))
  FOR nCurField := 1 TO nNumberofFields
    mtype := TYPE( FIELD(nCurField) )
    DO CASE
      CASE mtype == "C"
        FIELDPUT( nCurField, " " )
      CASE mtype == "N"
        FIELDPUT( nCurField, 0 )
      CASE mtype == "L"
        FIELDPUT( nCurField, .F. )
      CASE mtype == "D"
        FIELDPUT( nCurField, CTOD("") )
      CASE mtype == "M"
        IF !EMPTY(FIELDGET( nCurField ))
          FIELDPUT( nCurField, " " )
        ENDIF
    ENDCASE
  NEXT
  if is_delete
    DELETE
  endif
  if !is_cycle
    COMMIT
  endif
  if is_lock
    UNLOCK
  endif
endif
RETURN fl
