// ��⠭���� ⨯� �ਭ�� � (�᫨ ����室���) ����� �ਭ��
#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'

Static current_tip
Static a_pr_default
Static a_pr_nastr
Static _name := 'printer'
Static _ust_out := 'ust_pr_out'
Static _tmpfile := 'tmpprint'
// ᯨ᮪ ०���� ("tip") � ini-䠩��
Static reg_EP := 'EP'
Static reg_HP := 'HP'
Static reg_WI := 'WI'
// ᯨ᮪ ��६������ � ini-䠩��
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
// �������騥�� ��ப�
Static s_nepr     := '�ਧ��� �����뢭��� ����'
Static s_10cpi    := '10 cpi - ��ଠ��� ०�� ���� (Pica)'
Static s_12cpi    := '12 cpi - ०�� ���� Elita'
Static s_17cpi    := '17 cpi - 㯫�⭥��� ०�� ���� (Condensed)'
Static s_6lpi     := '6 lpi  - ���� ��ப �� �  (60 ��ப/����)'
Static s_8lpi     := '8 lpi  - ��ᥬ� ��ப �� � (80 ��ப/����)'
Static s_ini      := '��� ���樠����樨 �ਭ��'
Static s_port     := '���� �ਭ��'
Static s_w_edit   := '�뢮���� �ࠧ� � FastReport ��� �⮡ࠦ���� � ���� �।��ᬮ��'
Static s_lotstup  := '����� ᫥��  (� �)'
Static s_rotstup  := '����� �ࠢ� (� �)'
Static s_totstup  := '����� ᢥ��� (� �)'
Static s_botstup  := '����� ᭨��  (� �)'
Static s_DOSedit  := '��ப� ����᪠ DOS-।���� �� <F4>'
Static s_WINedit  := '� ����� Windows-।���� ���㦠�� 䠩� �� <F10>'

//
Function ust_printer(r)
  Local buf := savescreen(), tmp_help
  Local i, j, k, k2, l := 0, r1, r2, c1, c2, t_tmp := 3, t2_tmp := 1, ar

  Private menu_print := {{'����� �� ������ �ਭ�� �१ LPT-����', reg_EP}, ;
                        {'����� �� ������ �ਭ�� �१ LPT-����', reg_HP}, ;
                        {'����� �� Windows-�ਭ�� �१ FastReport', reg_WI}}
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
  status_key('^<Esc>^ - ��室;  ^<Enter>^ - ᬥ�� ⨯� �ਭ�� � ।���஢���� �ࠢ����� �����')
  if (ar := my_achoice(r1 + 1, c1 + 1, r2 - 1, c2 - 1, ar, t_tmp, 1, color0, , _ust_out)) != NIL
    k := ar[1]
    ust_pr_1(menu_print[k])
  endif
  restscreen(buf)
  chm_help_code := help_code := tmp_help
  return NIL

// ।���஢���� ����஥�
Function ust_pr_1(a1)
  Static _blank := ' '
  Static menu_nepr := {{'����� � ���⢥ত����� ������� ����', 1}, ;
                       {'�����뢭�� �����', 2}}
  Static menu_lpt  := {{'LPT 1 (PRN)', 1}, ;
                       {'LPT 2', 2}}
  Static mm_per_FF := {{'ᨬ��� ��ॢ��� �ଠ� (FF)', 1}, ;
                       {'����� ���뢠', 2}}
  Static mm_winedit := {{'WordPad', 0}, {'WinWord', 1}, {'OpenOffice', 2}}
  Static mm_danet := {{'���', 0}, {'��', 1}}
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
                    'Draft  - ���筮� ����⢮ ����'})
      aadd(mm_tmp, {_EP_nlq, 'C', 30, 0, NIL, NIL,_blank, NIL, ;
                    'NLQ    - ����� ��᮪�����⢥��� ���⮬'})
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
                    '�� �뢮���� ��᫥ ���� ��।���� ����'})
    case a1[2] == reg_HP
      aadd(mm_tmp, {_nepr, 'N', 1, 0, NIL, ;
                    {|x|menu_reader(x,menu_nepr, A__MENUVERT)}, ;
                    2, {|x|inieditspr(A__MENUVERT, menu_nepr,x)}, ;
                    s_nepr})
      aadd(mm_tmp, {_HP_Portr, 'C', 30, 0, NIL, NIL, _blank, NIL, ;
                    '���� ����祭�� �����⭮� ����'})
      aadd(mm_tmp, {_HP_Albom, 'C', 30, 0, NIL, NIL, _blank, NIL, ;
                    '���� ����祭�� ��졮���� ����'})
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
    case a1[2] == reg_WI  // ����� �� Windows-�ਭ�� �१ FastReport
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
    SetIniVar(_name, ar) // ar - ���ᨢ �� "�஥�": {cSect, cKey, cValue}
    ust_ar_default(.t.)
  endif
  close databases
  return NIL

