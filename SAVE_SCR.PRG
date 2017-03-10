#include "function.ch"

***** á®åà ­¥­¨¥ íªà ­  ¢ ä ©«¥
Function MySaveScr()
Static num_screen := 1
LOCAL i, s := ""
if num_screen == 1
  delete file screen.txt
endif
tone(450,4) ; tone(480,8)
s += "Ú"+replicate("Ä",80)+"¿"+eos
for i := 1 to 25
  s += "³"+atrepl("°",charodd(screenstr(i-1,0,80))," ")+"³"+eos
next
s += "À"+replicate("Ä",80)+"Ù"+eos
strfile(s, "screen.txt", .t.)
tone(480,4) ; tone(450,8)
++num_screen
return NIL
