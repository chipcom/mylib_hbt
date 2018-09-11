#include "inkey.ch"
#include "function.ch"

#define 	KS_ESC			  CHR(27)  + CHR(1)
#define 	KS_TAB			  CHR(9)   + CHR(15)
#define 	KS_ENTER		  CHR(13)  + CHR(28)
#define 	KS_HOME 		  CHR(224) + CHR(71)

***** вывести в строке <r> эмблемы "ЧИП"
Function put_chip(r)
// ничего
return NIL

***** 26.02.18 головная функция работы в первом (горизонтальном) меню
Function func_main(fl_exit,blk)
// fl_exit = .t. для разрешения выхода по ESC
LOCAL selItem, i, arr_mouse
DEFAULT fl_exit TO .f.
chm_help_code := help_code := 3
nhelp_code := "MainScreen"
max_glLock := len(main_menu)
Public rmain_menu := 0, It_main_menu[max_glLock]
afill(It_main_menu,1)
arr_mouse := _make_first()
FillScreen(p_char_screen,p_color_screen)
SETCOLOR(color0)
@ 0,0
put_chip()
if valtype(blk) == "B"
  eval(blk)
endif
selItem := 1
do while .t.
  setmtcolor(col1menu)
  @ maxrow(),0
  set message to maxrow() center
  for i := 1 to max_glLock
    @ rmain_menu,cmain_menu[i] PROMPT main_menu[i] MESSAGE main_message[i]
  next
  MENU TO selItem
  if selItem > 0
    gen_Menu(selItem,arr_mouse)
  elseif selItem == 0 .and. fl_exit
    exit
  endif
enddo
return NIL

***** 26.02.18 служебная функция для увеличения скорости работы в главном меню
FUNCTION _make_first()
LOCAL i, j, l, r1 := rmain_menu+1, c1, r2, c2, aName, aLine, arr_m[max_glLock]
Public _first_menu[max_glLock]
set message to maxrow() center
for j := 1 to max_glLock
  aName := aclone(first_menu[j])
  aLine := {}
  tmp := len(aName)
  c1 := cmain_menu[j]
  for i := tmp to 1 step -1
    if valtype(aName[i]) != "C"
      aadd(aLine,i)
      adel(aName, i)
      --tmp
    endif
  next
  asize(aName, tmp)
  l := 0
  for i := 1 to tmp
    c2 := len(aName[i] := " "+aName[i])
    l := max(l,if("~" $ aName[i], c2-1, c2))
  next
  l++
  aeval(aName, {|x,i| aName[i] := padr(x,if("~" $ x, l+1, l))})
  r2 := r1+len(first_menu[j])+1
  c2 := c1+l+1
  if c2 > maxcol()-2
    c2 := maxcol()-2
    c1 := c2-l-1
  endif
  setmtcolor(col1menu)
  tmp := 0
  FOR i := 1 TO len(first_menu[j])
    if valtype(first_menu[j,i]) == "C"
      ++tmp
      @ i+r1, c1+1 PROMPT aName[tmp] MESSAGE first_message[j,tmp]
    endif
  NEXT
  _first_menu[j] := {aName,r1,c1,r2,c2,aLine,SaveMenuTo()}
  arr_m[j] := {rmain_menu,cmain_menu[j],;
               rmain_menu,cmain_menu[j]+len(main_menu[j])-2,{KS_ESC,KS_HOME}}
  for i := 2 to j
    aadd(arr_m[j,5], KS_TAB)
  next
  aadd(arr_m[j,5], KS_ENTER)
next
return arr_m

***** 26.02.18 Главное меню (1-го уровня)
FUNCTION gen_Menu( number, arr_mouse )
LOCAL i, buf, selItem, tmp_help, tmp_nhelp
LOCAL aName := _first_menu[number,1], aFunc := func_menu[number]
LOCAL amessage := first_message[number], r1, c1, r2, c2
tmp_help := if(type("chm_help_code")=="N", chm_help_code, help_code)
// для новой HELP-системы
tmp_nhelp := ret_nhelp_code()
Private tmp, T_ROW, T_COL
r1 := _first_menu[number,2]
c1 := _first_menu[number,3]
r2 := _first_menu[number,4]
c2 := _first_menu[number,5]
buf := savescreen(r1,c1,r2+1,c2+2)
@ r1,c1 clear to r2,c2
@ r1,c1 to r2,c2 double
put_shadow(r1,c1,r2,c2)
do while .t.
  chm_help_code := 3
  help_code := 4
  nhelp_code := "_1_menu"
  setcolor(color0)
  @ maxcol(),0
  FOR i := 1 TO len(_first_menu[number,6])
    @ _first_menu[number,6,i]+r1, c1 say "╟"+replicate("─",c2-c1-1)+"╢"
  NEXT
  RestMenuTo(_first_menu[number,7])
  set key K_RIGHT to R_ARROW
  set key K_LEFT to L_ARROW

  selItem := It_main_menu[number]
  MENU TO selItem REGION arr_mouse

  set key K_RIGHT to
  set key K_LEFT to

  IF selItem == 0
    exit
  ELSE
    It_main_menu[number] := selItem
    if aFunc[selItem] != NIL .and. !empty(aFunc[selItem])
      tmp := 0
      FOR i := 1 TO len(first_menu[number])
        if valtype(first_menu[number,i]) == "C"
          ++tmp
          if tmp == selItem
            T_ROW := r1+1+i
            exit
          endif
        endif
      next
      T_COL := c1
      chm_help_code := help_code := -1
      nhelp_code := ""
      i := &(aFunc[selItem]) //  вызов функции
    else
      exit
    endif
  ENDIF
