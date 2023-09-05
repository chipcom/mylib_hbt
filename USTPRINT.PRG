// Установка типа принтера и (если необходимо) кодов принтера
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'

Static current_tip
Static a_pr_default
Static a_pr_nastr
Static _name := 'printer'
Static _ust_out := 'ust_pr_out'
Static _tmpfile := 'tmpprint'
// список режимов ("tip") в ini-файле
Static reg_EP := 'EP'
Static reg_HP := 'HP'
Static reg_WI := 'WI'
// список переменнных в ini-файле
Static _tip      := 'tip'
Static _nepr     := 'nepr'
Static _EP_10cpi := 'EP_10cpi'
Static _EP_12cpi := 'EP_12cpi'
Static _EP_17cpi := 'EP_17cpi'
Static _EP_6lpi  := 'EP_6lpi'
Static _EP_8lpi  := 'EP_8lpi'
Static _EP_draft := 'EP_draft'
Static _EP_nlq   := 'EP_nlq'
Static _EP_ini   := 'EP_ini'
Static _EP_ff    := 'EP_ff'
Static _lotstup  := 'lotstup'
Static _rotstup  := 'rotstup'
Static _totstup  := 'totstup'
Static _botstup  := 'botstup'
Static _port     := 'port'
Static _HP_Portr := 'HP_Portr'
Static _HP_Albom := 'HP_Albom'
Static _HP_10cpi := 'HP_10cpi'
Static _HP_12cpi := 'HP_12cpi'
Static _HP_17cpi := 'HP_17cpi'
Static _HP_6lpi  := 'HP_6lpi'
Static _HP_8lpi  := 'HP_8lpi'
Static _HP_ini   := 'HP_ini'
Static _w_edit   := 'w_edit'
Static _DOSedit  := 'DOSedit'
Static _WINedit  := 'WINedit'
// повторяющиеся строки
Static s_nepr     := 'Признак непрерывности печати'
Static s_10cpi    := '10 cpi - нормальный режим печати (Pica)'
Static s_12cpi    := '12 cpi - режим печати Elita'
Static s_17cpi    := '17 cpi - уплотненный режим печати (Condensed)'
Static s_6lpi     := '6 lpi  - шесть строк на дюйм  (60 строк/лист)'
Static s_8lpi     := '8 lpi  - восемь строк на дюйм (80 строк/лист)'
Static s_ini      := 'Код инициализации принтера'
Static s_port     := 'Порт принтера'
Static s_w_edit   := 'Выводить сразу в FastReport без отображения в окне предпросмотра'
Static s_lotstup  := 'Отступ слева  (в см)'
Static s_rotstup  := 'Отступ справа (в см)'
Static s_totstup  := 'Отступ сверху (в см)'
Static s_botstup  := 'Отступ снизу  (в см)'
Static s_DOSedit  := 'Строка запуска DOS-редактора по <F4>'
Static s_WINedit  := 'В какой Windows-редактор выгружать файл по <F10>'

//
Function ust_printer(r)
  Local buf := savescreen(), tmp_help
  Local i, j, k, k2, l := 0, r1, r2, c1, c2, t_tmp := 3, t2_tmp := 1, ar

  Private menu_print := {{'Печать на матричный принтер через LPT-порт', reg_EP}, ;
                        {'Печать на лазерный принтер через LPT-порт', reg_HP}, ;
                        {'Печать на Windows-принтер через FastReport', reg_WI}}
  tmp_help := if(type('chm_help_code') == 'N', chm_help_code, help_code)
  chm_help_code := 9
  ust_ar_default(.t.)
  if (j := ascan(a_pr_nastr, {|x| upper(x[1]) == upper(_tip)} )) > 0 .and. ;
       (j := ascan(menu_print, {|x| x[2] == upper(a_pr_nastr[j, 2])} )) > 0
    t_tmp := j
  endif
  ar := {}
  for i := 1 to len(menu_print)
    aadd(ar, if( i == t_tmp, '  ', '   ') + menu_print[i, 1])
    l := max(l, len(ar[i]))
  next
  r1 := r
  r2 := r1 + len(menu_print) + 1
  c2 := 75
  c1 := c2 - l - 2
  box_shadow(16, 2, 22, 43, 'G+/RB')
  box_shadow(r1, c1, r2, c2, color0)
  status_key('^<Esc>^ - выход;  ^<Enter>^ - смена типа принтера и редактирование управляющих кодов')
  if (ar := my_achoice(r1 + 1, c1 + 1, r2 - 1, c2 - 1, ar, t_tmp, 1, color0, , _ust_out)) != NIL
    k := ar[1]
    ust_pr_1(menu_print[k])
  endif
  restscreen(buf)
  chm_help_code := help_code := tmp_help
  return NIL

