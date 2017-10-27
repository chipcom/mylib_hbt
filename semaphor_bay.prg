*************** Использование семафоров для работы в сети *********************
*
* G_SOpen(<имя семафора/open>,<имя семафора/lock>,_fio,_comp) --> <успешность открытия>
*      открывает семафор для совместного использования (вход в задачу)
* G_SClose(<имя семафора>) --> <успех>
*      закрывает открытый Вами семафор (выход из задачи)
* G_SCount(<имя семафора>) --> <число>
*      возвращает число рабочих станций, совместно использующих этот семафор
*      (т.е. сколько пользователей работают в данный момент в этой задаче)
* G_SIsLock(<имя семафора>) --> <.t.-заблокирован, .f.-нет>
*      проверяет, заблокирован ли данный семафор
* G_SLock(<имя семафора>) --> <успешность блокировки>
*      позволяет блокировать семафор для монопольного использования
* G_SUnlock(<имя семафора>)
*      освобождает заблокированный Вами семафор
* G_SUnlockArr(<массив семафоров>)
*      освобождает заблокированные Вами семафоры
* G_SLock1Task(cSemaphore_task,cSemaphore_lock) --> <успешность блокировки>
*      позволяет блокировать семафор, если запущен только один экземляр задачи
* G_SValue(<имя семафора>) --> <значение счетчика>
*      возвращает текущее значение внутреннего счетчика семафора
*      (на это значение оказывают влияние две следующие функции)
* G_SPlus(<имя семафора>) --> <успех>
*      увеличивает текущее значение внутреннего счетчика семафора
* G_SMinus(<имя семафора>) --> <успех>
*      уменьшает текущее значение внутреннего счетчика семафора
* G_SValueNLock(cSemaphore_value,nValue,cSemaphore_lock) --> <успешность блокировки>
*      позволяет блокировать семафор cSemaphore_lock, если
*      G_SValue(cSemaphore_value) возвращает <= nValue
*
*******************************************************************************
#include "set.ch"
#include "fileio.ch"
#include "function.ch"

#define file_sem  (dir_server+"semaphor")
#define S_LOCK      1
#define S_IS_LOCK     11
#define S_UNLOCK    2
#define S_OPEN      3
#define S_CLOSE     4
#define S_COUNT     5
#define S_VALUE     6
#define S_VALUE_LOCK  61
#define S_MINUS     7
#define S_PLUS      8
#define S_UNLOCKARR 9

Static task_name := 0
Static task_fio  := ""
Static task_comp := ""

*****
*   G_SLock1Task(cSemaphore_task, cSemaphore_lock) --> <успешность открытия>
*
* Эта функция позволяет блокировать семафор для монопольного использования,
* если запущен только один экземляр задачи
*
FUNCTION G_SLock1Task(cSemaphore_task, cSemaphore_lock)
RETURN G_SOperation(cSemaphore_lock,S_LOCK,,cSemaphore_task)

*****
*   G_SValueNLock(cSemaphore_value,nValue,cSemaphore_lock) --> <успешность открытия>
*
* Эта функция позволяет блокировать семафор cSemaphore_lock, если
* G_SValue(cSemaphore_value) возвращает <= nValue
*
FUNCTION G_SValueNLock(cSemaphore_value,nValue,cSemaphore_lock)
RETURN G_SOperation(cSemaphore_value,S_VALUE_LOCK,,cSemaphore_lock,nValue)

*****
*   G_SIsLock(<имя семафора>) --> <.t.-заблокирован, .f.-нет>
*      проверяет, заблокирован ли данный семафор
*
FUNCTION G_SIsLock( cSemaphore )
RETURN G_SOperation(cSemaphore, S_IS_LOCK)

*****
*   G_SLock(<имя семафора>) --> <успешность открытия>
*
* Эта функция позволяет блокировать семафор для монопольного использования.
*
FUNCTION G_SLock( cSemaphore )
RETURN G_SOperation(cSemaphore, S_LOCK)

*****
*   G_SUnlock(<имя семафора>)
*
* Эта функция освобождает заблокированный Вами семафор.
*
FUNCTION G_SUnlock( cSemaphore )
RETURN G_SOperation(cSemaphore, S_UNLOCK)

*****
*   G_SUnlockArr(<массив семафоров>)
*
* Эта функция освобождает заблокированные Вами семафоры.
*
FUNCTION G_SUnlockArr( arrSemaphore )
RETURN G_SOperation( "_", S_UNLOCKARR, arrSemaphore)

*****
*   G_SOpen(<имя семафора/open>,<имя семафора/lock>) --> <успешность открытия>
*
* Эта функция открывает семафор для совместного использования.
*
FUNCTION G_SOpen( cSemaphore_open, cSemaphore_lock, _fio, _comp )
DEFAULT cSemaphore_lock TO "", _fio TO "", _comp TO ""
task_fio := _fio
if empty(_comp)
  _comp := date_8(date())+"без имени"