enddo
restscreen(r1,c1,r2+1,c2+2,buf)
chm_help_code := help_code := tmp_help
nhelp_code := tmp_nhelp
RETURN selItem

***** 26.02.18 имитация POPUP с помощью MENU TO
Function popup_prompt(r1, c1, sItem, m_prompt, m_msg, m_func, m_color, fl_clear, k_help)
Local r2 := r1+1+len(m_prompt), c2, m1_prompt[len(m_prompt)], i, tlen := 0, buf, ;
      tmp_color := setcolor(), k_nhelp, tmp_help, tmp_nhelp, COUNT := len(m_prompt), k, tr, tc
if type("T_ROW") == "N"
  tr := T_ROW ; tc := T_COL
endif
Private tmp, T_ROW := tr, T_COL := tc
if k_help == NIL
  k_nhelp := "_2_menu"
elseif valtype(k_help) == "C"
  k_nhelp := k_help
endif
DEFAULT sItem TO 1, m_color TO col2menu, fl_clear TO .t., k_help TO 5
if COUNT == 0
  return 0
endif
for i := 1 to COUNT
  m1_prompt[i] := " "+m_prompt[i]
  k := len(m1_prompt[i])
  tlen := max(tlen,if("~" $ m1_prompt[i],k-1,k))
next
++tlen
for i := 1 to COUNT
  m1_prompt[i] := padr(m1_prompt[i], if("~" $ m1_prompt[i], tlen+1, tlen))
next
c2 := c1+tlen+1
if c2 > maxcol()-2
  c2 := maxcol()-2
  c1 := c2-tlen-1
endif
if r1 < 0
  r2 += abs(r1) ; r1 := 0
endif
if r2 > maxrow()-1
  r1 -= (r2-(maxrow()-1)) ; r2 := maxrow()-1
endif
tmp_help := if(type("chm_help_code")=="N", chm_help_code, help_code)
// для новой HELP-системы
tmp_nhelp := ret_nhelp_code()
SETCOLOR(beforatnum(",",m_color,2))
buf := box_shadow(r1,c1,r2,c2)
do while .t.
  SETCOLOR(beforatnum(",",m_color,2))
  SETMTCOLOR(m_color)
  chm_help_code := help_code := k_help
  nhelp_code := k_nhelp
  if m_msg != NIL
    @ maxrow(),0
    set message to maxrow() center
  endif
  FOR i := 1 TO len(m1_prompt)
    if m_msg != NIL
      @ i+r1, c1+1 PROMPT m1_prompt[i] MESSAGE m_msg[i]
    else
      @ i+r1, c1+1 PROMPT m1_prompt[i]
    endif
  NEXT
  MENU TO sItem
  if sItem == 0 .or. m_func == NIL
    exit
  elseif empty(m_func[sItem])
    exit
  else
    T_ROW := r1+1+sItem
    T_COL := c1
    chm_help_code := help_code := -1
    nhelp_code := ""
    i := &(m_func[sItem])
  endif
enddo
if fl_clear
  REST_BOX(buf)
endif
setcolor(tmp_color)
chm_help_code := help_code := tmp_help
nhelp_code := tmp_nhelp
RETURN sItem

***** печать "первой" (или r-ой) строки (s) с отображением "ЧИП"
Function pr_1_str(s,r)
Local tmp_color := setcolor(color0)
DEFAULT r TO 0
@ r,0 say padc(alltrim(s),maxcol()+1)
put_chip(r)
setcolor(tmp_color)
return NIL

***** процедура используется для перемещения вправо в главном меню
PROCEDURE R_Arrow
KEYBOARD CHR(K_ESC) + CHR(K_RIGHT) + CHR(K_ENTER)
RETURN

***** процедура используется для перемещения влево в главном меню
PROCEDURE L_Arrow
KEYBOARD CHR(K_ESC) + CHR(K_LEFT) + CHR(K_ENTER)
RETURN
