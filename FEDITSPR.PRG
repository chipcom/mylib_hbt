#include "fileio.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "inkey.ch"
#include "getexit.ch"

*****
Function read_int(h)
Local s := "  "
fread(h, @s, 2)
return bin2i(s)

#define rnul if(is_file, i, i+1-m_screen[tek_screen,1])

***** функция редактирования баз данных типа "справочник"
Function f_edit_spr(pp,mas_name,sname,use_func,len_key,tkod,t_help,;
                    del_func,file_screen,clear_area,func_write)
// pp -       режим
// mas_name - указатель на массив
// sname -    строка с наименованием в дат. падеже
// use_func - имя функции для открытия базы данных
// len_key -  длина ключевого поля (или 0 в случае отсутствия в БД поля KOD)
//Необязательные параметры:
// tkod -     код для поиска (номер записи в случае отсутствия в БД поля KOD)
// t_help -   номер help'а (по старому) или строка help'а (по новому)
// del_func - имя функции для проверки допустимости удаления (параметр = 1)
//            и выполнения каких-либо действий после (параметр = 2) удаления
// file_screen - наименование файла экранного формата
// clear_area  - массив из 5 эл-тов - координаты очищаемой области и номер
//               строки для вывода заголовка (-1 в случае отсутствия заголовка)
// func_write  - имя функции для выполнения каких-либо действий
//               перед (параметр = 1) записью и после (параметр = 2) записи
Local i, j, fl := (pp != A__APPEND), s_msg := "", l_msg := "", buf, ;
      tmp_help, tmp_nhelp, k, k1, tmp_color := setcolor(),;
      m_screen := {}, tek_screen := 1, t_nhelp,;
      len_mas := len(mas_name), keystroke, rr := 1, fp, is_file := .f.,;
      i1, i2, i3, f_dostup := .t., shirina, vysota, fl_write,;
      fl_mouse, x_mouse, y_mouse, bSaveHandler, old_set
Private tmp, tmp1, tmp2, tmp3, func_val, mpic, kol_screen := 1
if pp != A__VIEW .and. !ver_dostup(pp!=A__DELETE)
  return 0
endif
do case
  case pp == A__VIEW
    i1 := 1 ; i2 := "fEditSprVi"
  case pp == A__EDIT .or. pp == A__APPEND
    i1 := 2 ; i2 := "fEditSprEd"
  case pp == A__DELETE
    i1 := -1 ; i2 := ""
endcase
if t_help == NIL
  t_nhelp := i2
elseif valtype(t_help) == "C"
  t_nhelp := t_help
  t_help := -1
endif
DEFAULT len_key TO 0, tkod TO 0, t_help TO i1, del_func TO "", ;
        clear_area TO {1,0,23,79,0}, func_write TO ""
Private gl_arr := mas_name,;  // скопировать указатель на гл.массив
        gl_area := clear_area // и указатель на массив области экрана
                              // для функции menu_reader()
shirina := clear_area[4]-clear_area[2]
vysota  := clear_area[3]-clear_area[1]-1
if !empty(del_func := alltrim(del_func)) .and. "(" $ del_func
  del_func := beforatnum("(",del_func)
endif
if !empty(func_write := alltrim(func_write)) .and. "(" $ func_write
  func_write := beforatnum("(",func_write)
endif
if file_screen != NIL
  if !("." $ file_screen)
    file_screen += ".frm"
  endif
  is_file := ((file_screen := search_file(file_screen)) != NIL)
endif
save screen to buf
if fl
  if !&use_func
    return 0
  endif
  if len_key > 0
    find (str(tkod,len_key))
    if !found()
      use
      func_error("Ошибка! Неудачный поиск в базе данных.")
      return 0
    endif
  else
    goto (tkod)
    if eof() .or. deleted()
      use
      func_error("Ошибка! Неудачный поиск в базе данных.")
      return 0
    endif
  endif
endif
mywait()
tmp_help := if(type("chm_help_code")=="N", chm_help_code, help_code)
chm_help_code := help_code := t_help
// для новой HELP-системы
tmp_nhelp := ret_nhelp_code()
nhelp_code := t_nhelp
if len_key > 0
  mkod := if(fl, kod, 0)
