#include 'function.ch'

// проверить существование каталога и корректное имя файла
Function VerDirFile(d)
  Local lfile, ldir
  // вернуть имя файла без пути
  lfile := StripPath(d)
  if !filevalid(lfile)
    func_error(4, 'Некорректное имя файла: ' + upper(lfile))
    return NIL
  endif
  // вернуть путь без имени файла
  ldir := KeepPath(d)
  is_server(ldir, cur_dir)
  return d
