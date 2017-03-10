#include "function.ch"

***** вывод сообщения о "глобальной" ошибке и выход из задачи
FUNCTION err_msg(s)
DEFAULT s TO "Глобальная ошибка"
SET DEVICE TO SCREEN
stat_msg(s)
mybell(10,ERROR)
f_end()
RETURN NIL