else
  mkod := if(fl, recno(), 0)
endif
if is_file
  fp := fopen(file_screen, FO_READ + FO_SHARED)
  kol_screen := read_int(fp)
  for i := 1 to kol_screen
    k := read_int(fp)
    aadd(m_screen, {1,k})
    tmp1 := "scr__"+lstr(i)
    Private &tmp1 := array(k)
    tmp := space(10)
    for j := 1 to k
      fread(fp, @tmp, 10)
      if (i1 := ascan(mas_name, ;
                      {|x| padr(upper(x[A__NAME]),10) == tmp})) == 0
        err_msg("В массиве нет поля базы данных - "+tmp)
      endif
      i2 := read_int(fp)
      i3 := read_int(fp)
      &tmp1[j] := {i1,i2,i3}
    next
    k := read_int(fp)
    tmp2 := "proc__"+lstr(i)
    Private &tmp2 := {}
    if k > 0
      &tmp2 := array(k)
      afill(&tmp2, "")
    endif
    for j := 1 to k
      if (i1 := read_int(fp)) > 0
        tmp := space(i1)
        fread(fp, @tmp, i1)
        &tmp2[j] := tmp
      endif
    next
    k := read_int(fp)
    tmp3 := "say__"+lstr(i)
    Private &tmp3 := array(k)
    afill(&tmp3, "")
    for j := 1 to k
      if (i1 := read_int(fp)) > 0
        tmp := space(i1)
        fread(fp, @tmp, i1)
        &tmp3[j] := tmp
      endif
    next
  next
  fclose(fp)
else
  if len_mas <= vysota
    aadd(m_screen, {1,len_mas})
  else
    j := vysota
    i := len_mas - j
    aadd(m_screen, {1,j})
    do while i > vysota
      kol_screen++
      aadd(m_screen, {j+1,j+vysota})
      j += vysota
      i -= vysota
    enddo
    if i > 0
      kol_screen++
      aadd(m_screen, {j+1,len_mas})
      if len_mas - j < 3
        j := len_mas - 3
        m_screen[kol_screen,1] := j+1
        m_screen[kol_screen-1,2] := j
      endif
    endif
  endif
endif
if kol_screen == 1 .and. len_mas < vysota-6
  rr += (vysota-1-len_mas)/2
endif
for i := 1 to len_mas
  tmp1 := mas_name[i,A__NAME]
  tmp := "m" + tmp1
  Private &tmp
  if fl
    &tmp := FIELD->&tmp1
  else
    &tmp := mas_name[i,A__INIT]
  endif
  if (tmp2 := is_element(mas_name[i],A__FIND)) != NIL
    tmp1 := "m1" + tmp1
    Private &tmp1 := &tmp
    &tmp := eval(tmp2, &tmp)
  endif
next
if fl
  use
endif
do case
  case pp == A__VIEW
    s_msg := "Просмотр данных по "+sname
    l_msg := "^<Esc>^ - выход"
  case pp == A__EDIT
    s_msg := "Редактирование данных по "+sname
  case pp == A__APPEND
    s_msg := "Добавление данных по "+sname
  case pp == A__DELETE
    s_msg := "Удаление данных по "+sname+" из базы данных"
endcase
if pp == A__EDIT .or. pp == A__APPEND
  if kol_screen == 1
    l_msg := "^<Esc>^ - выход без записи;  ^<PgDn>^ - подтверждение записи"
  else
    l_msg := "^<Esc>^ - выход для записи;  ^<>^ - перемещение по полям"
  endif
  if help_code >= 0 .or. !empty(nhelp_code)
    l_msg += ";  ^<F1>^ - помощь"
  endif
endif
if clear_area[5] > 0
  s_msg := padc(' '+s_msg+' ',80,"░")
endif
if clear_area[5] >= 0
  pr_1_str(s_msg,clear_area[5])
