#include "function.ch"

***** �뢮� ᮮ�饭�� � "������쭮�" �訡�� � ��室 �� �����
FUNCTION err_msg(s)
DEFAULT s TO "������쭠� �訡��"
SET DEVICE TO SCREEN
stat_msg(s)
mybell(10,ERROR)
f_end()
RETURN NIL