// редактирование настроек
Function ust_pr_1(a1)
  Static _blank := ' '
  Static menu_nepr := {{'Печать с подтверждением каждого листа', 1}, ;
                       {'Непрерывная печать', 2}}
  Static menu_lpt  := {{'LPT 1 (PRN)', 1}, ;
                       {'LPT 2', 2}}
  Static mm_per_FF := {{'символ перевода формата (FF)', 1}, ;
                       {'линия отрыва', 2}}
  Static mm_winedit := {{'WordPad', 0}, {'WinWord', 1}, {'OpenOffice', 2}}
  Static mm_danet := {{'нет', 0}, {'да', 1}}
  Local mm_tmp := {}, s_cmd, ar := {}, i, v
  Local blk1 := {|| iif(m1to_print == 1,(m1w_edit := 0, mw_edit := mm_danet[1, 1]), ), ;
                  update_gets() }
  Local blk2 := {|| m1to_print == 0 }

  do case
    case a1[2] == reg_EP
      aadd(mm_tmp, {_nepr, 'N', 1, 0, NIL, ;
                    {|x|menu_reader(x,menu_nepr, A__MENUVERT)}, ;
                    1, {|x|inieditspr(A__MENUVERT, menu_nepr, x)}, ;
                    s_nepr})
      aadd(mm_tmp, {_EP_10cpi, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_10cpi})
      aadd(mm_tmp, {_EP_12cpi, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_12cpi})
      aadd(mm_tmp, {_EP_17cpi, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_17cpi})
      aadd(mm_tmp, {_EP_6lpi, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_6lpi})
      aadd(mm_tmp, {_EP_8lpi, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_8lpi})
      aadd(mm_tmp, {_EP_draft, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    'Draft  - обычное качество шрифта'})
      aadd(mm_tmp, {_EP_nlq, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    'NLQ    - печать высококачественным шрифтом'})
      aadd(mm_tmp, {_EP_ini, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_ini})
      aadd(mm_tmp, {_lotstup, 'N', 3, 1, NIL, NIL, 1, NIL, ;
                    s_lotstup})
      aadd(mm_tmp, {_port, 'N', 1, 0, NIL, ;
                    {|x|menu_reader(x,menu_lpt, A__MENUVERT)}, ;
                    1, {|x|inieditspr(A__MENUVERT, menu_lpt, x)}, ;
                    s_port})
      aadd(mm_tmp, {_EP_ff, 'N', 1, 0, NIL, ;
                    {|x|menu_reader(x,mm_per_ff, A__MENUVERT)}, ;
                    1, {|x|inieditspr(A__MENUVERT, mm_per_ff, x)}, ;
                    'Что выводить после печати очередного листа'})
    case a1[2] == reg_HP
      aadd(mm_tmp, {_nepr, 'N', 1, 0, NIL, ;
                    {|x|menu_reader(x,menu_nepr, A__MENUVERT)}, ;
                    2, {|x|inieditspr(A__MENUVERT, menu_nepr,x)}, ;
                    s_nepr})
      aadd(mm_tmp, {_HP_Portr, 'C', 30, 0, NIL, NIL, _blank, NIL, ;
                    'Коды включения портретной печати'})
      aadd(mm_tmp, {_HP_Albom, 'C', 30, 0, NIL, NIL, _blank, NIL, ;
                    'Коды включения альбомной печати'})
      aadd(mm_tmp, {_HP_10cpi, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_10cpi})
      aadd(mm_tmp, {_HP_12cpi, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_12cpi})
      aadd(mm_tmp, {_HP_17cpi, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_17cpi})
      aadd(mm_tmp, {_HP_6lpi, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_6lpi})
      aadd(mm_tmp, {_HP_8lpi, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_8lpi})
      aadd(mm_tmp, {_HP_ini, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    s_ini})
      aadd(mm_tmp, {_lotstup, 'N', 3, 1, NIL, NIL, 1, NIL, ;
                    s_lotstup})
      aadd(mm_tmp, {_port, 'N', 1, 0, NIL, ;
                    {|x|menu_reader(x, menu_lpt, A__MENUVERT)}, ;
                    1, {|x|inieditspr(A__MENUVERT, menu_lpt, x)}, ;
                    s_port})
    case a1[2] == reg_WI  // Печать на Windows-принтер через FastReport
      aadd(mm_tmp, {_lotstup, 'N', 3, 1, NIL, NIL, 1, NIL, ;
                    s_lotstup})
      aadd(mm_tmp, {_rotstup, 'N', 3, 1, NIL, NIL, 1, NIL, ;
                    s_rotstup})
      aadd(mm_tmp, {_totstup, 'N', 3, 1, NIL, NIL, 1, NIL, ;
                    s_totstup})
      aadd(mm_tmp, {_botstup, 'N', 3, 1, NIL, NIL, 1, NIL, ;
                    s_botstup})
      aadd(mm_tmp, {_w_edit, 'N', 1, 0, NIL, ;
                    {|x|menu_reader(x,mm_danet, A__MENUVERT)}, ;
                    0, {|x|inieditspr(A__MENUVERT, mm_danet, x)}, ;
                    s_w_edit})
  endcase
  aadd(mm_tmp, {'e1', 'C', 1, 0, NIL, NIL, _blank, NIL, space(60), , {||.f.}})
  aadd(mm_tmp, {_DOSedit, 'C', 100, 0, NIL, ;
                {|x| menu_reader(x, {{|k, r, c| mng_file(k, r, c, '_DOSedit', ,'*.exe') }}, A__FUNCTION)}, ;
                '', {|x| x }, ;
                s_DOSedit})
  aadd(mm_tmp, {_WINedit, 'N', 1, 0, NIL, ;
                {|x|menu_reader(x, mm_winedit, A__MENUVERT)}, ;
                0, {|x|inieditspr(A__MENUVERT, mm_winedit, x)}, ;
                s_WINedit})
  delete file (_tmpfile + '.dbf')
  init_base(_tmpfile, , mm_tmp, 0)
  use (_tmpfile) new
  append blank
  for i := 1 to len(a_pr_default)
    ust_pole(a_pr_default[i, 1], a_pr_default[i, 2])
  next
  close databases
  do while len(mm_tmp[1]) < A__WHEN
    aadd(mm_tmp[1], NIL)
  enddo
  if f_edit_spr(A__EDIT, mm_tmp, '"' + a1[1] + '"', ;
                "g_use('" + _tmpfile + "', , , .t., .t.)", 0, 1, chm_help_code) > 0
    use (_tmpfile) new
    ar := array (fcount())
    for i := 1 to len(ar)
      if valtype(v := fieldget(i)) == 'N'
        v := lstr(v)
      endif
      ar[i] := {_name, fieldname(i), alltrim(v)}
    next
    close databases
    aadd(ar, {_name, _tip, a1[2]})
    SetIniVar(_name, ar) // ar - массив из "троек": {cSect, cKey, cValue}
    ust_ar_default(.t.)
  endif
  close databases
  return NIL