endif
status_key(l_msg)
old_set := __SetCentury( "on" )
do while .t.
  fl_write := .f.
  setcolor(cDataCScr)
  @ clear_area[1],clear_area[2] clear to clear_area[3],clear_area[4]
  if is_file
    tmp := "say__"+lstr(tek_screen)
    for i := 1 to len(&tmp)
      @ i+clear_area[1],clear_area[2] say &tmp[i]
    next
    tmp := "proc__"+lstr(tek_screen)
    bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
    BEGIN SEQUENCE
    for i := 1 to len(&tmp)
      tmp1 := &tmp[i]
      k := &tmp1
    next
    RECOVER USING error
      // ничего
    END
    ERRORBLOCK(bSaveHandler)
  else
    for i := m_screen[tek_screen,1] to m_screen[tek_screen,2]
      @ rr+rnul+clear_area[1]-1,clear_area[2]+1 say mas_name[i,A__SAY]
    next
  endif
  if pp == A__EDIT .or. pp == A__APPEND .or. pp == A__VIEW
    setcolor(cDataPgDn)
    if tek_screen > 1
      @ clear_area[1],clear_area[2] say ;
             padl("<PageUp> - предыдущая страница",shirina)
    endif
    if tek_screen < kol_screen
      @ clear_area[3],clear_area[2] say ;
             padl("<PageDown> - следующая страница",shirina)
    endif
  endif
  dispbegin()
  setcolor(if(pp == A__EDIT .or. pp == A__APPEND, cDataCGet, cDataCSay))
  for i := m_screen[tek_screen,1] to m_screen[tek_screen,2]
    if is_file
      tmp2 := "scr__"+lstr(tek_screen)
      j := &tmp2[i,1]
    else
      j := i
    endif
    if is_file
      tmp1 := shirina + 1 - &tmp2[i,3]
    else
      tmp1 := shirina - 2 - len(mas_name[j,A__SAY])
    endif
    tmp := "m" + mas_name[j,A__NAME]
    if mas_name[j,A__PICTURE] == NIL
      if type(tmp) == "C"
        mpic := if(len(&tmp) > tmp1, "@S"+lstr(tmp1), "")
      elseif mas_name[j,A__TYPE] == "N"
        mpic := replicate("9",mas_name[j,A__LEN])
        if mas_name[j,A__DEC] > 0
          mpic := stuff(mpic,len(mpic)-mas_name[j,A__DEC],1,".")
        endif
      else
        mpic := ""
      endif
    elseif type(tmp) == "C" .and. len(&tmp) > tmp1
      mpic := mas_name[j,A__PICTURE] + "@S"+lstr(tmp1)
    else
      mpic := mas_name[j,A__PICTURE]
    endif
    if pp == A__EDIT .or. pp == A__APPEND
      if is_file
        @ &tmp2[i,2]+clear_area[1],clear_area[2]+&tmp2[i,3]-1 ;
                                                get &tmp picture mpic
      else
        @ rr+rnul+clear_area[1]-1,clear_area[2]+shirina-tmp1 ;
                                                get &tmp picture mpic
      endif
      GetList[rnul]:reader := mas_name[j,A__BLOCK]
      GetList[rnul]:preBlock := is_element(mas_name[j],A__WHEN)
      GetList[rnul]:postBlock := is_element(mas_name[j],A__VALID)
    else
      if is_file
        @ &tmp2[i,2]+clear_area[1],clear_area[2]+&tmp2[i,3]-1 ;
                                                 say &tmp picture mpic
      else
        @ rr+rnul+clear_area[1]-1,clear_area[2]+shirina-tmp1 ;
                                                 say &tmp picture mpic
      endif
    endif
  next
  dispend()
  if pp == A__EDIT .or. pp == A__APPEND
    if kol_screen == 1
      myread()
    else
      set key K_ESC to f1_edit_spr
      myread({"escape"})
      set key K_ESC to
    endif
    keystroke := lastkey()
  else
    if pp == A__DELETE
      exit
    else
      fl_mouse := SETPOSMOUSE() ; FT_MSHOWCRS(fl_mouse)
      do while .t.
        keystroke := 0
        /*if fl_mouse
          if FT_MGETPOS() == 1
            x_mouse := FT_MGETX() ; y_mouse := FT_MGETY()
            if y_mouse == clear_area[1] .and. between(x_mouse,;
                       clear_area[2]+shirina-29,clear_area[2]+shirina-24)
              keystroke := K_PGUP
            elseif y_mouse == clear_area[3] .and. between(x_mouse,;
                       clear_area[2]+shirina-30,clear_area[2]+shirina-23)
              keystroke := K_PGDN
            elseif y_mouse == 24 .and. between(x_mouse,34,36)
              keystroke := K_ESC
            endif
          endif
        endif*/
        if keystroke == 0
          keystroke := inkeytrap()
        endif
        if keystroke == K_PGDN .or. keystroke == K_PGUP .or. keystroke == K_ESC
          exit
        endif
      enddo
      if fl_mouse
        clear_mouse() ; FT_MHIDECRS()
      endif
    endif
  endif
  if kol_screen > 1
    if keystroke == K_PGDN
      if tek_screen < kol_screen
        tek_screen++
      endif
      loop
    elseif keystroke == K_PGUP
      if tek_screen > 1
        tek_screen--
      endif
      loop
    endif
  endif
  if keystroke == K_CTRL_W .or. keystroke == K_ESC .or. ;
                           (kol_screen == 1 .and. keystroke == K_PGDN)
    if (pp == A__APPEND .or. pp == A__EDIT)
      if kol_screen == 1
        j := f_alert({padc("Выберите действие",60,".")},;
               {" Выход без записи "," Запись "," Возврат в редактирование "},;
               if(keystroke==K_ESC,1,2),"W+/N","N+/N",22,,"W+/N,N/BG" )
        if j == 3
          loop
        elseif j == 2
          if !empty(func_write) .and. !&(func_write+"(1)")
            loop
          else
            fl_write := .t.
          endif
        endif
      else
        if f_Esc_Enter(1)
          if !empty(func_write) .and. !&(func_write+"(1)")
            loop
          else
            fl_write := .t.
          endif
        endif
      endif
    endif
    exit
  endif
