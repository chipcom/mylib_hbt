#include "inkey.ch"
#include "function.ch"

Static max_FR_date_dbf := 9

#define lat_find   70   // <F>ind
#define lat_lfind 102   // f
#define rus_find  128   // русская "А" на том же месте, что и F
#define rus_lfind 160   // а
#define lat_next   78   // <N>ext
#define lat_lnext 110   // n
#define rus_next  146   // русская "Т" на том же месте, что и N
#define rus_lnext 226   // т

***** вызывается по умолчанию из viewtext для печати файла
*  Обрабатываемые клавиши:
*    <F6> - встать на указанный лист (перемещение
*           документа в окне просмотра на определенный лист).
*    <F7> - печать указанного листа.
*    <F8> - печать нескольких листов (с какого-то
*           по какой-то; для печати до конца документа введите
*           второе значение = 9999).
*    <F9> - печать всего документа.
*****
Function pr_view(keystroke,regim,inst_print,name_file,yes_FF,is_question)
Local s, s1, fl := .f., rec1 := ft_recno(), buf := save_maxrow(), ;
      nepr_print, tm, m_nlq := 0, kol_list, lport := 1, is_albom,;
      k := 0, l_margin := "", _i, t_list, sh1, sh2, sh3, sh4, sh5, ;
      fl_exit, rec, fl_begin, sh
if keystroke == K_F10
  export_to_WIN_editor()
  ft_goto( rec1 )
  rest_box(buf)
  return .t.
endif
DEFAULT is_question TO .t. // задавать вопросы перед печатью
if !eq_any(keystroke,K_F9,K_F8,K_F7,K_F6,K_CTRL_PGUP,K_CTRL_PGDN,;
           lat_find,rus_find,lat_next,rus_next,;
           lat_lfind,rus_lfind,lat_lnext,rus_lnext)
  return .f.
endif
if !(type("_p_list_2") == "N")
  Private _p_list_2 := 0, _p_list_3 := 0, ;
          _p_list_4 := 0, _p_list_5 := 0, _p_list_6 := 0
endif
is_albom := _upr_isalbom()
yes_FF := _upr_yes_FF(yes_FF)
//name_file := "ttt.txt"   // для отладки
do case
  case keystroke == K_F9  // весь документ
    tm := {.t.,1,9999}
    ft_gotop()
  case keystroke == K_F8  // с какого-то листа по какой-то лист
    tm := input_list(2)
  case keystroke == K_F7  // один лист
    tm := input_list(1)
  case keystroke == K_F6  // встать на лист
    tm := input_list(1)
    fl := tm[1]
  case keystroke == K_CTRL_PGUP  // на предыдущий лист
    fl := find_list(-1)
  case keystroke == K_CTRL_PGDN  // на следующий лист
    fl := find_list(1)
  case equalany(keystroke,lat_find,rus_find,lat_lfind,rus_lfind)
    fl := find_stroke(1)
  case equalany(keystroke,lat_next,rus_next,lat_lnext,rus_lnext)
    fl := find_stroke(2)
