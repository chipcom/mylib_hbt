#include "function.ch"
#include "inkey.ch"

***** ��ᨢ�� "���窠"
FUNCTION music_m(k)
LOCAL i, mdelay1 := 1, mdelay2 := 2
if type("MUSIC_ON_OFF") == "L" .and. !MUSIC_ON_OFF
  return NIL
endif
k := upper(k)
if k == "OK"        // ok - �� ��ࠥ��� � ��砥 �ᯥ�
  FOR i := 1 to 50 STEP 10
    TONE(150+i*50,mdelay2)
  NEXT
elseif k $ "ERROR"  // error - � �� - � ��砥 �訡��
  FOR i := 1 to 50 STEP 5
    TONE(650+i*30,mdelay1)
  NEXT
  FOR i := 60 to 1 STEP -10
    TONE(580+i*30,mdelay2)
  NEXT
endif
RETURN NIL
