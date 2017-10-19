#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"

#define S_LOCK      1
#define S_OPEN      3
#define S_VALUE     6
#define file_sem  (dir_server+"semaphor")

Static tmp1monitor := "tmp_mon1.dbf"
Static tmp2monitor := "tmp_mon2.dbf"

***** программа управления сетевым монитором
Function net_monitor(r,c,yes_admin)
LOCAL lCont := .T., nKey := 256, buf := savescreen(), ;
      t_color := setcolor(color0), i, j, nsec := seconds(), km, ;
      oBrowse, tmp, pr1, pr2, pc1, pc2, blk, s := ""
DEFAULT yes_admin TO .t.
if !f1_net_mon(1)
  return func_error(4,"Недоступен файл семафора! Попытайтесь еще раз.")
endif
//
if yes_admin
  s := ";  ^<Del>^ - удалить семафор"
endif
status_key("^<Esc>^ - выход"+s)
if r > maxrow()/2
  r := int(maxrow()/2)
endif
pr1 := r; pr2 := maxrow()-4; pc1 := 0; pc2 := 79
box_shadow(pr1, pc1, pr2, pc2, color0, "Сетевой монитор","B/BG")
// Создание нового TBrowse объекта
oBrowse := TBrowseDB(pr1+1, pc1+1, pr2, pc2-1)
//  задание установок TBrowse
oBrowse:headSep := "═╤═"
oBrowse:colSep  := " │ "
oBrowse:footSep := "═╧═"
//oBrowse:headSep := "═"
//oBrowse:colSep  := "░"
//oBrowse:footSep := "═"
oBrowse:colorSpec := "N/BG,W+/N,B/BG,BG+/B"
// добавление столбцов
blk := {|| iif(empty(tmp2->kod), {3,4}, {1,2}) }
oColumn := TBColumnNew(padc("Дата",10), {|| full_date(tmp2->data) })
oColumn:colorBlock := blk
oBrowse:addColumn(oColumn)
//
oColumn := TBColumnNew("Время", {|| hour_min(tmp2->task/100) })
oColumn:colorBlock := blk
oBrowse:addColumn(oColumn)
//
oColumn := TBColumnNew(padc("Задача",12), {|| tmp2->exe })
oColumn:colorBlock := blk
oBrowse:addColumn(oColumn)
//
oColumn := TBColumnNew(padc("Пользователь",20), {|| tmp2->fio })
oColumn:colorBlock := blk
oBrowse:addColumn(oColumn)
//
oColumn := TBColumnNew(padc("Компьютер",17), {|| left(tmp2->comp,17) })
oColumn:colorBlock := blk
oBrowse:addColumn(oColumn)
//
j := pr2 - oBrowse:rowCount-1
@ j,pc1 say "╠"
@ j,pc2 say "╣"
@ maxrow()-3,0 to maxrow()-1,79 color "B+/B"
@ maxrow()-2,1 say space(78) color "B+/B"
str_center(maxrow()-3," Наименование режима ","B+/B")
DO WHILE lCont   // главный цикл просмотра
  if nKey != 0
    oBrowse:refreshCurrent()  // Устанавливает текущей строке стандартные цвета
    oBrowse:forcestable()  // стабилизация
    if oBrowse:colCount > 1
      // Выделение цветом всей текущей строки
      i := eval(blk)
      if valtype(i) == "A"
        i := i[2]
      else
        i := 2
      endif
      oBrowse:colorRect({oBrowse:rowPos,1,oBrowse:rowPos,oBrowse:colCount},{i,i})
      oBrowse:forcestable()  // стабилизация
    endif
    @ maxrow()-2,1 say padc(alltrim(tmp2->name),78) color color1
  endif
  nKey := INKEYTRAP()
  if seconds() - nsec > 20     // каждые 20 сек.
    if f1_net_mon(2)           // перечитать семафор
      oBrowse:refreshAll()
      nsec := seconds()
      nKey := 256
    endif
    nsec := seconds()
  endif
  DO CASE  // обработка нажатых клавиш
    CASE nKey == K_UP .or. nKey == K_SH_TAB
      oBrowse:up()
    CASE nKey == K_DOWN .or. nKey == K_TAB
      oBrowse:down()
    CASE nKey == K_PGUP ; oBrowse:pageUp()
    CASE nKey == K_PGDN ; oBrowse:pageDown()
    CASE nKey == K_HOME .or. nKey == K_CTRL_PGUP .or. nKey == K_CTRL_HOME
      oBrowse:goTop()
    CASE nKey == K_END .or. nKey == K_CTRL_PGDN .or. nKey == K_CTRL_END
      oBrowse:goBottom()
    CASE nKey == K_DEL .and. yes_admin .and. f_Esc_Enter(2)
      del_sem_other(tmp2->task)
      select TMP2
      DeleteRec()
      oBrowse:goTop()
    CASE nKey == K_ESC
      lCont := .F.
  ENDCASE