//
Static Function ust_pole(s_pole, u_default)
  Local i, j
  // если поле есть в TMP-файле
  if (i := fieldnum(s_pole)) > 0
    // если поле есть в INI-файле
    if (j := ascan(a_pr_nastr, {|x| upper(x[1]) == upper(s_pole)} )) > 0
      u_default := a_pr_nastr[j, 2]
    endif
    fieldput(i, u_default)
  endif
  return NIL

//
Function ust_pr_out(k)
  Local i, ar := ust_pr_2(k)

  for i := 1 to 5
    @ 16 + i, 3 say padr(ar[i], 40) color 'GR+/RB'
  next
  return NIL

//
Function ust_pr_2(k, a1)
  Local i, ar := {}

  if valtype(k) == 'N' .and. between(k, 1, len(menu_print))
    a1 := menu_print[k]
  endif
  do case
    case a1[2] == reg_EP
      ar := {'Распечатка отчетов на матричном', ;
             'принтере, совместимом с EPSON', ;
             'подключенном к компьютеру', ;
             'через порт LPT1 (PRN) или LPT2'}
    case a1[2] == reg_HP
      ar := {'Распечатка отчетов на лазерном принтере,', ;
             'совместимом с HP, со встроенными', ;
             '(загружаемыми) шрифтами, подключенном', ;
             'через LPT порт (возможно виртуальный)'}
    case a1[2] == reg_WI
      ar := {'Распечатка отчетов на принтере,', ;
             'установленном по-умолчанию в', ;
             'операционной системе Windows,', ;
             'через генератор отчетов FastReport'}
  endcase
  do while len(ar) < 5
    aadd(ar, '')
  enddo
  return ar

