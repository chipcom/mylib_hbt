#include "edit_spr.ch"
#include "function.ch"
#include "inkey.ch"

***** вертикальное меню (с сохранением и восстановлением экрана)
FUNCTION popup_SCR(nTop, nLeft, nBottom, nRight, aArray, nInd, col,;
                   fl_shadow, n_func, regim, titul, titul_color, ;
                   mfunction, blk_color)
Local k, buf := savescreen()
k := popup(nTop, nLeft, nBottom, nRight, aArray, nInd, col,;
           fl_shadow, n_func, regim, titul, titul_color, ;
           mfunction, blk_color)
restscreen(buf)
return k

***** вертикальное меню
FUNCTION popup(nTop, nLeft, nBottom, nRight, aArray, nInd, col,;
               fl_shadow, n_func, regim, titul, titul_color, ;
               mfunction, blk_color)
// nTop,nLeft,nBottom,nRight - размеры окна
// aArray - массив
// nInd - текущий элемент
// col - цвет (строка или номер)
// fl_shadow - есть тень или нет
// n_func - имя функции пользователя (нажатие клавиш)
// regim - режим для popup_edit
// titul, titul_color - заголовок и его цвет
// mfunction - функция, вызываемая на каждом шаге TBrowse (рисование)
LOCAL oBrowse, oColumn, lCont := .t., cStatus, tmp_color := setcolor(),;
      nKey := 256, NSTR := nBottom-nTop-1, COUNT := LEN(aArray), ;
      fl_rbrd := .f., i, j, fl_mouse, x_mouse := 0, y_mouse := 0, km, ;
      color_find, static_find := "", buf_static, len_static, ;
      nsec := seconds(), period := 300
if COUNT == 0
  return 0
endif
Private last_k := 2, tmp, mnInd, parr := aArray
DEFAULT nInd TO 1, col TO color0, fl_shadow TO .f., n_func TO "", ;
        regim TO 0, mfunction TO "", blk_color TO .f.
nInd := if(nInd <= 0, 1, if(nInd > COUNT, COUNT, nInd))
if valtype(col) == "C"
  SETCOLOR(beforatnum(",",col))
elseif valtype(col) == "N"
  tmp := "color"+LSTR(col)
  SETCOLOR(&tmp)
endif
if !empty(n_func) .and. "(" $ n_func
  n_func := beforatnum("(",n_func)
endif
if !empty(mfunction) .and. !("(" $ mfunction)
  mfunction += "()"
endif
if fl_shadow
  put_shadow(nTop,nLeft,nBottom,nRight)
endif
@ nTop,nLeft TO nBottom,nRight DOUBLE
if titul != NIL
  tmp := " "+left(alltrim(titul),nRight-nLeft-3)+" "
  DEFAULT titul_color TO setcolor()
  @ nTop,nLeft+1+(nRight-nLeft-len(tmp))/2 SAY tmp color titul_color
endif
if NSTR < COUNT .and. NSTR > 4
  fl_rbrd := .t.
  @ nTop+1,nRight    say chr(30)
  @ nBottom-1,nRight say chr(31)
  for i := nTop+2 to nBottom-2
    @ i,nRight say chr(176)
  next
  @ nTop+last_k,nRight say chr(8)
endif
SETCURSOR(0)
oBrowse:= TBrowseNew(nTop+1, nLeft+1, nBottom-1, nRight-1)
oBrowse:colorSpec := if(valtype(col) == "C", col, &("color"+LSTR(col)))
oBrowse:goTopBlock := ;
     {|| nInd := 1, right_side(fl_rbrd, nInd, COUNT, nTop, nRight, NSTR) }
oBrowse:goBottomBlock := ;
     {|| nInd := COUNT, right_side(fl_rbrd, nInd, COUNT, nTop, nRight, NSTR) }
oBrowse:skipBlock := ;
     { |nSkip, nVar|  nVar := nInd,;
        nInd := IF(nSkip > 0, MIN(COUNT,nInd+nSkip), MAX(1,nInd+nSkip)),;
        right_side(fl_rbrd, nInd, COUNT, nTop, nRight, NSTR), nInd - nVar }
oColumn := TBColumnNew("", {|| padr(aArray[nInd],nRight-nLeft-3) })
if blk_color
  oColumn:colorBlock := {|| if("*" $ left(aArray[nInd],3), {1,2}, {3,4}) }
endif
oBrowse:addColumn(oColumn)
if (i := nInd) > COUNT-NSTR
  oBrowse:goBottom()
  for tmp := COUNT-1 TO i STEP -1
    oBrowse:up()
  next
