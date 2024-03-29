#include 'inkey.ch'
#include 'function.ch'

external pr_view

// ��ᬮ�� ⥪�⮢��� 䠩�� ��ꥪ⮬ TBROWSE (� ������������ ����)
FUNCTION ViewText(mfile, title, mf_print, plus_msg, fl_right,;
                  mcolor, t_help, mregim, pr_func, name_file,;
                  yes_clear, yes_FF, yes_edit, count_copy,;
                  nTop, nLeft, nBottom, nRight)
  // mfile    - ������������ ⥪�⮢��� 䠩��
  // title    - ��ப� ���������
  // mf_print - ��� �㭪樨 ���짮��⥫� (�� 㬮�砭�� pr_view)
  // plus_msg - ���祪 ��ப�, ������塞� � ᮮ�饭��
  // fl_right - 䫠�, ࠧ���騩 ᤢ�� ⥪�� ��ࠢ� � �����
  // mcolor   - 梥�
  // t_help   - ��� �����
  // mregim   - ०�� ���� (1 - Pica, 2 - Elite, 3 - Condensed,
  //            4 - Pica 8 lpi, 5 - Elite 8 lpi, 6 - Condensed 8 lpi)
  // pr_func  - �㭪�� ��� ��⠭���� ����� �ਭ�� � ����� ��ࠬ��஬:
  //            =1 - ��� ��⠭���� �����, =2 - ��� ���� �����
  //            (�� �㭪�� ��������� ��� ⮣� ����, �᫨ ��� ��
  //            �����筮 �⠭������ ०���� mregim)
  // name_file- ��� 䠩�� ��� �뢮�� ���㬥�� (����� �뢮�� �� �ਭ��)
  // yes_clear- ����� �� ���� ���������� ��। �室�� � �㭪��
  //            (�� 㬮�砭�� .t. - ��)
  // yes_FF   - ��⠢���� ᨬ��� ��ॢ��� �ଠ� ��� ����� ���뢠
  // yes_edit - ࠧ���� ������� ।���� (�� 㬮�砭�� .t. - ��)
  // count_copy - ᪮�쪮 ����� (�� 㬮�砭�� 0 - ��᪮��筮���)
  LOCAL oBrowse, oColumn, lCont, lEdit, cStatus, j := 1, j1 := 0, ;
      i, buf, buf1, tmp_color := setcolor(), ;
      fl_plus := (plus_msg == NIL), lwidth, arr_keys := {}, ;
      s_msg := ' <Esc> - ��室;    <Home> <End> <PgUp> <PgDn>', ;
      fl_mouse, x_mouse := 0, y_mouse := 0, km, raz := 0, ;
      tmp_help, tmp_nhelp, t_nhelp, s
  
  Private nKey := 256, _p_list_2 := 0, _p_list_3 := 0, ;
          _p_list_4 := 0, _p_list_5 := 0, _p_list_6 := 0
  if !file(mfile)
    return NIL
  endif
  if t_help == NIL
    t_nhelp := 'Printer'
  elseif valtype(t_help) == 'C'
    t_nhelp := t_help
  endif
  DEFAULT title TO '', fl_right TO .f., mf_print TO 'pr_view', ;
        mcolor TO cDataCScr, t_help TO 6, mregim TO 1, pr_func TO '', ;
        name_file TO '', yes_clear TO .t., ;
        yes_edit TO .t., count_copy TO 0, ;
        nTop TO 0, nLeft TO 0, nBottom TO maxrow() - 1, nRight TO maxcol()
  if yes_clear
    keyboard ''
  endif
  Private name_view_file := upper(mfile)
  if _upr_w_edit() // �뢮���� �ࠧ� � Windows-।���� ��� �⮡ࠦ���� � DOS-�
    FT_USE(mfile)
    prn_Window(mregim)
    FT_USE()
    return NIL
  endif
  tmp_help := if(type('chm_help_code') == 'N', chm_help_code, help_code)
  chm_help_code := help_code := t_help
  // ��� ����� HELP-��⥬�
  tmp_nhelp := ret_nhelp_code()
  nhelp_code := t_nhelp
  save screen to buf
  SETCURSOR(0)
  setcolor(mcolor)
  s_msg += if(fl_right, '  ', '') + ' - ��ᬮ��'
  DEFAULT plus_msg TO padl('<F1> - ������ ', 77 - len(s_msg))
  s_msg += if(!empty(plus_msg), ';  ', '') + plus_msg
  s_msg := padr(s_msg, 80)
  stat_msg(s_msg, .f.)
  mark_keys({'<Esc>', '  <Home> <End> <PgUp> <PgDn>', ' ', '<F1>'})
  if !(nTop == 0 .and. nLeft == 0)
    box_shadow(nTop - 1, nLeft - 1, nBottom + 1, nRight + 1)
  endif
  lwidth := nRight + 1 - nLeft
  oBrowse := TBrowseNew(nTop, nLeft, nBottom, nRight)
  IF !EMPTY(title)
    title := center(title, lwidth)
  ENDIF
  oColumn := TBColumnNew(title, {|| str_v_text(j)})
  oColumn:width := lwidth
  oBrowse:addColumn(oColumn)
  // ��࠭�� ������ �ࠢ�����
  aadd(arr_keys, {K_F2, nil} )
  aadd(arr_keys, {K_F3, nil} )
  aadd(arr_keys, {K_F4, nil} )
  aadd(arr_keys, {K_F7, nil} )
  aadd(arr_keys, {K_F8, nil} )
  aadd(arr_keys, {K_F9, nil} )
  aadd(arr_keys, {K_F10, nil} )
  aadd(arr_keys, {K_CTRL_F4, nil} )
  for i := 1 to len(arr_keys)
    arr_keys[i, 2] := setkey(arr_keys[i, 1], NIL)
  next
  //
  IF !EMPTY(title)
    oBrowse:headSep := '���'
    nTop := 2
  ENDIF
  //
  oBrowse:colorSpec := mcolor
  oBrowse:goTopBlock := {|| ft_gotop() }
  oBrowse:goBottomBlock := {|| ft_gobottom() }
  oBrowse:skipBlock := { |nSkip, nVar|  nVar := ft_recno(), ft_skip(nSkip), ;
                                                          ft_recno() - nVar }
  do while .t.
    lCont := .T. ; lEdit := .F.
    fl_mouse := SETPOSMOUSE()
    FT_USE(mfile)
    if ++j1 == 1 .and. type('recno_v_text') == 'N' .and. recno_v_text > 1
      ft_GoTo(recno_v_text)  // �᫨ ����, �ࠧ� ��६������� �� �㦭�� ��ப�
    endif
    DO WHILE lCont
      if nKey != 0
        oBrowse:forcestable()  // �⠡�������
        IF oBrowse:hitBottom .or. oBrowse:hitTop
          //TONE( 200, 1 )
        ENDIF
        FT_MSHOWCRS(fl_mouse)
      endif
      nKey := 0
      /*if fl_mouse .and. (km := FT_MGETPOS()) == 1
        x_mouse := FT_MGETX() ; y_mouse := FT_MGETY()
        if y_mouse == 24
          do case
            case between(x_mouse,2,4)   ; nKey := K_ESC
            case x_mouse == 17          ; nKey := K_UP
            case x_mouse == 19          ; nKey := K_DOWN
            case between(x_mouse,22,25) ; nKey := K_HOME  ; clear_mouse()
            case between(x_mouse,29,31) ; nKey := K_END   ; clear_mouse()
            case between(x_mouse,35,38) ; nKey := K_PGUP  ; clear_mouse()
            case between(x_mouse,42,45) ; nKey := K_PGDN  ; clear_mouse()
            case x_mouse == 48          ; nKey := K_LEFT  ; clear_mouse()
            case x_mouse == 50          ; nKey := K_RIGHT ; clear_mouse()
            //case between(x_mouse,67,68) .and. fl_plus
              //clear_mouse(); FT_MHIDECRS(fl_mouse); help(); FT_MSHOWCRS(fl_mouse)
          endcase
        endif
      endif*/
      if nKey == 0
        nKey := INKEYTRAP()
      endif
      DO CASE
        CASE nKey == K_RIGHT .and. fl_right
          FT_MHIDECRS(fl_mouse)
          j += 10
          oBrowse:refreshAll()
        CASE nKey == K_LEFT .and. fl_right .and. j > 1
          FT_MHIDECRS(fl_mouse)
          j -= 10
          oBrowse:refreshAll()
        CASE nKey == K_UP
          FT_MHIDECRS(fl_mouse)
          oBrowse:up()
        CASE nKey == K_DOWN
          FT_MHIDECRS(fl_mouse)
          oBrowse:down()
        CASE nKey == K_PGUP
          FT_MHIDECRS(fl_mouse)
          oBrowse:pageUp()
        CASE nKey == K_PGDN
          FT_MHIDECRS(fl_mouse)
          oBrowse:pageDown()
        CASE nKey == K_HOME .or. nkey == K_CTRL_HOME
          FT_MHIDECRS(fl_mouse)
          oBrowse:goTop()
        CASE nKey == K_END .or. nkey == K_CTRL_END
          FT_MHIDECRS(fl_mouse)
          buf1 := save_maxrow()
          mywait()
          oBrowse:goBottom()
          rest_box(buf1)
        CASE nKey == K_F3 .and. !empty(mf_print) // "ࠧ१���" ���� ��� ࠧ���쭮� ����.
          CutDocument(mfile, mregim)
          oBrowse:refreshAll()
        CASE nKey == K_F2 // �뢥�� ���ଠ�� � ���㬥��.
          InfoDocument(mfile, mregim)
        CASE nKey == K_F4 .and. yes_edit .and. !empty(mf_print) // ।���஢����
          lCont := .F.
          lEdit := .T.
        CASE nKey == K_ESC
          lCont := .F.
        CASE nKey != 0 .and. !empty(mf_print)
          s := mf_print + '(' + lstr(nKey) + ',' + ;
                          lstr(mregim) + ',' + ;
                          '"' + pr_func + '",' + ;
                          '"' + name_file + '",'
          if !empty(yes_FF)
            s += '"' + xtoc(yes_FF) + '"'
          endif
          s += ')'
          if &(s)
            oBrowse:refreshAll()   // �㭪�� ������ �������� .t. ���
          endif                    // ���������� TBrowse, ���� .f.
          if count_copy > 0 .and. eq_any(nKey, K_F7, K_F8, K_F9)
            if ++raz >= count_copy
              lCont := .F.
            endif
          endif
          nKey := 256
      ENDCASE
    ENDDO
    FT_USE()
    if fl_mouse
      clear_mouse()
      FT_MHIDECRS()
    endif
    if lEdit
      ViewEditor(mfile)
      oBrowse:refreshAll()
    else
      exit
    endif
  enddo
  setcolor(tmp_color)
  restore screen from buf
  chm_help_code := help_code := tmp_help
  nhelp_code := tmp_nhelp
  // ����⠭���� ������ �ࠢ�����
  for i := 1 to len(arr_keys)
    if arr_keys[i, 2] != NIL
      setkey(arr_keys[i, 1], arr_keys[i, 2])
    endif
  next
  RETURN NIL