endcase
if eq_any(keystroke,K_F7,K_F8,K_F9) .and. tm[1]
  if _upr_windows() // печать через Windows
    prn_Window(regim,tm,is_albom)
    ft_goto( rec1 )
    rest_box(buf)
    return fl
  endif
  s := inst_print
  if regim % 3 == 0      // Condensed
    k := 17
    inst_print := "Condensed"
    m_nlq := 1
  elseif regim % 3 == 2  // Elita
    k := 12
    inst_print := "Elite"
  elseif regim % 3 == 1  // Pica
    k := 10
    inst_print := "Pica"
  endif
  inst_print += iif(regim < 4, "6", "8")
  if !empty(s) // если на входе другая функция управления кодами принтера
    inst_print := s
  endif
  if k > 0 // расчет левого отступа
    if (k := round(_upr_otstup() * k / 2.54, 0) ) > 0
      l_margin := space(k)
    endif
  endif
  **************************************
  end_print := .F.
  kol_list := tm[3] - tm[2] + 1
  lport := _upr_port()
  nepr_print := (_upr_nepr() == 2)
  if is_question // задать вопросы
    fl_begin := (m_nlq := yes_nlq(m_nlq,_upr_epson())) > 0 .and. ;
                            if(empty(name_file),print_flag(lport),.t.)
  else  // просто проверить порт принтера
    m_nlq := 1 ; _p_list_2 := 0 ; nepr_print := .t.
    if !(fl_begin := PRINTREADY(lport))
      stat_msg('Принтер не готов.')
      mybell(1)
    endif
  endif
  if (fl := fl_begin)
    status_key("^<Esc>^ - прекращение печати")
    SET DEVICE TO PRINT
    if !empty(name_file)
      SET PRINTER TO &(name_file)
    elseif lport == 2
      SET PRINTER TO LPT2
    endif
    put_code(_upr_init())
    if is_albom
      put_code(_upr_Albom())  // включить альбомную печать ESC+"&l1O"
    endif
    SETPRC(0,0)
    k := &(inst_print+"(1)")
    if m_nlq == 2
      put_code(_upr_nlq())
    endif
    private bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
    BEGIN SEQUENCE
    if _p_list_2 == 0 // обычная печать
      sh := 0
      do while !ft_eof()
        s := ft_readln()
        IF f_stroke_next_page(s)
          kol_list--
          if kol_list == 0 ; exit ; endif
          if nepr_print ; myeject(,yes_FF,,sh)
          else          ; myeject(1,yes_FF,,sh)
          endif
        ELSE
          @ prow()+1,0 say l_margin+s
          sh := max(sh,len(l_margin+s))
        ENDIF
        IF Stop_Print()
          fl := .f.
          exit
        ENDIF
        ft_skip()
      enddo
    else  // "разрезание" листа на части при печати
*
      fl_exit := .f.
      t_list := retShCut(@sh1,@sh2,@sh3,@sh4,@sh5)
      do while !ft_eof()
        rec := ft_RecNo()
        for _i := 1 to t_list
          if _i > 1
            ft_GoTo(rec)
          endif
          do while .t.
            s := ft_readln()
            IF f_stroke_next_page(s) .or. ft_eof()
              if _i == t_list
                kol_list--
                if kol_list == 0
                  fl_exit := .t.
                  exit
                endif
              endif
              if iif(_i==t_list, !ft_eof(), .t.)
                if nepr_print ; myeject(,yes_FF,iif(_i==t_list,0,_i+1),sh)
                else          ; myeject(1,yes_FF,iif(_i==t_list,0,_i+1),sh)
                endif
                ft_skip()
              endif
              EXIT
            ELSE
              s1 := retS1Cut(_i,s,sh1,sh2,sh3,sh4,sh5)
              @ prow()+1,0 say l_margin+s1
              sh := len(l_margin+s1)
            ENDIF
            IF Stop_Print()
              fl_exit := .t.
              exit
            ENDIF
            ft_skip()
          enddo
          if fl_exit ; exit ; endif
        next
        if fl_exit ; exit ; endif
      enddo
      fl := !fl_exit
    endif
    SET DEVICE TO PRINT
    myeject(,yes_FF)
    if m_nlq == 2
      put_code(_upr_draft())
    endif
    if is_albom
      put_code(_upr_Portr())  // включить портретную печать ESC+"&l0O"
    endif
    k := &(inst_print+"(2)")
    if !empty(name_file) .or. lport == 2
      SET PRINTER TO
    endif
    RECOVER USING error
      set device to screen
      fl := func_error("Ошибка принтера")
    END
    // Восстановление начальной программы обработки ошибок
    ERRORBLOCK(bSaveHandler)
    SET DEVICE TO SCREEN
  endif
  ft_goto( rec1 )
endif
rest_box(buf)
RETURN fl

*

