#include "Box.ch"
#include "inkey.ch"
#include "function.ch"

***** окно общего назначения (с возможностью редактирования переменных)
Function DisplBox()
Parameter ;
  CTEXT, ;     // текст в окне, ( \ - перевод строки, @ - Get'ы )
  CPARCOLOR, ; // цвет окна (умолч. - cDataCGet)
  AGETS, ;     // массив Private-переменных для редактирования
  APICTS, ;    // массив Picture для редактирования
  NROW, ;      // row - левый верхний угол окна (по умолч. - центрирование)
  NCOL, ;      // col - левый верхний угол окна (по умолч. - центрирование)
  AWHEN, ;     // массив блоков кода условий WHEN
  AVAL, ;      // массив блоков кода условий VALID
  CFRAME, ;    // тип рамки ( в стиле box.ch ) (умолч. - B_DOUBLE)
  YES_BUF,;    // восстанавливать ли экран после работы (умолч. - да)
  CTITLE,;     // заголовок
  COLORTITLE   // цвет заголовка
Local _kol_str, max_len, _r1, _r2, _c1, _c2, _tmp_color, i, arr_str := {},;
      _pict, _val, _when, _buf
Private CMAC, AROWGETS := {}, ACOLGETS := {}, GetList := {}
DEFAULT CPARCOLOR TO cDataCGet, CFRAME TO B_DOUBLE + " ", YES_BUF TO .t.
_kol_str := numat("\", CTEXT)
max_len := 0
for i := 1 to _kol_str
  aadd(arr_str, token(CTEXT, "\", i))
  max_len := max(max_len, len(arr_str[i]))
next
_r1 := if(NROW == NIL, (24 - _kol_str - 1) / 2, NROW)
_r2 := _r1 + _kol_str + 1
_c1 := if(NCOL == NIL, (80 - max_len - 1) / 2, NCOL)
_c2 := _c1 + max_len + 1
if _r1 < 0 ;  _r1 := 0 ;  endif
if _r2 > 23 ; _r2 := 23 ; endif
if _c1 < 0 ;  _c1 := 0 ;  endif
if _c2 > 79 ; _c2 := 79 ; endif
for i := 1 to _kol_str
  if AGETS != NIL .and. !empty(AGETS)
    PutAdrGets(i, arr_str[i], _r1, _c1)
  endif
next
_tmp_color := setcolor(CPARCOLOR)
_buf := savescreen()
dispbox(_r1, _c1, _r2, _c2, CFRAME)
if !empty(ctitle)
  ctitle := " "+left(alltrim(ctitle),_c2-_c1-3)+" "
  if colortitle != NIL
    setcolor(colortitle)
  endif
  @ _r1,_c1+(_c2-_c1+1-len(ctitle))/2 SAY ctitle
  setcolor(CPARCOLOR)
endif
PUT_SHADOW(_r1,_c1,_r2,_c2)
for i := 1 to _kol_str
  DevPos(_r1 + i, _c1 + 1)
  DevOut(arr_str[i])
next
if AGETS != NIL .and. !empty(AGETS)
  for i := 1 to len(AGETS)
    CMAC := AGETS[i]
    _pict := if(APICTS != NIL .and. !empty(APICTS) .and. APICTS[i] != NIL, ;
                                                             APICTS[i], "")
    _when := {|| .t. }
    if AWHEN != NIL .and. !empty(AWHEN) .and. AWHEN[i] != NIL
      _when := AWHEN[i]
    endif
    _val := {|| .t. }
    if AVAL != NIL .and. !empty(AVAL) .and. AVAL[i] != NIL
      _val := AVAL[i]
    endif
    SetPos(AROWGETS[i], ACOLGETS[i])
    aadd(GetList, __GET(NIL, CMAC, _pict, _val, _when):DISPLAY() )
  next
  SETCURSOR()
  READMODAL(GetList)
  GetList := {}
  SETCURSOR(0)
endif
if YES_BUF
  restscreen(_buf)
endif
setcolor(_tmp_color)
Return NIL

*****
Static Function PutAdrGets(_i, _l_str, _r, _c)
Local j, _kg
for j := 1 to 100
  _kg := atnum("@", _l_str, j)
  if _kg > 0
    AADD(AROWGETS, _r + _i)
    AADD(ACOLGETS, _c + _kg)
  else
    exit
  endif
next
Return NIL