// ।���஢���� 䠩��
Function ViewEditor(name_file)
  Local s, buf := savescreen(), tmp_color := setcolor(), c1, c2,;
      tmp_help, tmp_nhelp, width, mtitle, bSaveHandler

  if !file(name_file)
    return func_error('�� ��᪥ ��� 䠩�� ' + name_file)
  endif
  tmp_help := if(type('chm_help_code') == 'N', chm_help_code, help_code)
  mywait()
  if !empty(s := _upr_DOSedit())  // ���譨� ।����
    bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
    BEGIN SEQUENCE
    run (s + ' ' + name_file)
    RECOVER USING error
      func_error('�訡�� ����᪠ ���譥�� ।����')
    END
    // ����⠭������� ��砫쭮� �ணࠬ�� ��ࠡ�⪨ �訡��
    ERRORBLOCK(bSaveHandler)
  else  // ����७��� ।����
    ft_use(name_file)
    width := ft_strlen()
    ft_use()
    //
    setkey(K_ESC, {|| __keyboard(CHR(23)) } )  // KS_CTRL_W
    bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
    BEGIN SEQUENCE
      s := memoread(name_file)
      status_key('^<Esc>^ - ��室 ��� ��ᬮ��/����;  ^<F1>^ - ������')
      chm_help_code := help_code := 10  // H_MemoEdit
      // ��� ����� HELP-��⥬�
      tmp_nhelp := ret_nhelp_code()
      nhelp_code := 'MemoEdit'
      pr_1_str('������஢���� 䠩�� ' + upper(name_file))
      setcolor(cDataCScr)
      setcursor()
      s := memoedit(s, 1, 0, 23, 79, .t., , width)
      s := strtran(s, Hos, eos) // atrepl(Hos,@s,eos)
      memowrit(name_file, s)
    RECOVER USING error
      func_error(4, '�訡�� ����᪠ ����७���� ।����')
    END
    // ����⠭������� ��砫쭮� �ணࠬ�� ��ࠡ�⪨ �訡��
    ERRORBLOCK(bSaveHandler)
    chm_help_code := help_code := tmp_help
    nhelp_code := tmp_nhelp
    setkey(K_ESC, NIL)
  endif
  setcursor(0)
  restscreen(buf)
  setcolor(tmp_color)
  return NIL

