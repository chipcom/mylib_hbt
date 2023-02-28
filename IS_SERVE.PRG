#include 'function.ch'

*****
Function is_server(dir_s)
  // dir_s - путь к файл-серверу
  Local tmp_file, fp, err, s_err

  if empty(dir_s)
    return nil
  endif
  tmp_file := dir_s + '_t' + lstr(seconds(), 15, 0) + '.$$$'
  if (fp := fcreate(tmp_file)) == -1
    s_err := 'Не обнаружен путь доступа к файл-серверу: ' + dir_s
    err := ferror()
    do case
      case err == 4
        s_err := 'Слишком много открытых файлов'
      case err == 5
        s_err := 'Отказано в доступе к файл-серверу'
      case err == 8
        s_err := 'Нет памяти'
      case err == 15
        s_err := 'Неверно указано имя диска сервера'
      case err == 19
        s_err := 'Попытка записи на защищенный диск (сервер)'
      case err == 21
        s_err := 'Дисковод сервера не готов'
      case err == 29
        s_err := 'Ошибка записи на файл-сервер'
      case err == 32
        s_err := 'Нарушение совместного использования сервера'
      case err == 33
        s_err := 'Нарушение защиты сервера'
    endcase
    s_err += '! Код ошибки ' + lstr(err)
    func_error(s_err)
    SET COLOR TO
    SET CURSOR ON
    CLS
    QUIT
  endif
  fclose(fp)
  delete file (tmp_file)
  return nil
