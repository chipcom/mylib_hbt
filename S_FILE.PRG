#include "function.ch"

*****
Function search_file(_fname,par)
// par = 1 - начинаем с каталога запуска задачи
// par = 2 - начинаем с каталога баз данных
Local ret, _path := upper(beforatnum("\",exename()))+"\"
DEFAULT par TO 1
if par == 1 .and. file(_path+_fname)         // сначала каталог запуска задачи
  ret := _path+_fname
else
  if type("DIR_SERVER") != "C"
    Private dir_server := ""
  endif
  if file(dir_server+_fname)  // каталог на файл-сервере
    ret := dir_server+_fname
  elseif file(_fname)         // текущий каталог
    ret := _fname
  endif
  if ret == NIL .and. par == 2 .and. file(_path+_fname) // каталог запуска задачи
    ret := _path+_fname
  endif
endif
return ret

***** правильно проставляет окончание в слове "файл" в зависимости от кол-ва
Function num_files(i)
Local t := str(i,3), s1, s2, s := "файлов"
s1 := right(t,1)
s2 := left(right(t,2),1)
if s2 != "1"
  if s1 == "1"
    s := "файл"
  elseif s1 == "2" .or. s1 == "3" .or. s1 == "4"
    s := "файла"
  endif
endif
return ltrim(t)+" "+s