//
Function InfoDocument(name_file, reg_print)
  Local s, buf := savescreen(), tmp_color := setcolor(), ;
      r1 := 10, c1 := 10, c2 := 69, cregim, ;
      tmp_help, tmp_nhelp, width, mtitle, CountPage

  if !file(name_file)
    return func_error('�� ��᪥ ��� 䠩�� ' + name_file)
  endif
  tmp_help := if(type('chm_help_code') == 'N', chm_help_code, help_code)
  chm_help_code := help_code := -1
  // ��� ����� HELP-��⥬�
  tmp_nhelp := ret_nhelp_code()
  nhelp_code := 'InfoDocum'
  mywait()
  if !between(reg_print, 1, 6)
    reg_print := 1
  endif
  if equalany(reg_print, 1, 4)
    cregim := 'Pica'
  elseif equalany(reg_print, 2, 5)
    cregim := 'Elite'
  else
    cregim := 'Condensed'
  endif
  if reg_print < 4
    cregim += '  6 lpi'
  else
    cregim += '  8 lpi'
  endif
  if type('yes_albom') == 'L' .and. yes_albom
    cregim += ' (��졮���� �����)'
  endif
  CountPage := ft_CountPage()
  box_shadow(r1, c1, r1 + 8, c2, color0, '���ଠ�� � ���㬥�� ' + name_file, 'W+/BG')
  setcolor('N/BG, W+/N, , , B/BG')
  @ r1 + 2, c1 + 2 say '������ 䠩�� - ' + expand_value(ft_FileSize()) + ' ����'
  @ r1 + 3, c1 + 2 say '��ਭ� ���㬥�� - ' + lstr(ft_StrLen()) + ' ᨬ�����'
  @ r1 + 4, c1 + 2 say '����� ���㬥�� - ' + lstr(ft_LastRec()) + ' ��ப'
  @ r1 + 5, c1 + 2 say '������⢮ ���⮢ � ���㬥�� - ' + lstr(CountPage)
  @ r1 + 6, c1 + 2 say '����� ���� - ' + cregim
  status_key('^<Esc>^ - ��室')
  inkeytrap(0)
  chm_help_code := help_code := tmp_help
  nhelp_code := tmp_nhelp
  restscreen(buf)
  setcolor(tmp_color)
  return NIL

