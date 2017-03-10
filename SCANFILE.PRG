#include "inkey.ch"
#include "function.ch"

**************************************************************************
* Функция    : SCANFILES()
* Copyright  : (c) 1990, 1991, 1992 Computer Associates International Inc.
*            : Все права сохраняются.
* Дата       : 06/20/90
* Автор      : Michael Peters / Lothar Bongartz
* Возвращает : Функция возвращает NIL
* Применение : Используя эту функцию, можно обработать содержимое
*              указанной директории и всех поддиректорий. Обработке
*              подвергаются все файлы, указанные в параметре FileSpec.
*              Допускается указание шаблона. Таким образом можно
*              организовать достаточно сложную обработку файлов,
*              подобно XDEL или FILEFIND, прямо из прикладной программы.
*
* Пример     : cFilespec  := "*.PRG"  // Все .PRG файлы
*              cStartPath := "\"      // начиная с корневой директории
*
* Следующие параметры и соответствующие исправления и добавления в функции
* введены Бабенко К.В.
*          blk := {|x|QOUT(x)}
*          blk := {|x|deletefile(x)}  // блок кода для каждого файла
*          if_delete := .t.           // флаг удаления файлов
*                                     // .t., если в blk стоит deletefile,
*                                     //      иначе .f.
*          SCANFILES(cStartPath, cFilespec, blk, if_delete)
**************************************************************************
FUNCTION SCANFILES(cPath, cFilespec, blk, if_delete)
LOCAL cSeekEnv, cFile               // для сохранения среды FILESEEK
Local i                             // при рекурсивных вызовах
DEFAULT cPath TO "", if_delete TO .f.
// сначала обрабатываются поддиректории
cFile := FILESEEK(cPath + "*.*", 16, .T.)
DO WHILE !EMPTY(cFile)
  IF LEFT(cFile,1) <> "."          // ".." и "." - "мнимые" директории
    IF ISBIT(FILEATTR(),5)         // поддиректория ?
      cSeekEnv := SAVEFSEEK()      // сохранение среды FILESEEK
      // рекурсивный вызов с дополненным путем доступа
      SCANFILES(cPath + cFile + "\", cFilespec, blk, if_delete)
      if if_delete
        dirremove(cPath + cFile)
      endif
      RESTFSEEK(cSeekEnv)          // восстановление среды
    ENDIF
  ENDIF
  cFile := FILESEEK()              // следующая поддиректория
ENDDO
cFile := FILESEEK(cPath + cFileSpec , 32)
DO WHILE !EMPTY(cFile)
  eval(blk, cPath + cFile)         // вызов блока кода для каждого файла
  cFile := FILESEEK()              // следующий файл
ENDDO
RETURN NIL                         // возвращаемое значение неважно