endif
task_comp := _comp
RETURN G_SOperation(cSemaphore_open,S_OPEN,,cSemaphore_lock)

*****
*   G_SClose(<имя семафора>) --> <успех>
*
* Эта функция закрывает открытый Вами семафор.
*
FUNCTION G_SClose( cSemaphore )
RETURN G_SOperation(cSemaphore, S_CLOSE)

*****
*   G_SCount(<имя семафора>) --> <число>
*
* Эта функция возвращает число рабочих станций, совместно использующих в
* настоящий момент этот семафор (т.е. сколько пользователей работают
* в данный момент в этой задаче).
*
FUNCTION G_SCount( cSemaphore )
RETURN G_SOperation(cSemaphore, S_COUNT)

*****
*   G_SValue(<имя семафора>) --> <значение счетчика>
*
* Эта функция возвращает текущее значение внутреннего счетчика семафора.
* (На это значение оказывают влияние две следующие функции.)
*
FUNCTION G_SValue( cSemaphore )
RETURN G_SOperation(cSemaphore, S_VALUE)

*****
*   G_SMinus(<имя семафора>) --> <успех>
*
* Эта функция уменьшает текущее значение внутреннего счетчика семафора.
*
FUNCTION G_SMinus( cSemaphore )
RETURN G_SOperation(cSemaphore, S_MINUS)

*****
*   G_SPlus(<имя семафора>) --> <успех>
*
* Эта функция увеличивает текущее значение внутреннего счетчика семафора.
*
FUNCTION G_SPlus( cSemaphore )
RETURN G_SOperation(cSemaphore, S_PLUS)

*

***** 15.09.15
STATIC FUNCTION G_SOperation(cSemaphore,cOperation,arrSemaphore,cSemaphore2,nV)
Static adbf := {{"KOD",  "N", 1,0},;  // код операции
                {"NAME", "C",60,0},;  // наименование (содержание) семафора
                {"VALUE","N", 4,0},;  // значение счетчика
                {"TASK", "N", 7,0},;  // количество секунд после полуночи
                {"EXE",  "C",12,0},;  // наименование файла задачи
                {"DATA", "D", 8,0},;  // дата запуска задачи
                {"FIO",  "C",20,0},;  // ФИО пользователя
                {"COMP", "C",17,0}}   // наименование компьютера
LOCAL i, lnRetValue := .f., tmp_select := select(), sem_dbf, fl, bSaveHandler
DEFAULT cSemaphore TO "", cOperation TO 0, cSemaphore2 TO ""
if equalany(cOperation,S_COUNT,S_VALUE)
  lnRetValue := 0
endif
IF EMPTY(cSemaphore)
  return lnRetValue
ENDIF
sem_dbf := file_sem+".dbf"
cSemaphore  := padr(UPPER(LTRIM(cSemaphore )),60)
cSemaphore2 := padr(UPPER(LTRIM(cSemaphore2)),60)
i := 0 ; fl := .f.
do while .t.
  //
  bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
  //
  BEGIN SEQUENCE
    if !hb_FileExists(sem_dbf)  // пытаемся создать DBF-файл
      dbcreate(file_sem, adbf)
    endif
    dbUseArea( .T.,;          // new
               , ;            // rdd
               file_sem, ;    // db
               "SEMAPHOR", ;  // alias
               .f.,;          // !lExcluUse, ;  // if(<.sh.> .or. <.ex.>, !<.ex.>, NIL)
               , ;            // readonly
               "RU866")
    fl := .t.
  RECOVER USING error
    fl := .f.
    if select("SEMAPHOR") > 0
      SEMAPHOR->( dbCloseArea() )
    endif
  END
  //
  ERRORBLOCK(bSaveHandler)
  //
  if fl // при удачном открытии создаём индекс в рабочем каталоге
    index on str(kod,1)+name+str(task,7) to tmp_sem
    exit
  else
    if ++i > 30
      f_alert({"Невозможно открыть файл "+upper(sem_dbf)+".",;
               "Вероятнее всего, он занят другим пользователем.",;
               ""},;
              {" <Enter> - попытаться снова "},;
              1,"W/N","G+/N",,,"W+/N,N/BG" )
      i := 0
    endif
  endif
  millisec(20)