//
Function CutDocument(name_file, reg_print)
  Local i, s, buf := savescreen(), tmp_color := setcolor(), ;
      r1 := 10, c1 := 10, c2 := 69, smsg := '���� ��稭����� � ����樨', ;
      tmp_help, tmp_nhelp, width, mtitle, fl := .f.

  tmp_help := if(type('chm_help_code') == 'N', chm_help_code, help_code)
  chm_help_code := help_code := -1
  // ��� ����� HELP-��⥬�
  tmp_nhelp := ret_nhelp_code()
  nhelp_code := 'CutDocum'
  Private m2 := _p_list_2, m3 := _p_list_3, m4 := _p_list_4, ;
                         m5 := _p_list_5, m6 := _p_list_6
  width := ft_StrLen()
  box_shadow(r1, c1, r1 + 10, c2, color0, '���१���� ���㬥�� ' + name_file, 'W+/BG')
  setcolor('N/BG, W+/N, , , B/BG')
  @ r1 + 2, c1 + 2 say '��ਭ� ���㬥�� - ' + lstr(width) + ' ᨬ�����'
  @ r1 + 3, c1 + 2 say '���㬥�� �� ���� ����� ࠧ������ �� 2 (6) ��⥩:' color 'B/BG'
  @ r1 + 4, c1 + 2 say padr('����'   ,10) + smsg get m2 pict '999'
  @ r1 + 5, c1 + 2 say padr('�����'   ,10) + smsg get m3 pict '999'
  @ r1 + 6, c1 + 2 say padr('��⢥���',10) + smsg get m4 pict '999'
  @ r1 + 7, c1 + 2 say padr('����'    ,10) + smsg get m5 pict '999'
  @ r1 + 8, c1 + 2 say padr('�����'   ,10) + smsg get m6 pict '999'
  status_key('^<Esc>^ - ��室;  ^<Enter>^ - ��������� ����ன��')
  myread()
  if lastkey() != K_ESC .and. m2 >= 0 .and. m3 >= 0
    for i := 2 to 6
      fl := vCutDocument(i, width)
      if !fl
        exit
      endif
    next
    if fl
      _p_list_2 := m2
      _p_list_3 := m3
      _p_list_4 := m4
      _p_list_5 := m5
      _p_list_6 := m6
    endif
  endif
  chm_help_code := help_code := tmp_help
  nhelp_code := tmp_nhelp
  restscreen(buf)
  setcolor(tmp_color)
  return NIL