ENDDO
setcolor(t_color)
close databases
restscreen(buf)
return NIL

*****
Static Function f1_net_mon(par)
Local rec := 0, fl := .f.
if par == 1  // первый запуск
  delete file (tmp2monitor)
  fl := f2_net_mon()
else  // следующие запуски
  rec := tmp2->(recno())
  close databases
  fl := f2_net_mon()
endif
if fl .or. file(tmp2monitor)
  use (tmp2monitor) index tmp2 new alias TMP2
  go top
  if rec > 0
    do while !eof()  // пройти вперед до конца
      skip
    enddo
    do while !bof()  // а теперь назад до нужной записи
      if recno() == rec
        exit
      endif
      skip -1
    enddo
  endif
endif
return fl

*****
Static Function f2_net_mon()
Local i := 0, adbf, fl := .f., buf := save_row(maxrow())
mywait()
delete file (tmp1monitor)
do while ++i < 20
  //
  bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
  //
  BEGIN SEQUENCE
    copy file (dir_server+"semaphor.dbf") to (tmp1monitor)
    if hb_FileExists(tmp1monitor)
      fl := .t.
    endif
  RECOVER USING error
    fl := .f.
  END
  //
  ERRORBLOCK(bSaveHandler)
  if fl
    exit
  endif
  millisec(20)
enddo
if fl
  use (tmp1monitor) new alias TMP1
  if file(tmp2monitor)
    use (tmp2monitor) new alias TMP2
    zap
  else
    select TMP1
    adbf := dbstruct()
    dbcreate(tmp2monitor,adbf)
    use (tmp2monitor) new alias TMP2
  endif
  select TMP1
  index on str(kod,1) to tmp1
  find (str(S_OPEN,1))
  do while tmp1->kod == S_OPEN .and. !eof()
    select TMP2
    append blank
    replace task with tmp1->task,;
            data with tmp1->data,;
            fio  with tmp1->fio ,;
            comp with tmp1->comp,;
            exe  with tmp1->exe
    select TMP1
    skip
  enddo
  select TMP2
  index on str(task,7) to tmp2
  //
  select TMP1
  find (str(S_LOCK,1))
  do while tmp1->kod == S_LOCK .and. !eof()
    select TMP2
    find (str(tmp1->task,7))
    if found()
      tmp2->kod  := S_LOCK
      tmp2->name := tmp1->name
    endif
    select TMP1
    skip
  enddo
  //
  select TMP1
  find (str(S_VALUE,1))
  do while tmp1->kod == S_VALUE .and. !eof()
    if tmp1->value > 0
      select TMP2
      find (str(tmp1->task,7))
      if found() .and. empty(tmp2->kod)
        tmp2->kod  := S_VALUE
        tmp2->name := tmp1->name
      endif
    endif
    select TMP1
    skip
  enddo
  select TMP2
  index on dtos(data)+str(task,7) to tmp2
endif
close databases
rest_box(buf)
return fl

*

***** 19.10.17 удалить семафор вызовом из сетевого монитора (по имени задачи)
Function del_sem_other(t_name)
LOCAL fl := .f., tmp_select := SELECT(), bSaveHandler
do while .t.
  bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
  BEGIN SEQUENCE
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
  ERRORBLOCK(bSaveHandler)
  if fl // при удачном открытии создаём индекс в рабочем каталоге
    index on str(task,7) to tmp_sem
    do while .t.
      find (str(t_name,7))
      if !found() ; exit ; endif
      S_DeleteRec()
    enddo
    SEMAPHOR->( dbCloseArea() )
  else
    if f_alert({"Возникла ошибка!",;
                "Невозможно открыть файл SEMAPHOR.DBF",;
                "Вероятнее всего, он занят другим пользователем.",;
                ""},;
               {" <Esc> - отказ "," <Enter> - попытаться снова "},;
               1,"W/N","G+/N",,,"W+/N,N/BG" ) == 2
      loop
    endif
  endif
  exit
enddo
if tmp_select > 0
  select (tmp_select)
endif
return NIL