*****
Static Function input_list(par)
Static nom_list := 1
Local rec1 := ft_recno(), flag := .f., buf, nom2_list,;
      buf1 := save_maxrow(), i := 1, tmp_color := setcolor(color0+",,,B/BG")
status_key("^<Esc>^ - отказ;  ^<Enter>^ - подтверждение ввода")
if par == 1
  buf := box_shadow(20,20,22,59)
  @ 21,28 say "Введите номер листа" get nom_list picture "9999"
elseif par == 2
  nom2_list := nom_list
  buf := box_shadow(20,2,22,77)
  @ 21,11 say "Введите, с какого" get nom_list picture "9999"
  @ 21,34 say "по какой" get nom2_list picture "9999" range nom_list,9999
  @ 21,48 say "лист печатать документ"
endif
myread({"confirm"})
if lastkey() != K_ESC
  ft_gotop()
  if nom_list == 1
    flag := .t.
  else
    mywait()
    do while !ft_eof()
      s := ft_readln()
      if f_stroke_next_page(s)
        if ++i == nom_list
          flag := .t.
          ft_skip()
          exit
        endif
      endif
      ft_skip()
    enddo
  endif
  if !flag
    func_error(3,"Нет такого листа")
    ft_goto( rec1 )
  endif
endif
rest_box(buf)
rest_box(buf1)
setcolor(tmp_color)
if par == 1
  nom2_list := nom_list
endif
return {flag,nom_list,nom2_list}

*****
Static Function find_list(k)
Local rec1 := ft_recno(), fl := .f., buf := save_maxrow(), i := 0
mywait()
if k == 1  // следующий лист
  if ft_RecNo() < ft_LastRec()
    fl := .t.
    do while !ft_eof()
      if ++i > 1 .and. f_stroke_next_page(ft_readln())
        exit
      endif
      ft_skip()
    enddo
  endif
  if ft_RecNo() == ft_LastRec()
    keyboard chr(K_END)
  endif
else  // предыдущий лист
  if ft_RecNo() > 1
    fl := .t.
    do while ft_RecNo() > 1
      if ++i > 1 .and. f_stroke_next_page(ft_readln())
        exit
      endif
      ft_skip(-1)
    enddo
  endif
  if ft_RecNo() == 1
    keyboard chr(K_HOME)
  endif
endif
if !fl
  ft_goto( rec1 )
  //mybell()
endif
rest_box(buf)
return fl

***** 01.09.16 для перевода русских слов в верхний регистр с учётом буквы "ё"
Function RUpper(s)
return charrepl("ё",upper(s),"Ё")

***** 01.09.16
Static Function find_stroke(par)
Static str_find := ""
Local rec1 := ft_recno(), fl := .f., buf := save_maxrow(), k, arr := {}
if par == 1
  if (k := input_value(20,2,22,77,color0,;
        "Введите ключ для поиска",padr(str_find,48),"@K@!")) != NIL
    if !empty(k)
      fl := .t.
      str_find := alltrim(RUpper(k))
    endif
  endif
elseif par == 2
  if !empty(str_find)
    fl := .t.
  endif
endif
if fl
  for k := 1 to numtoken(str_find,"|")
    aadd(arr, alltrim(token(str_find,"|",k)))
  next
  fl := .f.
  mywait()
  if par == 2
    ft_skip()
  endif
  do while !ft_eof()
    s := RUpper(ft_readln())
    for k := 1 to len(arr)
      if arr[k] $ s
        fl := .t.
      endif
    next
    if fl ; exit ; endif
    ft_skip()
  enddo
  if !fl
    func_error(3,"Неудачный поиск!")
    ft_goto( rec1 )
  endif
  rest_box(buf)
endif
return fl

*

*****
Static Function retShCut(sh1,sh2,sh3,sh4,sh5)
Static max_sh := 768
Local t_list := 2
sh1 := _p_list_2
if _p_list_3 == 0
  sh2 := max_sh