//
Static Function vCutDocument(i, width)
  Local fl := .t., pole1 := 'm' + lstr(i), pole2 := 'm' + lstr(i - 1)

  if i > 2
    if &pole1 > 0 .and. &pole1 - 1 <= &pole2
      fl := func_error(4, '����ୠ� ������ ' + lstr(i) + '-� ���!')
    endif
  endif
  if fl .and. &pole1 > width
    fl := func_error(4, '���誮� ����讥 ' + lstr(i) + '-� ���祭��!')
  endif
  return fl

//
Function str_v_text(lj)
  Local s := ft_readln(), s1, s2, s3, ls

  if _p_list_2 == 0 .or. s == chr(12) .or. s == 'FF'
    s := substr(s, lj)
  else
    ls := chr(221) + chr(27) + chr(26) + chr(222)
    s1 := substr(s + space(_p_list_2), 1, _p_list_2 - 1) + ls
    if _p_list_3 == 0
      s1 += substr(s, _p_list_2)
    else
      s1 += substr(s + space(_p_list_3), _p_list_2, _p_list_3 - _p_list_2) + ls
      if _p_list_4 == 0
        s1 += substr(s, _p_list_3)
      else
        s1 += substr(s + space(_p_list_4), _p_list_3, _p_list_4 - _p_list_3) + ls
        if _p_list_5 == 0
          s1 += substr(s, _p_list_4)
        else
          s1 += substr(s + space(_p_list_5), _p_list_4, _p_list_5 - _p_list_4) + ls
          if _p_list_6 == 0
            s1 += substr(s, _p_list_5)
          else
            s1 += substr(s + space(_p_list_6), _p_list_5, _p_list_6 - _p_list_5) + ls
            s1 += substr(s, _p_list_6)
          endif
        endif
      endif
    endif
    s := substr(s1, lj)
  endif
  return s
