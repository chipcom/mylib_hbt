#include "function.ch"
#include "inkey.ch"

***** �஢�ઠ ��⮢���� � ࠡ�� �ਭ��
FUNCTION print_flag(k)
// k - ����� ����, 楫�� �᫮ �� 1 �� 3 - (LPT1,LPT2,LPT3)
LOCAL fl := .F., bbuf := save_maxrow()
DO WHILE .T.
  status_key('�᫨ �ਭ�� ��⮢ � ࠡ��, ������ ���� �������. ^<Esc>^ - �⪠� �� ����.')
  IF inkeytrap(0) == K_ESC
    EXIT
  ENDIF
  IF !PRINTREADY(k)
    stat_msg('�ਭ�� �� ��⮢.')
    mybell(1)
  ELSE
    fl := .T.
    EXIT
  ENDIF
ENDDO
REST_BOX(bbuf)
RETURN fl