else
  t_list := 3 ; sh2 := _p_list_3
  if _p_list_4 == 0
    sh3 := max_sh
  else
    t_list := 4 ; sh3 := _p_list_4
    if _p_list_5 == 0
      sh4 := max_sh
    else
      t_list := 5 ; sh4 := _p_list_5
      if _p_list_6 == 0
        sh5 := max_sh
      else
        t_list := 6 ; sh5 := _p_list_6
      endif
    endif
  endif
endif
return t_list

*****
Static Function retS1Cut(i,s,sh1,sh2,sh3,sh4,sh5)
Local s1 := ""
if i == 1
  s1 := left(s,sh1-1)
elseif i == 2
  s1 := substr(s,sh1,sh2-sh1)
elseif i == 3
  s1 := substr(s,sh2,sh3-sh2)
elseif i == 4
  s1 := substr(s,sh3,sh4-sh3)
elseif i == 5
  s1 := substr(s,sh4,sh5-sh4)
else
  s1 := substr(s,sh5)
endif
return s1

*

*****
Function Pica6()
put_code(_upr_10cpi())
return NIL

*****
Function Elite6(k)
if k == 1
  put_code(_upr_12cpi())
else
  put_code(_upr_10cpi())
endif
return NIL

*****
Function Condensed6(k)
if k == 1
  put_code(_upr_17cpi())
else
  put_code(_upr_10cpi())
endif
return NIL

*****
Function Pica8(k)
if k == 1
  put_code(_upr_8lpi()) ; put_code(_upr_10cpi())
else
  put_code(_upr_6lpi()) ; put_code(_upr_10cpi())
endif
return NIL

*****
Function Elite8(k)
if k == 1
  put_code(_upr_8lpi()) ; put_code(_upr_12cpi())
else
  put_code(_upr_6lpi()) ; put_code(_upr_10cpi())
endif
return NIL

*****
Function Condensed8(k)
if k == 1
  put_code(_upr_8lpi()) ; put_code(_upr_17cpi())
else
  put_code(_upr_6lpi()) ; put_code(_upr_10cpi())
endif
return NIL

*****
Static Function yes_nlq(k,is_epson)
Static mnlq := 1
Local m := mnlq, tmp_color := setcolor(color0), buf
if is_epson
  if k == 0
    buf := box_shadow(11,6,15,72,,"Выбор режима печати")
    @ 13,12 prompt " Обычная печать (Draft) "
    @ 13,39 prompt " Качественная печать (NLQ) "
    menu to m
    if m > 0
      mnlq := m
    endif
    rest_box(buf)
  else
    m := k
  endif
else
  m := 1
endif
setcolor(tmp_color)
return m

*****
Static Function put_code(s)
Local kol, j, s1
if (kol := numtoken(s," ")) == 0
  return NIL
endif
for j := 1 to kol
  s1 := int(val(token(s," ",j)))
  @ prow(),pcol() say chr(s1)
next
return NIL

*

*****
Function export_to_WIN_editor()
Local k, s, name_win := "WIN_FILE"+stxt
delete file (name_win)
if file(name_win)
  return func_error(4,"Файл с именем "+name_win+" открыт другим приложением")
endif
mywait()
fp := fcreate(name_win)
ft_gotop()
do while !ft_eof()
  s := ft_readln()
  if f_stroke_next_page(s)
    add_string(chr(12))
  else
    add_string(win_OEMToANSI(s))
  endif
  ft_skip()
enddo
fclose(fp)
k := _upr_WINedit()
if !between(k,0,2)
  k := 0
endif
s := {"write.exe","Winword.exe","swriter.exe"}[k+1]
stat_msg("Выгрузка файла в редактор "+s)
//ShellExecute(GetDeskTopWindow(),'open',s,cur_dir+'\'+name_win,,1)
ShellExecute(GetDeskTopWindow(),'open',s,name_win,,1)
return NIL

*

#include "FastRepH.ch"

