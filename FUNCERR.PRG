#include "function.ch"
#include "inkey.ch"

***** ����� ᮮ�饭�� �� �訡�� � 24 ��ப� ��࠭�
FUNCTION func_error(num,string)
// �ᯮ�짮�����:
// func_error(<n>,<string>) - ��몠, �������� <n> ᥪ㭤, ������ .f.
// func_error(<string>) - ��몠, �������� 10 ᥪ㭤, ������ .f.
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
