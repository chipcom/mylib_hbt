#include "inkey.ch"
#include "function.ch"

*****
Function get_cfg()
Local k, s, s1, nMax, nMin, cString, ff, gpasskod := ret_gpasskod(), ;
      tip_proc, exe_name := upper(beforatnum(".",exename()))
if "\" $ exe_name
  exe_name := afteratnum("\",exe_name)
endif
if !file(s := exe_name+".CFG")
  func_error("На диске нет файла конфигурации "+s)
  if lastkey() == K_CTRL_F1
    f1_get_cfg(exe_name,gpasskod)
  endif
  SET COLOR TO
  SET CURSOR ON
  CLS
  QUIT
endif
s := filestr(s)
if (tip_proc := cputype()) > 7
  tip_proc := 7
endif
nMax := 61424
nMin := 57784
cString := PEEKSTR(61440, nMin, nMax-nMin)      // F000 - сегмент
ff := ltrim(str(ASCIISUM(cString)))+ltrim(str(CHECKSUM(cString)))
ff += PADR(dtoc(biosdate()),8)+PADR(str(tip_proc,1),1)+PADR(str(pctype(),3),3)
ff += exe_name
k := len(ff)
if len(s) > k
  s1 := substr(s,k+1)
  s1 := crypt(s1,gpasskod)
  s := left(s,k)
endif
if !(s == crypt(ff,gpasskod))
  func_error("Несанкционированная копия программы!")
  if lastkey() == K_CTRL_F1
    f1_get_cfg(exe_name,gpasskod)
  endif
  SET COLOR TO
  SET CURSOR ON
  CLS
  QUIT
endif
return s1

*****
Function f1_get_cfg(exe_name,gpasskod)
Local s := str_random(), s2
CLS
@ 16,0 say center("Необходимо сообщить следующее число:",80)
@ 17,0 say center("<< "+left(s,5)+"-"+substr(s,6,5)+"-"+substr(s,11,5)+;
                                                  "-"+right(s,5)+" >>",80)
Private s1 := space(20)
@ 19,19 say "Введите ответный шифр" get s1 picture "@R 99999-99999-99999-99999"
@ 20,0 say center("               (<Esc> - отказ от установки задачи)",80)
myread({"confirm"})
if lastkey() == K_ESC
  return NIL
endif
//
s2 := Unit(s,s1,gpasskod)
s1 := crypt("гП╓╨T~╖╘",gpasskod)
if !(s1 == s2)
  return NIL
endif
nMax := 61424
nMin := 57784
if (tip_proc := cputype()) > 7
  tip_proc := 7
endif
cString := PEEKSTR(61440, nMin, nMax-nMin)      // F000 - сегмент
ff := ltrim(str(ASCIISUM(cString)))+ltrim(str(CHECKSUM(cString)))
ff += PADR(dtoc(biosdate()),8)+PADR(str(tip_proc,1),1)+PADR(str(pctype(),3),3)
ff := crypt(ff+upper(exe_name),gpasskod)
file_cfg := exe_name+".cfg"
strfile(ff,file_cfg)
cls
@ 12,0 say center("Установка произведена !!!",80)
?? chr(7)
inkey(1)
return NIL

*****
function str_random()
Local p[7], s := "", s1, tip_proc
if (tip_proc := cputype()) > 7
  tip_proc := 7
endif
p[1] := charrem(".",PADR(biosdate(),8))
p[2] := PADR(tip_proc,1)
p[3] := PADR(pctype(),3)
p[4] := PADR(memsize(.F.),4)
p[5] := PADR(memsize(.T.),4)
p[6] := ltrim(str(seconds(),10,0))
p[7] := charrem(".",padr(date(),8))
for i = 1 to 7
 s += alltrim(p[i])
next
s1 := charmix(ltrim(str(checksum(s))),ltrim(str(asciisum(s))))
charone(@s1)
if random()%2 > 0
  charmirr(@s1)
endif
if random()%2 > 0
  charswap(@s1)
endif
do while len(s1) < 20
  i := len(s1)
  s1 := padright(s1,i+1,str(random()%10,1))
enddo
return left(s1,20)

*****
FUNCTION Unit(cInp, cdop, gpasskod)
LOCAL cBase := "░Н■є*~yУєъ√√bБ╓нЩб`Ъ·hE╛╩T│┴]Ю2╞╖g╖ЪттЮEРр`Є]", ;
      nlen, i, j, nline, nlet, cbase1, rezult := ""
cbase := crypt(cbase,gpasskod)
nLen := LEN(cInp)
FOR i:= 1 TO nLen STEP 2
  nLine := VAL(SUBSTR(cInp,i,2))
  nLet := VAL(SUBSTR(cDop,i,2))
  cbase1 := cbase
  for j := 1 to nline
    cbase1 := justleft(cbase1,LEFT(cbase1,1))
  next
  rezult += substr(cbase1,nLet,1)
NEXT
return rezult