***** 22.05.16
Function prn_Window(regim,tm,is_albom)
DEFAULT tm TO {.t.,1,9999}, is_albom TO _upr_isalbom()
PRIVATE lShowCustName := .t.
PRIVATE FrPrn := frReportManager():new(,.t.) // .t. ошибки выводятся в OEM кодировке
FrPrn:SetIcon("MAIN_ICON")
if type("name_view_file") == "C"
  FrPrn:SetTitle("Предварительный просмотр файла "+name_view_file)
endif
FrPrn:StartManualBuild({|| MyTxtFR(regim,tm,is_albom) }, iif(is_albom,1,0), , FR_CM)
FrPrn:ShowReport()
FrPrn:ClearDataSets()
lShowCustName := .f.
FrPrn:DestroyFR()
RETURN

*****
PROCEDURE MyTxtFR(iRegim,tm,is_albom)
Local msize, len_stroke, kol_list, s, s1, nwidth, widthList, _top,;
      nLeft, nRight, nTop, nBottom,;
      nlpi := 2.54/iif(iRegim<4,6,8)*1.05,; // перевод 6 или 8 lpi в см
      rec, _i, t_list, sh1, sh2, sh3, sh4, sh5, fl_exit
//
kol_list := tm[3] - tm[2] + 1
len_stroke := ft_StrLen()
FrPrn:SetDefaultFontProperty("Name", "Lucida Console")
if iRegim = 1 .or. iRegim = 4    // Pica
  msize := iif(len_stroke < 65, 12, 11)
elseif iRegim = 2  // Elite
  msize := iif(len_stroke < 85, 10, 9)
elseif iRegim = 5  // Elite
  msize := 9
elseif iRegim = 3 .or. iRegim = 6  // Condensed
  //FrPrn:SetDefaultFontProperty("Style", 1) // Bold
  msize := iif(len_stroke < 110, 8, 7)
endif
FrPrn:SetDefaultFontProperty("Size", msize)
if is_albom
  widthList := 29.7
  nLeft   := _upr_otstup("b")
  nright  := _upr_otstup("t")
  nTop    := _upr_otstup("l")
  nBottom := _upr_otstup("r")
else
  widthList := 21
  nLeft   := _upr_otstup("l")
  nright  := _upr_otstup("r")
  nTop    := _upr_otstup("t")
  nBottom := _upr_otstup("b")
endif
_top := nTop
nWidth := widthList-nLeft-nright
if _p_list_2 == 0 // обычная печать
  do while !ft_eof()
    s := ft_readln()
    IF f_stroke_next_page(s)
      if --kol_list == 0 ; exit ; endif
      FrPrn:NewPage()
      _top := nTop
    ELSE
      FrPrn:MemoAt(fr_OemToAnsi(s),nLeft,_top,nWidth,nlpi)
      _top += nlpi
    ENDIF
    ft_skip()
  enddo
else  // "разрезание" листа на части при печати
  fl_exit := .f.
  t_list := retShCut(@sh1,@sh2,@sh3,@sh4,@sh5)
  do while !ft_eof()
    rec := ft_RecNo()
    for _i := 1 to t_list
      if _i > 1
        ft_GoTo(rec)
        _top := nTop
      endif
      do while .t.
        s := ft_readln()
        IF f_stroke_next_page(s) .or. ft_eof()
          if _i == t_list
            if --kol_list == 0
              fl_exit := .t.
              exit
            endif
          endif
          if iif(_i==t_list, !ft_eof(), .t.)
            FrPrn:NewPage()
            _top := nTop
            ft_skip()
          endif
          EXIT
        ELSE
          s1 := retS1Cut(_i,s,sh1,sh2,sh3,sh4,sh5)
          FrPrn:MemoAt(fr_OemToAnsi(s1),nLeft,_top,nWidth,nlpi)
          _top += nlpi
        ENDIF
        ft_skip()
      enddo
      if fl_exit ; exit ; endif
    next
    if fl_exit ; exit ; endif
  enddo
