#include "set.ch"
#include "function.ch"

*****
FUNCTION FindFirst( xValue, fl_softseek )
DEFAULT fl_softseek TO .f.
// Перемещает указатель на первую запись, соответствующую условию
DBSEEK( xValue, fl_softseek )
RETURN (NIL)

*****
FUNCTION FindLast( xValue, ascend_des, is_value, i1, i2 )
// Перемещает указатель на последнюю запись, соответствующую условию
// ascend_des := 1 - индексный файл ASCENDING (по умолчанию)
// ascend_des := -1 - индексный файл DESCENDING
// is_value := .t. - часть индексного ключа обрабатывается функцией STR()
//  i1 - начальная позиция индексного ключа для функции STR() (умолч.=1)
//  i2 - конечная позиция индексного ключа для функции STR() (умолч.=len(ключ))
LOCAL lSeek := SET(_SET_SOFTSEEK, .T.), k, s1, s2, s3, v
DEFAULT ascend_des TO 1, is_value TO .f.
// поиск записи, следующей сразу за последней записью, удовлетворяющей
// условию поиска
if is_value  // часть строки -> число
  Store "" to s1, s2, s3
  k := LEN(xValue)
  DEFAULT i1 TO 1, i2 TO k
  if i1 > 1
    s1 := left(xValue,i1-1)
  endif
  v := val(substr(xValue,i1,i2-i1+1)) + ascend_des ; s2 := str(v,i2-i1+1)
  if i2 < k
    s3 := right(xValue,k-i2)
  endif
  DBSEEK(s1+s2+s3)
else
  DBSEEK(SUBSTR(xValue,1, LEN(xValue)-1)+;
         CHR(ASC(SUBSTR(xValue, LEN(xValue)))+ascend_des))
endif
// возвращение назад на одну запись, т.е. на последнюю запись,
// удовлетворяющую условию поиска
DBSKIP(-1)
SET(_SET_SOFTSEEK, lSeek)
RETURN (NIL)

*****
FUNCTION SkipPointer(nSkip, condition)
// Управляет перемещением указателя записи между записями,
// удовлетворяющими условию фильтрации
LOCAL nNumMoved := 0
DEFAULT condition TO ".t."
DO WHILE !EOF() .AND. !BOF() .AND. nNumMoved != nSkip .AND. &(condition)
  IF nSkip > 0
    DBSKIP()
    Inc(nNumMoved)
  ELSE
    DBSKIP(-1)
    Dec(nNumMoved)
  ENDIF
ENDDO
DO CASE
  CASE EOF()   // При достижении конца файла
    DBSKIP(-1)
    Dec(nNumMoved)
  CASE BOF()       // При достижении начала файла необходимо увеличить
    Inc(nNumMoved) // значение счетчика на 1; перемещать указатель записи
                   // не нужно, так как он уже находится на первой записи
    DBSKIP()       // шаг вперед
    DBSKIP(-1)     // шаг назад  - чтобы снять установку BOF()
  CASE !(&(condition)) // Если указатель вышел за пределы условия фильтра.
    IF nSkip > 0    //  Если указатель записи перемещался вперед, то
      DBSKIP(-1)    //  необходимо переместить указатель на одну запись назад
      Dec(nNumMoved)//  и уменьшить значение счетчика на 1
    ELSE              // Если указатель записи перемещался назад, то
      DBSKIP()        // необходимо переместить указатель на одну запись
      Inc(nNumMoved)  // вперед и увеличить значение счетчика на 1
    ENDIF
ENDCASE
RETURN (nNumMoved)
