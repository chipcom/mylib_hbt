#include "set.ch"
#include "function.ch"
#include "edit_spr.ch"
#include "inkey.ch"
#include "getexit.ch"

***** 10.04.22 ��������� GetReader � ������� ���� (ࠧ���묨 ᯮᮡ���)
Function menu_reader(get, tmp_mas, type_menu, kod_help, mcolor, fl_esc, titul, titul_color, fl_sort)
  // get       - Get-��ꥪ�
  // tmp_mas   - 㪠��⥫� �� ���ᨢ
  // type_menu - ⨯ ����
  // kod_help  - ��� help'� (�� 㬮�砭�� -1)
  // mcolor    - 梥� ���� (�� 㬮�砭�� "N/BG,W+/N,,,B/W" (cDataCMenu))
  // fl_esc    - 䫠� ��室� �� ESC
  // titul     - ��ப� ��������� ����
  // titul_color - 梥� ���������
  // fl_sort   - 䫠� ���஢�� ����
  Local k, buf, r1, c1 := get:col, r2, c2, nr := len(tmp_mas), ;
      nc := 0, t_mas := {}, tk_mas := {}, flag_2 := .f., i, ;
      tmp_color := setcolor(), nc1, tmp_help, tmp_nhelp, lregim,;
      old_value, len_var, tmp_list, old_esc, fl_valid := .t., s, tmp_mas_sort

  Private __mvar := readvar()
  if empty(__mvar)  // �᫨ �맮� �१ VGET
    __mvar := get:name
  endif
  Private __m1var := "M1" + substr(__mvar, 2)

  DEFAULT fl_esc TO .t., fl_sort TO .f.
  if type("kol_screen") == "N" .and. kol_screen == 1
    fl_esc := .f.  // ��� �-�� f_edit_spr
  endif
  if !(type("gl_area") == "A")        // �� ��直� ��砩, �᫨ �� ��।�����
    Private gl_area := {1, 0, maxrow() - 1, maxcol(), 0}  // � ��뢠�饩 �ணࠬ��
  endif
  if valtype(get:preBlock) == "B" .and. !eval(get:preBlock, get)
    return NIL
  endif
  if valtype(&__mvar) != "C"
    &__mvar := space(10) // �� ��直� ��砩, �᫨ �� ��।����� � ��뢠�饩 �-��
  endif
  get:SetFocus()
  @ get:row, get:col say left(&__mvar, gl_area[4] - get:col) color afteratnum(",", tmp_color, 1)
  SETCURSOR(0)
  IF fl_esc
    set key K_ESC to
  endif
  tmp_help := if(type("chm_help_code") == "N", chm_help_code, help_code)
  tmp_nhelp := ret_nhelp_code()
  if (k := inkeytrap(0)) == K_ENTER .or. k >= 32
    DEFAULT kod_help TO -1, mcolor TO "N/BG,W+/N,,,B/W" //  cDataCMenu
    chm_help_code := help_code := kod_help
    nhelp_code := kod_help
    len_var := len(&__mvar)  // len_var := len(get:buffer)
    old_esc := Set(_SET_ESCAPE, .t.)
    do case
      case eq_any(type_menu, A__MENUHORIZ, A__MENUVERT, A__MENUVERT_SPACE)
        if len(tmp_mas) > 0 .and. valtype(tmp_mas[1]) == "A"
          if fl_sort // ���஢�� ����᪠���� ⮫쪮 ��� ��㬥୮�� ���ᨢ�
            tmp_mas_sort := aclone(tmp_mas)
            asort(tmp_mas_sort, , , {|x, y| upper(x[1]) < upper(y[1]) })
            aeval(tmp_mas_sort, {|x| aadd(t_mas, x[1]), aadd(tk_mas, x[2])} )
          else
            aeval(tmp_mas, {|x| aadd(t_mas, x[1]), aadd(tk_mas, x[2])} )
          endif
          flag_2 := .t.
        else
          t_mas := aclone(tmp_mas)
        endif
        aeval(t_mas, {|x| nc := max(nc, len(x))} )
        if (nc1 := nc) > maxcol() - 5
          nc1 := maxcol() - 5
        endif
        if type_menu == A__MENUHORIZ
          r1 := r2 := get:row
          c2 := c1
          aeval(t_mas, {|x| c2 += len(x) + 2 } )
          Dec(c2)
        else
          if get:row > int(maxrow() / 2)
            r2 := get:row - 1
            r1 := r2 - nr - 1
          else
            r1 := get:row + 1
            r2 := r1 + nr + 1
          endif
          c2 := c1 + nc1 + 3
        endif
        if c2 > maxcol() - 2
          c2 := maxcol() - 2
          c1 := maxcol() - nc1 - 5
        endif
        if r1 < 0
          r1 := 0
        endif
        if r2 > maxrow() - 2
          r2 := maxrow() - 2
        endif
        buf := savescreen()
        setcolor(mcolor)
        if flag_2
          i := ascan(tk_mas, &__m1var)
          old_value := &__m1var
        else
          i := ascan(t_mas, &__mvar)
          old_value := &__mvar
        endif
        save gets to tmp_list
        if type_menu == A__MENUHORIZ  // ��ਧ��⠫쭮� ���� MENU TO
          @ r1, c1 clear to r2, c2
          nc1 := c1 + 1
          for k := 1 to len(t_mas)
            @ r1, nc1 prompt t_mas[k]
            nc1 += len(t_mas[k]) + 2
          next
          menu to i
        else                    // ���⨪��쭮� ���� POPUP
          if type_menu == A__MENUVERT_SPACE
            lregim := PE_SPACE
            status_key("^<Esc>^ - �⪠�;  ^<Enter>^ - �롮�;  ^<�஡��>^ - ���⪠ ����")
          else
            lregim := NIL
            status_key("^<Esc>^ - �⪠�;  ^<Enter>^ - �롮�")
          endif
          i := popup(r1, c1, r2, c2, t_mas, i, mcolor, .t., , lregim, titul, titul_color)
        endif
        restore gets from tmp_list
        setcolor(tmp_color)
        restscreen(buf)
        if type_menu == A__MENUVERT_SPACE .and. lastkey() == K_SPACE
          if flag_2
            &__m1var := iif(valtype(old_value) == "N", 0, "")
          endif
          @ get:row, get:col clear to get:row, get:col + len_var - 1
          &__mvar := space(10)
        elseif i > 0
          if flag_2
            &__m1var := tk_mas[i]
          endif
          @ get:row, get:col clear to get:row, get:col + len_var - 1
          &__mvar := left(t_mas[i], gl_area[4] - get:col)
        endif
      case type_menu == A__MENUBIT  // ���⨪��쭮� ���� � ��⮢�� �������樥�
        if valtype(tmp_mas[1]) == "A"
          aeval(tmp_mas, {|x| aadd(t_mas, x[1]), aadd(tk_mas, x[2])} )
          flag_2 := .t.
        else
          t_mas := aclone(tmp_mas)
        endif
        aeval(t_mas, {|x| nc := max(nc, len(x))} )
        nc += 6
        if (nc1 := nc) > maxcol() - 7
          nc1 := maxcol() - 7
        endif
        if get:row > int(maxrow() / 2)
          r2 := get:row - 1
          r1 := r2 - nr - 1
        else
          r1 := get:row + 1
          r2 := r1 + nr + 1
        endif
        c2 := c1 + nc1 + 1
        if c2 > maxcol() - 2
          c2 := maxcol() - 2
          c1 := maxcol() - nc1 - 3
        endif
        if r2 > maxrow() - 2
          r2 := maxrow() - 2
        endif
        if r1 < 0
          r1 := 0
        endif
        buf := save_box(r1, c1, r2 + 1, c2 + 2)
        buf1 := save_maxrow()
        tmp_color := setcolor(mcolor)
        __m1var := "M1" + substr(__mvar, 2)
        old_value := k := &__m1var
        if flag_2
          aeval(tmp_mas, {|x, i| t_mas[i] := if(isbit(k, x[2]), " * ", "   ") + x[1] })
        else
          aeval(t_mas, {|x, i| t_mas[i] := if(isbit(k, i), " * ", "   ") + t_mas[i]})
        endif
        status_key("^<Esc>^ - �⪠�; ^<Enter>^ - ���⢥ত����; ^<Ins>^ - ᬥ�� �ਧ����")
        save gets to tmp_list
        if popup(r1, c1, r2, c2, t_mas, i, mcolor, .t., "fmenu_reader") > 0
          &__m1var := 0
          FOR i := 1 TO nr
            IF "*" $ left(t_mas[i], 3)
              if flag_2
                &__m1var := SETBIT(&__m1var, tk_mas[i])
              else
                &__m1var := SETBIT(&__m1var, i)
              endif
            ENDIF
          NEXT
        endif
        restore gets from tmp_list
        setcolor(tmp_color)
        rest_box(buf)
        rest_box(buf1)
        if (i := ascan(gl_arr, {|x| UPPER(x[A__NAME]) == UPPER(substr(__mvar, 2))})) > 0
          @ get:row, get:col clear to get:row, get:col + len_var - 1
          &__mvar := left(eval(gl_arr[i, A__FIND], &__m1var), gl_area[4] - get:col)
        endif
      case eq_any(type_menu, A__POPUPBASE, A__POPUPBASE1, A__POPUPEDIT, A__POPUPMENU)
        // ���� �� ᮤ�ন���� "���⮩" ���� ������ - POPUP_EDIT
        t_mas := aclone(tmp_mas)
        asize(t_mas, 8)
        //  ����ন��� ���ᨢ� t_mas:
        // t_mas[1] - ��� ���� ������ � ���ﬨ kod � name
        // t_mas[2] - ᮮ�饭�� �� �訡�� �� ������⢨� ����室���� ����ᥩ
        // t_mas[3] - ���� FOR-�᫮��� ��� ���᪠ � �� (�᫨ ����� ����� ����)
        // t_mas[4] - ���� ���� ��� ����� ��㣨� ����� (�᫨ ����� ����� ����)
        // t_mas[5] - 蠡��� PICTURE ��� ����� ������ � ���� name
        // t_mas[6] - 梥� (��� ��� ��ப�)
        // t_mas[7] - title
        // t_mas[8] - 梥� title (��ப�)
        DEFAULT t_mas[6] TO mcolor
        DEFAULT t_mas[7] TO titul
        DEFAULT t_mas[8] TO titul_color
        old_value := &__m1var
        if get:row > int(maxrow() / 2)
          r2 := get:row - 1
          r1 := r2 - 10
        else
          r1 := get:row + 1
          r2 := r1 + 12
        endif
        if r2 > maxrow() - 2
          r2 := maxrow() - 2
        endif
        if r1 < 0
          r1 := 0
        endif
        save gets to tmp_list
        do case
          case type_menu == A__POPUPBASE
            i := 2
          case type_menu == A__POPUPBASE1
            i := 2.5
          case type_menu == A__POPUPEDIT
            i := 3
          case type_menu == A__POPUPMENU
            i := 4
        endcase
        k := popup_edit(t_mas[1], r1, get:col, r2, &__m1var, i, t_mas[6], , ;
                      t_mas[2], t_mas[3], t_mas[4], t_mas[5], (get:row <= int(maxrow() / 2)), ;
                      t_mas[7], t_mas[8] )
        restore gets from tmp_list
        setcolor(tmp_color)
        if k != NIL
          &__m1var := k[1]
          @ get:row, get:col clear to get:row, get:col + len_var - 1
          &__mvar := if(!empty(k[2]), left(rtrim(k[2]), gl_area[4] - get:col), space(10))
        endif
      case type_menu == A__FUNCTION // �㭪�� ��饣� �����祭��
        old_value := &__m1var
        // � ���ᨢ� tmp_mas - ���� ������� -> ���� ���� � �맮��� �㭪樨,
        // � ����� ��।����� �� ��ࠬ��� : ��� (m1...), row � col get'�
        save gets to tmp_list
        k := eval(tmp_mas[1], old_value, get:row, get:col)
        restore gets from tmp_list
        setcolor(tmp_color)
        if k != NIL
          &__m1var := k[1]
          s := rtrim(k[2])
          if len(tmp_mas) > 1 .and. valtype(tmp_mas[2]) == "N"
            s := padr(s, tmp_mas[2])
          endif
          @ get:row, get:col clear to get:row, get:col + len_var - 1
          &__mvar := if(!empty(s), left(s, gl_area[4] - get:col), space(10))
          if len(tmp_mas) > 1 .and. valtype(tmp_mas[2]) == "N"
            &__mvar := padr(s, tmp_mas[2])
          endif
        endif
    endcase
    if valtype(get:postBlock) == "B"
      fl_valid := eval(get:postBlock, get, old_value)
    endif
    Set(_SET_ESCAPE, old_esc)
    get:ExitState := if(fl_valid, GE_ENTER, GE_NOEXIT)
    if eq_any(lastkey(), K_ESC, K_PGDN)
      setlastkey(K_DOWN)
    endif
  else
    do case
      case k == K_ESC
        get:ExitState := GE_ESCAPE
      case k == K_DOWN .or. k == K_TAB
        if valtype(get:postBlock) == "B"
          fl_valid := eval(get:postBlock, get, old_value)
        endif
        if fl_valid
          get:ExitState := GE_DOWN
        else
          get:ExitState := GE_NOEXIT
        endif
      case k == K_CTRL_W .or. k == K_PGDN .or. k == K_PGUP
        get:ExitState := GE_WRITE
      otherwise
        get:ExitState := GE_UP
    endcase
  endif
  get:KillFocus()
  IF fl_esc
    set key K_ESC to f1_edit_spr
  endif
  SetCursor()
  chm_help_code := help_code := tmp_help
  nhelp_code := tmp_nhelp
  return NIL

*****
Function fmenu_reader(nKey, i)

  do case
    case nKey == K_INS
      parr[i] := stuff(parr[i], 2, 1, if("*" == substr(parr[i], 2, 1), " ", "*"))
      keyboard chr(K_TAB)
    case nKey == 43  // ������ "+"
      for i := 1 to len(parr)
        parr[i] := stuff(parr[i], 2, 1, "*")
      next
    case nKey == 45  // ������ "-"
      for i := 1 to len(parr)
        parr[i] := stuff(parr[i], 2, 1, " ")
      next
  endcase
  return 0