endif
RETURN

***** конвертирует DOS-строку в WINDOWS-строку специально для FR
Function fr_OemToAnsi(dos_str)
Local len_str, i, cur_char, win_str := ""
len_str := len(dos_str)
for i := 1 to len_str
  cur_asc := ASC(substr(dos_str,i,1))
  do case
    case between(cur_asc,128,175)     // А-п
      cur_asc := cur_asc + 64
    case between(cur_asc,176,223)
      if between(cur_asc,176,182)     // ░▒▓│┤╡╢
        cur_asc := 124               // |
      elseif between(cur_asc,183,184) // ╖╕
        cur_asc := 43                // +
      elseif between(cur_asc,185,186) // ╣║
        cur_asc := 124               // |
      elseif between(cur_asc,187,194) // ╗╝╜╛┐└┴┬
        cur_asc := 43                // +
      elseif cur_asc == 195           // ├
        cur_asc := 124               // |
      elseif cur_asc == 196           // ─
        cur_asc := 150               // -
      elseif cur_asc == 197           // ┼
        cur_asc := 43                // +
      elseif between(cur_asc,198,199) // ╞╟
        cur_asc := 124               // |
      elseif between(cur_asc,200,203) // ╚╔╩╦
        cur_asc := 43                // +
      elseif cur_asc == 204           // ╠
        cur_asc := 124               // |
      elseif cur_asc == 205           // ═
        cur_asc := 150               // -
      elseif between(cur_asc,206,218) // ╬╧╨╤╥╙╘╒╓╫╪┘┌
        cur_asc := 43                // +
      elseif cur_asc == 219           // █
        cur_asc := 124               // |
      elseif cur_asc == 220           // ▄
        cur_asc := 95                // _
      elseif between(cur_asc,221,222) // ▌▐
        cur_asc := 124               // |
      elseif cur_asc == 223           // ▀
        cur_asc := 126               // ~
      endif
    case between(cur_asc,224,239)     // р-я
      cur_asc := cur_asc + 16
    case cur_asc == 91  // [
      cur_asc := 40    // (
    case cur_asc == 93  // ]
      cur_asc := 41    // )
    case cur_asc == 240 // Ё
      cur_asc := 168
    case cur_asc == 241 // ё
      cur_asc := 184
    case cur_asc == 252 // №
      cur_asc := 185
    case cur_asc == 255 //
      cur_asc := 32
  end case
  win_str += CHR(cur_asc)
next
return (win_str)

*

***** удалить файлы данных для отчетов FR ("_data.dbf" и "_titl.dbf")
Function delFRfiles()
Local j, nfile
delete file (fr_titl+sdbf)
delete file (fr_data+sdbf)
delete file (fr_data+sntx)
for j := 1 to max_FR_date_dbf
  nfile := fr_data+ltrim(str(j))
  delete file (nfile+sdbf)
  delete file (nfile+sntx)
next
return NIL

***** запустить генератор отчетов
Function call_fr(cFile_Otchet,ltip,cFile_Export,bMasterDetail,is_open)
Static sExt := ".fr3"
Local i, j, nfile, buf := savescreen(), tmp_select := select(), fl, is_ot := .t.
DEFAULT ltip TO 1, cFile_Export TO "", bMasterDetail TO {|| .t. }, is_open TO .t.
//
stat_msg("Ждите! Запуск генератора отчетов FastReport.")
// Now load and init FastReport
PRIVATE FrPrn := frReportManager():new(,.t.),; // .t. ошибки выводятся в OEM кодировке
        lShowCustName := .t.
FrPrn:SetIcon("MAIN_ICON")        
if file(fr_data+sdbf)
  USE (fr_data) NEW
  if file(fr_data+sntx)
    set index to (fr_data)
  endif
  GO TOP
  FrPrn:SetWorkArea(fr_data,select(),.t.) // .t. dbf-файл в OEM кодировке