// чтение ini-файла
Function ust_pr_ini()
  Local ar := {}, i, j

  ar := GetIniSect(_name,_name)
  // корректируем тип некоторых переменных
  for i := 1 to len(ar)
    if (j := ascan(a_pr_default, {|x| upper(x[1]) == upper(ar[i, 1]) } )) > 0 ;
        .and. valtype(a_pr_default[j, 2]) == 'N' .and. valtype(ar[i, 2]) == 'C'
      ar[i, 2] := val(ar[i, 2])
    endif
  next
  current_tip := NIL
  return ar

//
Static Function _u2ret_ini(arr, pole, sv, uslovie)

  DEFAULT uslovie TO !empty(sv)
  if uslovie
    aadd(arr, {pole, sv})
  endif
  return NIL

// все переменные по умолчанию, читаем до чтения ini-файла
Function ust_pr_default()
  Static ar

  if ar == NIL
    ar := {}
    aadd(ar, {_tip     , reg_WI})
    aadd(ar, {_nepr    , 2})
    aadd(ar, {_EP_10cpi, '18 27 80'})
    aadd(ar, {_EP_12cpi, '18 27 77'})
    aadd(ar, {_EP_17cpi, '27 15'})
    aadd(ar, {_EP_6lpi , '27 50'})
    aadd(ar, {_EP_8lpi , '27 48'})
    aadd(ar, {_EP_draft, '27 120 0'})
    aadd(ar, {_EP_nlq  , '27 120 1'})
    aadd(ar, {_EP_ini  , '27 64 18'})
    aadd(ar, {_EP_ff   , 1})
    aadd(ar, {_lotstup , 1})
    aadd(ar, {_rotstup , 1})
    aadd(ar, {_totstup , 1})
    aadd(ar, {_botstup , 1})
    aadd(ar, {_port    , 1})
    aadd(ar, {_HP_Portr, '27 38 108 48 79'})  // включить портретную печать ESC+"&l0O"
    aadd(ar, {_HP_Albom, '27 38 108 49 79'})  // включить альбомную печать ESC+"&l1O"
    aadd(ar, {_HP_10cpi, '27 38 107 48 83'})
    aadd(ar, {_HP_12cpi, '27 38 107 52 83'})
    aadd(ar, {_HP_17cpi, '27 38 107 50 83'})
    aadd(ar, {_HP_6lpi , '27 38 108 54 68'})
    aadd(ar, {_HP_8lpi , '27 38 108 56 68'})
    aadd(ar, {_HP_ini  , '27 69'})
    aadd(ar, {_w_edit  , 0})
    aadd(ar, {_DOSedit , ''})
    aadd(ar, {_WINedit , 0})
  endif
  return ar

// Вернуть значение переменной по имени
Function __UV__(s)
  Local v := '', i

  ust_ar_default(.f.)
  if (i := ascan(a_pr_nastr, {|x| upper(x[1]) == upper(s) })) > 0
    v := a_pr_nastr[i, 2]
  elseif (i := ascan(a_pr_default, {|x| upper(x[1]) == upper(s) })) > 0
    v := a_pr_default[i, 2]
  endif
  return v

