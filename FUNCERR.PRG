#include "function.ch"
#include "inkey.ch"

***** печать сообщения об ошибке в 24 строке экрана
FUNCTION func_error(num,string)
// Использование:
// func_error(<n>,<string>) - музыка, ожидание <n> секунд, возврат .f.
// func_error(<string>) - музыка, ожидание 10 секунд, возврат .f.
LOCAL buf := save_maxrow(), icur := SetCursor(0)
if string == NIL
  string := num
  num := 10
endif
stat_msg(ALLTRIM(string))
mybell(num,ERROR)
if icur > 0
  SETCURSOR()
endif
REST_BOX(buf)
RETURN .F.
