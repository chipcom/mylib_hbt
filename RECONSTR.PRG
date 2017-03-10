#include "set.ch"
#include "function.ch"

***** 05.11.15 создает или перестраивает файл БД
Function reconstruct(file_base,;  // имя файла базы данных
                     struct_dbf,; // двумерный массив с эталонной структурой БД
                     func_index,; // наименование ф-ии, в которой создаются индексные файлы для данной БД
                     lstring,;    // строка текста с пояснением содержимого БД
                     fl_NET)      // флаг, указывающий, где создается БД, - на сервере или нет
Static sdbf := ".dbf"
Static err_2_task := "Вероятность повторного запуска задачи!"
Local adbf, fl := .f., lOldDeleted, lrec, i, is_time, buf := save_maxrow()
DEFAULT func_index TO "", lstring TO "", fl_NET TO .f.
file_base := lower(file_base)
if !(right(file_base,4) == sdbf)
  file_base += sdbf
endif
if !file(file_base)
  if !empty(lstring)
    stat_msg("Ждите! Создается база данных по "+lstring)
  endif
  dbcreate(file_base,struct_dbf)
  fl := .t.
elseif control_base(2)
  if !G_Use(file_base,,,.t.,!fl_NET)
    err_msg(err_2_task)
  endif
  adbf := dbstruct()
  lrec := lastrec()
  is_time := (lrec > 1000)
  use
  if !compare_arrays(adbf,struct_dbf)
    if !empty(lstring)
      stat_msg("Ждите! Перестраивается база данных по "+lstring)
    endif
    dbcreate("tmp",struct_dbf)
    if !G_Use("tmp",,,.t.,.t.)
      err_msg(err_2_task)
    endif
    vrec := (recsize()*lrec+header()+1)*1.3
    if diskspace() < vrec
      func_error("На диске не хватает "+lstr(vrec-diskspace(),15,0)+;
                                      " байт для перестроения базы данных")
      f_end()
    endif
    close databases
    //
    if is_time
      showtime(maxrow(),72,.f.,"G+/R")
    endif
    lOldDeleted := SET(_SET_DELETED, .F.)
    use tmp new
    append from (file_base) codepage "RU866"
    close databases
    //
    do while ferase(file_base) != 0
    enddo
    if fl_NET
      copy file tmp.dbf to (file_base)
      delete file tmp.dbf
    else
      rename tmp.dbf to (file_base)
    endif
    SET(_SET_DELETED, lOldDeleted)
    if is_time
      showtime()
    endif
    fl := .t.
  endif
endif
rest_box(buf)
if fl .and. !empty(func_index)
  if !("(" $ func_index)
    func_index += "()"
  endif
  if fl_NET
    G_Use(file_base,,,.t.,.t.)
  else
    use (file_base)
  endif
  fl := &(func_index)
endif
close databases
return NIL
