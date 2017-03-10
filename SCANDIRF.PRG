#include "inkey.ch"
#include "function.ch"

***** то же, что и ScanFiles, но по одной директории cPath
FUNCTION SCANDIRFILES(cPath, cFilespec, blk)
LOCAL cFile
DEFAULT cPath TO "", cFilespec TO "*.*"
cFile := FILESEEK(cPath + cFileSpec , 32)
DO WHILE !EMPTY(cFile)
  eval(blk, cPath + cFile)         // вызов блока кода для каждого файла
  cFile := FILESEEK()              // следующий файл
ENDDO
RETURN NIL                         // возвращаемое значение неважно