// вернуть тип настройки принтера
Function _upr_tip()

  DEFAULT current_tip TO __UV__(_tip)
  return current_tip

// вернуть номер порта
Function _upr_port()
  return __UV__(_port)

// вернуть признак непрерывности печати
Function _upr_nepr()
  return __UV__(_nepr)

// вернуть отступ
Function _upr_otstup(k)
  Local _o

  DEFAULT k TO 'L'
  k := lower(k)
  do case
    case k == 'L'
      _o := _lotstup
    case k == 'r'
      _o := _rotstup
    case k == 't'
      _o := _totstup
    case k == 'b'
      _o := _botstup
  endcase
  return __UV__(_o)

// вернуть код инициализации
Function _upr_init()
  return iif(_upr_tip() == reg_EP, __UV__(_EP_ini), __UV__(_HP_ini))

// включить книжную ориентацию
Function _upr_Portr()
  return __UV__(_HP_Portr)

// включить альбомную ориентацию
Function _upr_Albom()
  return __UV__(_HP_Albom)

// включить однопроходную печать
Function _upr_draft()
  return __UV__(_EP_draft)

// включить двухпроходную печать
Function _upr_nlq()
  return __UV__(_EP_nlq)

//
Function _upr_10cpi()
  return iif(_upr_tip() == reg_EP, __UV__(_EP_10cpi), __UV__(_HP_10cpi))

//
Function _upr_12cpi()
  return iif(_upr_tip() == reg_EP, __UV__(_EP_12cpi), __UV__(_HP_12cpi))

//
Function _upr_17cpi()
  return iif(_upr_tip() == reg_EP, __UV__(_EP_17cpi), __UV__(_HP_17cpi))

//
Function _upr_6lpi()
  return iif(_upr_tip() == reg_EP, __UV__(_EP_6lpi), __UV__(_HP_6lpi))

//
Function _upr_8lpi()
  return iif(_upr_tip() == reg_EP, __UV__(_EP_8lpi), __UV__(_HP_8lpi))

// печать на принтер Epson
Function _upr_epson()
  return (_upr_tip() == reg_EP)

// печать на принтер HP
Function _upr_HP()
  return (_upr_tip() == reg_HP)

// печать через Windows
Function _upr_windows()
  return (_upr_tip() == reg_WI)

// Выводить ли сразу в Windows-редактор без отображения в DOS-е
Function _upr_w_edit()
  return _upr_windows() .and. __UV__(_w_edit) == 1

//
Function _upr_isalbom()
  // Для того, чтобы была возможность альбомной печати конкретного документа,
  // в вызывающей программе перед вызовом соответствующей функции viewtext
  // необходимо объявить:      Private yes_albom := .t.
  Local is_albom := (type('yes_albom') == 'L' .and. yes_albom)

  return is_albom .and. _upr_tip() != reg_EP // принтер не Epson

// делать EJECT или просто проматывать бумагу
Function _upr_yes_FF(yes_FF)

  if _upr_tip() == reg_EP // принтер Epson
    if yes_FF == NIL
      yes_FF := (__UV__(_EP_ff) == 1)
    elseif valtype(yes_FF) == 'C'
      yes_FF := (yes_FF == 'T')
    endif
  else
    yes_FF := .t.
  endif
  if !(valtype(yes_FF) == 'L')  // на всякий случай
    yes_FF := .t.
  endif
  return yes_FF

// вернуть путь к DOS-редактору
Function _upr_DOSedit()
  Local cPath := __UV__(_DOSedit)

  if !empty(cPath) .and. !hb_FileExists(cPath)
    func_error(4, 'Не обнаружен DOS-редактор: ' + cPath)
    cPath := ''
  endif
  return cPath

// вернуть тип WIN-редактора
Function _upr_WINedit()
  return __UV__(_WINedit)

//
Static Function ust_ar_default(fl)

  DEFAULT fl TO .f., a_pr_default TO ust_pr_default()
  if fl .or. a_pr_nastr == NIL
    a_pr_nastr := ust_pr_ini()
  endif
  return NIL