enddo
tmp := mkod ; mkod := 0
if pp == A__DELETE
  mkod := tmp ; tmp := 0 // чтобы в "del_func" можно было использовать mkod
  i := .t.
  if !empty(del_func) .and. !&(del_func+"(1)")
    i := .f.
  endif
  if i .and. f_Esc_Enter(2) .and. &use_func
    if len_key > 0
      find (str(tkod,len_key))
    else
      goto (tkod)
    endif
    tmp := recno()
    if DeleteRec(.t.)
      if !empty(del_func)
        i := &(del_func+"(2)")
      endif
    else
      tmp := 0
    endif
  endif
  mkod := tmp
endif
if (pp == A__APPEND .or. pp == A__EDIT) .and. fl_write
  mywait()
  if &use_func
    if fl
      if len_key > 0
        find (str(tkod,len_key))
      else
        goto (tkod)
      endif
      f_dostup := G_RLock()
    else
      if len_key > 0
        f_dostup := AddRec(len_key,,(type("pr_fl_is_0")=="L"))
      else
        f_dostup := AddRecN()
      endif
    endif
    if f_dostup
      mkod := recno()
      set order to 0
      if len_key > 0
        replace kod with mkod
      endif
      for i := 1 to len(mas_name)
        tmp1 := mas_name[i,A__NAME]
        tmp := "m" + tmp1
        if is_element(mas_name[i],A__FIND) != NIL
          tmp2 := "m1" + tmp1
          replace &tmp1 with &tmp2
        else
          replace &tmp1 with &tmp
        endif
      next
      if !empty(func_write)
        i := &(func_write+"(2)")
      endif
    endif
  endif
endif
close databases
chm_help_code := help_code := tmp_help
nhelp_code := tmp_nhelp
setcolor(tmp_color)
restore screen from buf
__SetCentury( old_set )
return mkod

***** вместо кода <Esc> (отказ от записи) послать в буфер клавиатуры <CTRL>+W
Function f1_edit_spr
keyboard chr(K_CTRL_W)
return NIL
