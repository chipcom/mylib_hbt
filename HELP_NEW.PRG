******************************************************************************
* Новая HELP-система
******************************************************************************
* Что должно быть определено сразу после запуска программы:
* SET KEY K_F1 TO help_new     // вызов помощи по клавише F1
*   или helpkey() (это то же самое)
* Public cHelpCMain   := "N/W,W+/N"        // цвет экрана помощи
* Public cHelpCVagno  := "R/W,W+/R"        // цвет выделения важной информации
* Public cHelpCStatus := "N+/W"            // цвет статусной строки
* Public pub_name_help := "plat.hlp"       // наименование файла помощи
* Public nhelp_code := "..."   // строковая переменная, в которую в каждом
*     // режиме заносится новое значение, соответствующее своему экрану помощи
* (Для стыковки версий оставить определение старой переменной help_code := -1)
******************************************************************************
* Список функций:
*   вызов на экран содержания помощи
*        Function HelpContents()
*   формирование содержания - начало
*        Function cont_begin()
*   формирование содержания - "тело"
*        Function cont_hlp(notstup,shelp,stext)
*   просмотр содержания
*        Function cont_view()
*   служебная ф-ия, вызываемая из cont_view
*        Function f1cont_view(nKey,oBrow,regim)
*   процедура помощи (по F1)
*        PROCEDURE help_new(call_prg, line_num, input_var)
*   Чтение "куска" текста помощи из файла
*        Static FUNCTION helptext(shelp,par)
*   заголовок экрана помощи
*        Function t_hlp(s)
*   один абзац экрана помощи
*        Function s_hlp(nSpace,sStr,lVagno)
*                      (nSpace - количество пробелов впереди - по умолчанию = 2;
*                                если nSpace - массив из двух чисел, то второе
*                                число обозначает количество пробелов впереди
*                                каждой следующей строки - по умолчанию = 0)
*                      (sStr   - содержание абзаца в виде строки
*                      (lVagno - логич.параметр для выделения цветом (умол.=.f.)
*                      параметры nSpace и lVagno могут отсутствовать
*   вывод одной строки
*        Function l_hlp(symb,sh)
*               например: l_hlp() - вывод линии из символов "─" во всю ширину
*                         l_hlp("*") - вывод линии из звездочек во всю ширину
*                         l_hlp("*",5) - вывод пяти звездочек по центру
*                         l_hlp("строка") - вывод "строки" по центру
*                         l_hlp("строка",.t.) - подчеркнутая "строка" по центру
*   окончание экрана помощи
*        Function v_hlp()
*   просмотр экрана помощи
*        Static Function help_view(par)
*   служебная ф-ия, вызываемая из help_view
*        Function f1help_view(nKey,oBrow,regim,par)
*   сохранить текущее состояние программы перед вызовом HELP'а
*        Static Function save_hlp()
*   восстановить состояние программы, которое было перед вызовом HELP'а
*        Static Function rest_hlp()
*   вернуть значение переменной "nhelp_code", если она существует
*        Function ret_nhelp_code()
******************************************************************************
* Из программы можно вызывать только HelpContents() и help_new()
******************************************************************************
#include "fileio.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "inkey.ch"

#define _old_shb    1
#define s_tmp_color 2
#define s_tek_row   3
#define s_tek_col   4
#define s_tek_sost  5
#define s_keys      6
#define s_old_help  7
#define s_fl_mouse  8
#define s_screen    9
#define s_select   10
#define s__len     10

Static _help_uroven := 10  // max 10 уровней вложенности содержания
Static _help_width  := 64  // ширина экрана для просмотра HELP'а
Static _help_top    :=  4
Static _help_bottom := 22
Static _help_left   :=  6
Static _help_right  := 73
Static _help_title  := ""
Static _help_razdel

Static _tf_content := "tmp_hcon.dbf"
Static _tf_help := "tmp_help.dbf"

*

*****
Function HelpContents()
Local a_hlp
Parameters p_cont_par
a_hlp := save_hlp()
_help_razdel := NIL
exec_shb("contents")
rest_hlp(a_hlp)
return NIL

*****
Function cont_begin()
Local adbf := {{"help_text","C",_help_width,0},;
               {"help_code","C",15,0}}
dbcreate(_tf_content,adbf)
Use (_tf_content) new alias _CONT
return NIL

*****
Function cont_hlp(notstup,shelp,stext)
Static sotstup := 0
Local i, si, s, ta[2]
if notstup > _help_uroven
  return func_error(4,"cont_hlp: "+lstr(notstup))
endif
DEFAULT shelp TO ""
if _help_razdel == NIL
  _help_razdel := array(_help_uroven)
  afill(_help_razdel,0)
endif
if notstup < sotstup
  for i := notstup+1 to _help_uroven
    _help_razdel[i] := 0
  next
endif
++ _help_razdel[notstup]
sotstup := notstup
si := space((notstup-1)*2)
for i := 1 to notstup
  si += lstr(_help_razdel[i])+"."
next
si += " "+stext
for i := 1 to perenos(ta,si,_help_width)
  select _CONT
  append blank
  if i == 1
    _cont->help_text := ta[1]
  else
    _cont->help_text := padl(alltrim(ta[i]),_help_width)
  endif
  _cont->help_code := shelp
next
return NIL

*****
Function cont_view()
Local t_arr[BR_LEN], lhelp
t_arr[BR_TOP] := _help_top
t_arr[BR_BOTTOM] := _help_bottom
t_arr[BR_LEFT] := _help_left
t_arr[BR_RIGHT] := _help_right
t_arr[BR_COLOR] := cHelpCMain
t_arr[BR_ARR_BROWSE] := {,,,,.t.,600,,.t.}
t_arr[BR_FL_INDEX] := .f.
t_arr[BR_COLUMN] := {{center("Содержание помощи",_help_width), {|| _cont->help_text }}}
t_arr[BR_STAT_MSG] := {|| DevPos(24,0), DevOut(padc("<Esc> - выход;  <Enter> - выбор и просмотр раздела",80),cHelpCStatus) }
t_arr[BR_EDIT] := {|nk,ob| f1cont_view(nk,ob,"edit") }
commit
select _CONT
go top
if p_cont_par != NIL
  Locate for padr(upper(p_cont_par),15)==upper(_cont->help_code)
  if !found()
    go top
  endif
endif
edit_browse(t_arr)
_cont->(dbCloseArea())
return NIL

*****
Function f1cont_view(nKey,oBrow,regim)
Local ret := -1, buf
do case
  case regim == "edit"
    do case
      case nKey == K_ENTER
        if !empty(_cont->help_code)
          save screen to buf
          helptext(_cont->help_code,2)
          restore screen from buf
          select _CONT
        endif
    endcase
endcase
return ret

*

***** процедура помощи (по F1)
PROCEDURE help_new(call_prg,line_num,input_var,lhelp)
Local k, a_hlp
if lhelp == NIL .and. type("nhelp_code") == "C" .and. !empty(nhelp_code)
  lhelp := nhelp_code
endif
if lhelp != NIL .and. !empty(lhelp)
  a_hlp := save_hlp()
  delete file (_tf_help)
  k := helptext(lhelp,1)
  rest_hlp(a_hlp)
  if k != NIL
    HelpContents(lhelp)
  endif
endif
RETURN

***** Чтение "куска" текста помощи из файла шаблона
Static FUNCTION helptext(shelp,par)
Local ret := exec_shb(shelp), ret1
if !(valtype(ret)=="N" .and. ret==0) .and. file (_tf_help)
  ret1 := help_view(par)
endif
return ret1

***** процедура, вызываемая изнутри уже запущенной HELP-системы
PROCEDURE help_newIN(lhelp)
Local ret := exec_shb(lhelp), ret1
if !(valtype(ret)=="N" .and. ret==0)
  ret1 := help_view(0)
endif
return ret1

*

***** заголовок экрана помощи
Function t_hlp(s)
Local ta[2], i, k
Local adbf := {{"help_text", "C",_help_width,0},;
               {"help_vagno","L",          1,0}}
// заголовок (может быть многострочным)
_help_title  := ""
for i := 1 to perenos(ta,s+" (экран помощи)",_help_width)
  _help_title += padc(alltrim(ta[i]),_help_width)+";"
next
_help_title := substr(_help_title,1,len(_help_title)-1)
// создание временного файла
dbcreate(_tf_help,adbf)
Use (_tf_help) new alias _HLP
return NIL

***** один абзац экрана помощи
Function s_hlp
Local i, p, ta[2], n := 2, n1 := 0, s := "", lvagno := .f.
Parameters par1,par2,par3
for i := 1 to 3
  p := &("par"+lstr(i))
  if valtype(p) == "N"
    n := p
    n1 := n+2
  elseif valtype(p) == "A"
    n := p[1]
    n1 := p[2]
  elseif valtype(p) == "C"
    s := p
  elseif valtype(p) == "L"
    lvagno := p
  endif
next
s := space(n)+charone(" ",s)
select _HLP
for i := 1 to perenos(ta,s,_help_width-n1)
  append blank
  if empty(n1) .or. i == 1
    _hlp->help_text := ta[i]
  else
    _hlp->help_text := space(n1)+ta[i]
  endif
  _hlp->help_vagno := lvagno
next
return NIL

***** примеры использования
*  l_hlp() - вывод линии из символов "─" во всю ширину
*  l_hlp("*") - вывод линии из звездочек во всю ширину
*  l_hlp("*",5) - вывод пяти звездочек по центру
*  l_hlp("строка") - вывод "строки" по центру
*  l_hlp("строка",.t.) - подчеркнутая "строка" по центру
*****
Function l_hlp(symb,par2)
Local l, s, sh, fl_underline := .f.
DEFAULT symb TO "─"
if par2 == NIL
  sh := _help_width
elseif valtype(par2) == "N"
  sh := par2
else
  fl_underline := .t.
endif
if (l := len(symb)) == 1
  s := padc(replicate(symb,sh),_help_width)
else
  s := padc(symb,_help_width)
endif
select _HLP
append blank
_hlp->help_text := s
if l > 1 .and. fl_underline
  append blank
  _hlp->help_text := padc(replicate("─",l),_help_width)
endif
return NIL

***** окончание экрана помощи
Function v_hlp()
_hlp->(dbCloseArea())
return NIL

*

***** просмотр экрана помощи
Static Function help_view(par)
// par = 0 - вызов из программы (не работает выход в содержание)
// par = 1 - вызов из программы
// par = 2 - вызов из содержания
Local t_arr[BR_LEN], s, lcolor, blk
if type("cHelpCVagno") == "C"
  if numat(",",cHelpCMain) == 1
    lcolor := cHelpCMain
  else
    lcolor := beforatnum(",",cHelpCMain,2)
  endif
  lcolor += ","+cHelpCVagno
  blk := {|| iif(_hlp->help_vagno, {3,4}, {1,2}) }
endif
t_arr[BR_TOP]    := _help_top
t_arr[BR_BOTTOM] := _help_bottom
t_arr[BR_LEFT]   := _help_left
t_arr[BR_RIGHT]  := _help_right
t_arr[BR_COLOR]  := cHelpCMain
t_arr[BR_COLUMN] := {{_help_title, {|| _hlp->help_text }, blk}}
t_arr[BR_ARR_BROWSE] := {,,,lcolor,.t.,600,,.t.}
t_arr[BR_FL_INDEX] := .f.
if par == 0
  s := "<Esc> - вернуться в программу"
elseif par == 1
  s := "<Esc> - вернуться в программу;  <F10> - выход в содержание"
else
  s := "<Esc> - вернуться в содержание"
endif
t_arr[BR_STAT_MSG]  := {|| DevPos(24,0), DevOut(padc(s,80),cHelpCStatus) }
t_arr[BR_EDIT] := {|nk,ob| f1help_view(nk,ob,"edit",par) }
Use (_tf_help) new alias _HLP
go top
Private p_k_f10
edit_browse(t_arr)
_hlp->(dbCloseArea())
delete file (_tf_help)
return p_k_f10

*****
Function f1help_view(nKey,oBrow,regim,par)
Local ret := -1, buf
do case
  case regim == "edit"
    do case
      case nKey == K_F10 .and. par == 1
        ret := p_k_f10 := 1
    endcase
endcase
return ret

*

***** сохранить текущее состояние программы перед вызовом HELP'а
Static Function save_hlp()
Local ret[s__len]
ret[s_screen] := savescreen()
ret[s_fl_mouse] := IS_MOUSE_ON_SCREEN()
FT_MHIDECRS(s_fl_mouse)
//ret[s_tek_sost] := CSETALL()
SET KEY K_F1 TO
ret[s_old_help] := nhelp_code
ret[s_keys] := my_savekey()
ret[s_tek_row] := ROW()
ret[s_tek_col] := COL()
ret[s_tmp_color] := SETCOLOR(cHelpCMain)
change_attr()
SETCURSOR(0)
ret[s_select] := select()
if type("task_shb") == "C"
  ret[_old_shb] := task_shb      // запомнить наменование файла-шаблона задачи
else
  Public task_shb
endif
if type("pub_name_help") == "C"  // Public-переменная в вызывающей программе
  task_shb := pub_name_help      // наименование скомпилированного help-файла
else
  task_shb := "help.hlp"         // наименование help'а по умолчанию
endif
return ret

***** восстановить состояние программы, которое было перед вызовом HELP'а
Static Function rest_hlp(ar)
if ar[s_select] > 0
  select (ar[s_select])
endif
if ar[_old_shb] == NIL
  release task_shb
else
  task_shb := ar[_old_shb]
endif
SETCOLOR(ar[s_tmp_color])
@ ar[s_tek_row],ar[s_tek_col] SAY ""
my_restkey(ar[s_keys])
nhelp_code := ar[s_old_help]
helpkey()
//CSETALL(ar[s_tek_sost])
FT_MSHOWCRS(ar[s_fl_mouse])
restscreen(ar[s_screen])
return NIL

*

*****
Function helpkey()
// вызов помощи по клавише F1
SetKey( K_F1, {|p, l, v| help_new(p, l, v)} )
return NIL
