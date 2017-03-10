#include "inkey.ch"

***** функция по умолчанию для завершения программы
FUNCTION f_end()
CLOSE DATABASES
hard_err("delete")
SET KEY K_ALT_F4 TO
SET KEY K_ALT_F3 TO
SET KEY K_ALT_F2 TO
SET KEY K_ALT_X TO
SET COLOR TO
SET CURSOR ON
CLS
QUIT
RETURN NIL