endif
color_find := color_find(oBrowse:colorSpec)     // =============
buf_static := save_box(nTop,nLeft,nTop,nRight)  // =============
len_static := nRight - nLeft - 3                // =============
fl_mouse := SETPOSMOUSE()
DO WHILE lCont
  if nKey != 0
    oBrowse:forcestable()  // стабилизация
    mnInd := nInd
    if !empty(mfunction) ; tmp := &mfunction ; endif
    FT_MSHOWCRS(fl_mouse)
  endif
  nKey := 0
  /*if fl_mouse
    if (km := FT_MGETPOS()) == 2
      nKey := K_ESC
    elseif km == 1
      x_mouse := FT_MGETX() ; y_mouse := FT_MGETY()
      if between(x_mouse,nLeft+1,nRight-1)
        if between(y_mouse,nTop+1,nBottom-1)
          if y_mouse == (i := nTop + oBrowse:rowPos)
            nKey := K_ENTER
          elseif y_mouse > i
            for j := 1 to y_mouse-i
              keyboard CHR(K_TAB)  //  keysend(CHR(9)+CHR(15),.t.)  // KS_TAB
            next
          else
            for j := 1 to i-y_mouse
              keyboard CHR(K_SH_TAB)  //  keysend(CHR(0)+CHR(15),.t.)  // KS_SH_TAB
            next
          endif
          clear_mouse()
        elseif y_mouse == nTop
          nKey := K_SH_TAB
        elseif y_mouse == nBottom
          nKey := K_TAB
        endif
      elseif fl_rbrd .and. x_mouse == nRight
        if between(y_mouse,nTop+2,nBottom-2)
          if y_mouse < nTop+last_k
            nKey := K_PGUP
          elseif y_mouse > nTop+last_k
            nKey := K_PGDN
          endif
        elseif y_mouse == nTop+1
          nKey := K_SH_TAB
        elseif y_mouse == nBottom-1
          nKey := K_TAB
        endif
        clear_mouse()
      endif
    endif
  endif*/
  if nKey == 0
    nKey := INKEYTRAP()
  endif
  if nKey == 0
    if period > 0 .and. seconds() - nsec > period
      // если не трогали клавиатуру [period] сек., то выйти из функции
      nKey := K_ESC
    endif
  else
    nsec := seconds()
  endif
  if nKey != 0 .and. ;                                         // =============
     !((len(static_find) > 0 .and. nKey == 32) .or. between(nKey,33,255) ;
                                            .or. nKey == K_BS) // =============
    static_find := "" ; rest_box(buf_static)                   // =============
  endif                                                        // =============
  DO CASE
    CASE nKey == K_UP .or. nKey == K_SH_TAB
      FT_MHIDECRS(fl_mouse) ; oBrowse:up()
    CASE nKey == K_DOWN .or. nKey == K_TAB
      FT_MHIDECRS(fl_mouse) ; oBrowse:down()
    CASE nKey == K_PGUP
      FT_MHIDECRS(fl_mouse) ; oBrowse:pageUp()
    CASE nKey == K_PGDN
      FT_MHIDECRS(fl_mouse) ; oBrowse:pageDown()
    CASE nKey == K_HOME .or. nKey == K_CTRL_PGUP .or. nKey == K_CTRL_HOME
      FT_MHIDECRS(fl_mouse) ; oBrowse:goTop()
    CASE nKey == K_END .or. nKey == K_CTRL_PGDN .or. nKey == K_CTRL_END
      FT_MHIDECRS(fl_mouse) ; oBrowse:goBottom()
    CASE len(static_find) == 0 .and. nKey == 32 .and. ;
                         eq_any(regim,PE_APP_SPACE,PE_SPACE)  // пробел == 32
      lCont := .F.
    CASE nKey == K_ENTER
      if regim == PE_EDIT  // вызов ф-ии для редактирования
        FT_MHIDECRS(fl_mouse)
        tmp := n_func+"("+lstr(nKey)+","+lstr(nInd)+")"
        if (i := &tmp) == 0         // функция должна возвратить 0 для
          oBrowse:refreshAll()      // обновления TBrowse, иначе -1 (ничего)
        elseif i == 1               // или 1 для выхода из popup
          lCont := .f.
        endif
        nKey := 256
      else  // иначе выбор из меню
        lCont := .F.
      endif
    CASE nKey == K_ESC
      lCont := .F.
    CASE ((len(static_find) > 0 .and. nKey == 32) ;
                          .or. between(nKey,33,255) .or. nKey == K_BS) ;
                          .and. !equalany(nKey,43,45) // не + и -
      FT_MHIDECRS(fl_mouse)
      oBrowse:goTop()
      if nKey == K_BS
        if len(static_find) > 1
          static_find := left(static_find,len(static_find)-1)
        else
          static_find := ""
        endif
      else
        if len(static_find) < len_static
          static_find += Upper(CHR(nKey))
        endif
      endif
      put_static(buf_static,static_find,color_find)
      if !empty(static_find)
        tmp := len(static_find)
        if (i := ascan(aArray, {|x| static_find <= StrForPopup(x,tmp)} )) > 0
          if i < COUNT-NSTR+1
            oBrowse:goTop()
            nInd := i
            oBrowse:refreshAll()
            right_side(fl_rbrd, nInd, COUNT, nTop, nRight, NSTR)
          else
            oBrowse:goBottom()
            for tmp := COUNT-1 TO i STEP -1
              oBrowse:up()
            next
          endif
        else
          oBrowse:goBottom()
        endif
      endif
    CASE nKey != 0 .and. !empty(n_func)
      FT_MHIDECRS(fl_mouse)
      tmp := n_func+"("+lstr(nKey)+","+lstr(nInd)+")"
      if (i := &tmp) == 0         // функция должна возвратить 0 для
        oBrowse:refreshAll()      // обновления TBrowse, иначе -1 (ничего)
      elseif i == 1               // или 1 для выхода из popup
        lCont := .f.
      endif
      nKey := 256
  ENDCASE
ENDDO
if fl_mouse
  clear_mouse()
  FT_MHIDECRS()
endif
setcolor(tmp_color)
RETURN if(nKey == K_ESC, 0, nInd)

***** поиск по нач.букве в POPUP, игнорируя пробелы и "*"
Function StrForPopup(s,k)
Local i, j, c, ls
s := upper(s)
for i := 1 to len(s)
  c := substr(s,i,1)
  if !eq_any(c," ","*")
    j := i ; exit
  endif
next
if j == NIL
  j := 1
endif
ls := substr(s,j,k)
return padr(ls,k)
