#include "function.ch"
#include "inkey.ch"

Static ce := ""
Static smsg := " � ������ ^<Enter>^.    ^<Esc>^ - �४�饭�� ����."

***** �४���� �����
FUNCTION Stop_print
PRIVATE keystroke := 0
IF inkey() == K_ESC
  end_print := .T.
  SET DEVICE TO SCREEN
  stat_msg("��������, ���� �����⠥��� ���� �ਭ��.")
  mybell(3)
ENDIF
KEYBOARD ce
RETURN end_print

***** ��ॢ��� ��࠭��� (� ������������ ���ࠢ�� ������ ����)
FUNCTION myeject(s,yes_FF,ilist,sh)
LOCAL ch, is_middle := (sh != NIL)
DEFAULT yes_FF TO .t., ilist TO 0
if yes_FF
  @ PROW()+1,0 SAY ce
  EJECT
else
  @ PROW()+2,0 SAY ce
  if is_middle  // �᫨ �� ����� ���㬥��
    @ PROW()+1,0 SAY replicate("-",sh)  // ����� ����� ���뢠
  endif
  @ PROW()+2,0 SAY ce
endif
IF s != NIL
  SET DEVICE TO SCREEN
  mybell(0.1,OK)
  if ilist == 0
    status_key("���ࠢ�� ᫥���騩 ����"+smsg)
  else
    status_key("���ࠢ�� "+lstr(ilist)+"-� ���� ����"+smsg)
  endif
  if (ch := INKEY(0)) == K_ESC
    end_print := .T.
  ELSE
    status_key("^<Esc>^ - �४�饭�� ����")
    SET DEVICE TO PRINT
    SETPRC(0,0)
  ENDIF
ENDIF
RETURN NIL