endif
if file(fr_titl+sdbf)
  USE (fr_titl) NEW
  GO TOP
  FrPrn:SetWorkArea(fr_titl,select(),.t.) // .t. dbf-файл в OEM кодировке
endif
for j := 1 to max_FR_date_dbf
  nfile := fr_data+ltrim(str(j))
  if file(nfile+sdbf)
    USE (nfile) NEW
    if file(nfile+sntx)
      set index to (nfile)
    endif
    GO TOP
    FrPrn:SetWorkArea(nfile,select(),.t.) // .t. dbf-файл в OEM кодировке
  endif
next
eval(bMasterDetail)
if valtype(cFile_Otchet) == "C"
  if !(sExt $ lower(cFile_Otchet))
    cFile_Otchet += sExt
  endif
  if hb_FileExists(dir_exe+cFile_Otchet)
    FrPrn:LoadFromFile(dir_exe+cFile_Otchet)
  else
    is_ot := func_error(4,"Не обнаружен файл отчёта "+dir_exe+cFile_Otchet)
  endif
else
  fl := .t.
  for i := 1 to len(cFile_Otchet)
    if !(sExt $ lower(cFile_Otchet[i]))
      cFile_Otchet[i] += sExt
    endif
    if hb_FileExists(dir_exe+cFile_Otchet[i])
      FrPrn:LoadFromFile(dir_exe+cFile_Otchet[i])
      FrPrn:PrepareReport(iif(fl,nil,FR_NOTCLEARLASTREPORT))
      fl := .f.
    else
      func_error(4,"Не обнаружен файл отчёта "+dir_exe+cFile_Otchet[i])
    endif
  next
  if fl
    is_ot := .f.
  endif
endif
do case
  case ltip == 1 .and. is_ot
    if valtype(cFile_Otchet) == "C"
      FrPrn:ShowReport()
    else
      FrPrn:ShowPreparedReport()
    endif
  case ltip == 2
    //FrPrn:DesignReport()
  case ltip == 3 .and. is_ot
    PRIVATE cExpObj := "XLSExport", cExpFile, cExtention := ".xls"
    if cFile_Export == NIL
      cExpFile := StripPath(cFile_Otchet)
    else
      cExpFile := cFile_Export
    endif
    if (j := at(".",cExpFile)) > 0
      cExpFile := left(cExpFile,j-1)
    endif
    cExpFile += cExtention
    FrPrn:PrepareReport()
    // не запрашивать окно диалога
    FrPrn:SetProperty(cExpObj, "ShowDialog", .f.)
    // открыть Excel и загрузить в него отчет
    FrPrn:SetProperty(cExpObj, "OpenExcelAfterExport", is_open)
    // имя таблицы Excel, записываемой в текущий каталог
    FrPrn:SetProperty(cExpObj, "FileName", cExpFile)
    // запрет вывода заголовков страниц, начиная со 2-ой
    FrPrn:SetProperty(cExpObj, "SuppressPageHeadersFooters", .t.)
    // не выводить пустые строки
    FrPrn:SetProperty(cExpObj, "EmptyLines", .f.)
    // не делать перевод страниц
    FrPrn:SetProperty(cExpObj, "PageBreaks", .f.)
    FrPrn:DoExport(cExpObj)
endcase
FrPrn:ClearDataSets()
lShowCustName := .f.
// Unload FastReport
FrPrn:DestroyFR()
//
if file(fr_data+sdbf)
  &fr_data.->(dbCloseArea())
endif
if file(fr_titl+sdbf)
  &fr_titl.->(dbCloseArea())
endif
for j := 1 to max_FR_date_dbf
  nfile := fr_data+ltrim(str(j))
  if file(nfile+sdbf)
    &nfile.->(dbCloseArea())
  endif
next
select (tmp_select)
restscreen(buf)
keyboard ""
return NIL

***** 10.09.13
Static Function f_stroke_next_page(s)
return left(s,1)=="" .or. left(s,2)=="FF"