//
Static Function ust_pole(s_pole, u_default)
  Local i, j
  // �᫨ ���� ���� � TMP-䠩��
  if (i := fieldnum(s_pole)) > 0
    // �᫨ ���� ���� � INI-䠩��
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
      ar := {'��ᯥ�⪠ ���⮢ �� ����筮�', ;
             '�ਭ��, ᮢ���⨬�� � EPSON', ;
             '������祭��� � ���������', ;
             '�१ ���� LPT1 (PRN) ��� LPT2'}
    case a1[2] == reg_HP
      ar := {'��ᯥ�⪠ ���⮢ �� ����୮� �ਭ��,', ;
             'ᮢ���⨬�� � HP, � ���஥��묨', ;
             '(����㦠��묨) ���⠬�, ������祭���', ;
             '�१ LPT ���� (�������� ����㠫��)'}
    case a1[2] == reg_WI
      ar := {'��ᯥ�⪠ ���⮢ �� �ਭ��,', ;
             '��⠭�������� ��-㬮�砭�� �', ;
             '����樮���� ��⥬� Windows,', ;
             '�१ ������� ���⮢ FastReport'}
  endcase
  do while len(ar) < 5
    aadd(ar, '')
  enddo
  return ar

// �⥭�� ini-䠩��
Function ust_pr_ini()
  Local ar := {}, i, j

  ar := GetIniSect(_name,_name)
  // ���४��㥬 ⨯ �������� ��६�����
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

// �� ��६���� �� 㬮�砭��, �⠥� �� �⥭�� ini-䠩��
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
    aadd(ar, {_HP_Portr, '27 38 108 48 79'})  // ������� �������� ����� ESC+"&l0O"
    aadd(ar, {_HP_Albom, '27 38 108 49 79'})  // ������� ��졮���� ����� ESC+"&l1O"
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

// ������ ���祭�� ��६����� �� �����
Function __UV__(s)
  Local v := '', i

  ust_ar_default(.f.)
  if (i := ascan(a_pr_nastr, {|x| upper(x[1]) == upper(s) })) > 0
    v := a_pr_nastr[i, 2]
  elseif (i := ascan(a_pr_default, {|x| upper(x[1]) == upper(s) })) > 0
    v := a_pr_default[i, 2]
  endif
  return v

// ������ ⨯ ����ன�� �ਭ��
Function _upr_tip()

  DEFAULT current_tip TO __UV__(_tip)
  return current_tip

// ������ ����� ����
Function _upr_port()
  return __UV__(_port)

// ������ �ਧ��� �����뢭��� ����
Function _upr_nepr()
  return __UV__(_nepr)

// ������ �����
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

// ������ ��� ���樠����樨
Function _upr_init()
  return iif(_upr_tip() == reg_EP, __UV__(_EP_ini), __UV__(_HP_ini))

// ������� ������� �ਥ����
Function _upr_Portr()
  return __UV__(_HP_Portr)

// ������� ��졮���� �ਥ����
Function _upr_Albom()
  return __UV__(_HP_Albom)

// ������� ������室��� �����
Function _upr_draft()
  return __UV__(_EP_draft)

// ������� �����室��� �����
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

// ����� �� �ਭ�� Epson
Function _upr_epson()
  return (_upr_tip() == reg_EP)

// ����� �� �ਭ�� HP
Function _upr_HP()
  return (_upr_tip() == reg_HP)

// ����� �१ Windows
Function _upr_windows()
  return (_upr_tip() == reg_WI)

// �뢮���� �� �ࠧ� � Windows-।���� ��� �⮡ࠦ���� � DOS-�
Function _upr_w_edit()
  return _upr_windows() .and. __UV__(_w_edit) == 1

//
Function _upr_isalbom()
  // ��� ⮣�, �⮡� �뫠 ����������� ��졮���� ���� �����⭮�� ���㬥��,
  // � ��뢠�饩 �ணࠬ�� ��। �맮��� ᮮ⢥�����饩 �㭪樨 viewtext
  // ����室��� �����:      Private yes_albom := .t.
  Local is_albom := (type('yes_albom') == 'L' .and. yes_albom)

  return is_albom .and. _upr_tip() != reg_EP // �ਭ�� �� Epson

// ������ EJECT ��� ���� �஬��뢠�� �㬠��
Function _upr_yes_FF(yes_FF)

  if _upr_tip() == reg_EP // �ਭ�� Epson
    if yes_FF == NIL
      yes_FF := (__UV__(_EP_ff) == 1)
    elseif valtype(yes_FF) == 'C'
      yes_FF := (yes_FF == 'T')
    endif
  else
    yes_FF := .t.
  endif
  if !(valtype(yes_FF) == 'L')  // �� ��直� ��砩
    yes_FF := .t.
  endif
  return yes_FF

// ������ ���� � DOS-।�����
Function _upr_DOSedit()
  Local cPath := __UV__(_DOSedit)

  if !empty(cPath) .and. !hb_FileExists(cPath)
    func_error(4, '�� �����㦥� DOS-।����: ' + cPath)
    cPath := ''
  endif
  return cPath

// ������ ⨯ WIN-।����
Function _upr_WINedit()
  return __UV__(_WINedit)

//
Static Function ust_ar_default(fl)

  DEFAULT fl TO .f., a_pr_default TO ust_pr_default()
  if fl .or. a_pr_nastr == NIL
    a_pr_nastr := ust_pr_ini()
  endif
  return NIL