enddo
if fl
  DO CASE
    CASE cOperation == S_IS_LOCK
      find (str(S_LOCK,1)+cSemaphore)
      lnRetValue := found()
    CASE cOperation == S_LOCK
      lnRetValue := .t.
      if !empty(cSemaphore2)
        i := 0
        find (str(S_OPEN,1)+cSemaphore2)
        do while kod == S_OPEN .and. name == cSemaphore2 .and. !eof()
          i++
          skip
        enddo
        lnRetValue := (i < 2)
      endif
      if lnRetValue
        find (str(S_LOCK,1)+cSemaphore)
        if (lnRetValue := !found())
          S_AddRec(1)
          replace kod with S_LOCK, name with cSemaphore, task with task_name
        endif
      endif
    CASE cOperation == S_UNLOCK
      find (str(S_LOCK,1)+cSemaphore+str(task_name,7))
      if found()
        S_DeleteRec()
      endif
      lnRetValue := .t.
    CASE cOperation == S_UNLOCKARR
      for i := 1 to len(arrSemaphore)
        find (str(S_LOCK,1)+padr(UPPER(LTRIM(arrSemaphore[i])),60)+str(task_name,7))
        if found()
          S_DeleteRec()
        endif
      next
      lnRetValue := .t.
    CASE cOperation == S_OPEN
      if task_name == 0
        if lastrec() > 20
          Pack  // если уже большой файл, упакуем его
        endif
        del_sem_files()  // удалим все старые семафоры
        task_name := int(seconds()*100)
        fp := fcreate(lstr(task_name)+".000", FC_HIDDEN)
        fwrite(fp, lstr(task_name))
        fclose(fp)
      endif
      lnRetValue := .t.
      if !empty(cSemaphore2)
        find (str(S_LOCK,1)+cSemaphore2)
        lnRetValue := !found()
      endif
      if lnRetValue .and. !empty(task_fio) .and. type("verify_fio_polzovat")=="L"
        find (str(S_OPEN,1)+cSemaphore)
        do while kod == S_OPEN .and. name == cSemaphore .and. !eof()
          if fio == padr(task_fio,20)
            lnRetValue := .f.
            verify_fio_polzovat := .t.
            exit
          endif
          skip
        enddo
      endif
      if lnRetValue
        S_AddRec(1)
        replace kod  with S_OPEN, ;
                name with cSemaphore, ;
                task with task_name,;
                data with date(), ;
                fio  with task_fio, ;
                comp with task_comp, ;
                exe  with StripPath(exename())
      endif
    CASE cOperation == S_CLOSE
      lnRetValue := del_sem_files() // удалим все старые семафоры
    CASE cOperation == S_COUNT
      lnRetValue := 0
      find (str(S_OPEN,1)+cSemaphore)
      do while kod == S_OPEN .and. name == cSemaphore .and. !eof()
        lnRetValue++
        skip
      enddo
    CASE cOperation == S_VALUE
      lnRetValue := 0
      find (str(S_VALUE,1)+cSemaphore)
      do while kod == S_VALUE .and. name == cSemaphore .and. !eof()
        lnRetValue += semaphor->value
        skip
      enddo
    CASE cOperation == S_VALUE_LOCK
      i := 0
      find (str(S_VALUE,1)+cSemaphore)
      do while kod == S_VALUE .and. name == cSemaphore .and. !eof()
        i += semaphor->value
        skip
      enddo
      if (lnRetValue := (i <= nV))
        find (str(S_LOCK,1)+cSemaphore2)
        if (lnRetValue := !found())
          S_AddRec(1)
          replace kod with S_LOCK, name with cSemaphore2, task with task_name
        endif
      endif
    CASE cOperation == S_MINUS
      find (str(S_VALUE,1)+cSemaphore+str(task_name,7))
      if found()
        replace value with value-1
      endif
      lnRetValue := .t.
    CASE cOperation == S_PLUS
      find (str(S_VALUE,1)+cSemaphore+str(task_name,7))
      if !found()
        S_AddRec(1)
        replace kod with S_VALUE, name with cSemaphore, task with task_name
      endif
      replace value with value+1
      lnRetValue := .t.
  ENDCASE
endif
if select("SEMAPHOR") > 0   // на всякий случай при разрушении индексного файла
  SEMAPHOR->( dbCloseArea() )
endif
if tmp_select > 0
  select(tmp_select)
endif
return (lnRetValue)

*****
Static Function del_sem_files(arr_files)
Local i, t_name
DEFAULT arr_files TO directory("*.000","H")
set order to 0
for i := 1 to len(arr_files)
  t_name := int(val(filestr(arr_files[i,1])))
  go top
  do while !eof()
    if task == t_name
      S_DeleteRec()
    endif
    skip
  enddo
  delete file (arr_files[i,1])
next
set order to 1
return .t.

*

***** добавление с повторным использованием удаленных записей (есть индекс)
Function S_AddRec(k)
// k - длина цифрового ключа
Local lOldDeleted := SET(_SET_DELETED, .F.)
find (str(0,k))
if found() .and. deleted()
  Recall
else
  append blank
endif
SET(_SET_DELETED, lOldDeleted)  // Восстановление среды
return .t.

***** Очистить запись файла семафора и пометить для удаления
Function S_DeleteRec()
replace kod with 0, name with "", value with 0, task with 0, ;
        data with ctod(""), fio with "", comp with "", exe with ""
Delete
return .t.
