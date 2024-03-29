#include 'inkey.ch'
#include 'function.ch'
#include 'edit_spr.ch'

// 10.02.17
Function edit_u_spr(k, _arr, r1)
  Static si1 := 1
  Local mas_pmt, mas_msg, mas_fun, j, c1, c2, len_browse 

  DEFAULT k TO 1, r1 TO T_ROW
  do case
    case k == 1
      Private t_arr := _arr, __pr1 := r1
      if !(_arr[US_LEFT] == 0 .and. _arr[US_RIGHT] == maxcol())
        c1 := _arr[US_LEFT]
        len_browse := _arr[US_RIGHT] - _arr[US_LEFT]
        c2 := c1 + len_browse
        if c2 > maxcol() - 2
          c2 := maxcol() - 2
          c1 := c2 - len_browse
        endif
        if c1 < 0
          c1 := 0
        endif
        t_arr[US_LEFT] := c1 
        t_arr[US_RIGHT] := c2 
      endif
      VALDEFAULT t_arr[US_ADD_MENU]   ,'A' TO {}
      VALDEFAULT t_arr[US_SEMAPHORE]  ,'�' TO ''
      VALDEFAULT t_arr[US_BLK_DEL]    ,'B' TO {||.t.}
      VALDEFAULT t_arr[US_TITUL]      ,'C' TO t_arr[US_IM_PADEG]
      VALDEFAULT t_arr[US_TITUL_COLOR],'C' TO 'B/BG'
      if valtype(t_arr[US_TITUL]) == 'C' .and. len(t_arr[US_TITUL]) > 1
        t_arr[US_TITUL] := upper(left(t_arr[US_TITUL], 1))+substr(t_arr[US_TITUL], 2)
      endif
      //
      mas_pmt := {'~������஢����'}
      mas_msg := {'������஢���� �ࠢ�筨�� ' + t_arr[US_ROD_PADEG]}
      mas_fun := {'edit_u_spr(11)'}
      if !(type('tip_polzovat') == 'N')
        Private tip_polzovat := 0
      endif
      if valtype(t_arr[US_BLK_DUBL]) == 'B' .and. tip_polzovat == 0  // ��� �����������
        aadd(mas_pmt, '~�������� �㡫���⮢')
        aadd(mas_msg, '�������� �㡫���⮢ �� �ࠢ�筨�� ' + t_arr[US_ROD_PADEG])
        aadd(mas_fun, 'edit_u_spr(12)')
      endif
      for k := 1 to len(t_arr[US_ADD_MENU])
        aadd(mas_pmt, t_arr[US_ADD_MENU,k, 1])
        aadd(mas_msg, t_arr[US_ADD_MENU,k, 2])
        aadd(mas_fun, t_arr[US_ADD_MENU,k, 3])
      next
      if !empty(t_arr[US_SEMAPHORE])
        if !G_SLock(t_arr[US_SEMAPHORE])
          return func_error(4, '����� � ����� ०���� ࠡ�⠥� ��㣮� ���짮��⥫�!')
        endif
      endif
      if len(mas_pmt) == 1
        edit_u_spr(11)
      else
        if __pr1 > 11
          __pr1 := __pr1 - len(mas_pmt) - 3
        endif
        popup_prompt(__pr1, T_COL - 5, si1, mas_pmt, mas_msg, mas_fun)
      endif
      if !empty(t_arr[US_SEMAPHORE])
        G_SUnLock(t_arr[US_SEMAPHORE])
      endif
    case k == 11
      if valtype(t_arr[US_COLUMN]) == 'A'
        Private arr2[BR_LEN]
        DEFAULT t_arr[US_TOP] TO __pr1, ;
              t_arr[US_ARR_BROWSE] TO {'�', '�', '�', , .t.}
        arr2[BR_TOP]    := t_arr[US_TOP]
        arr2[BR_BOTTOM] := t_arr[US_BOTTOM]
        arr2[BR_LEFT]   := t_arr[US_LEFT]
        arr2[BR_RIGHT]  := t_arr[US_RIGHT]
        arr2[BR_OPEN]   := {|nk, ob| f1_e_u_spr(nk, ob, 'open', t_arr[US_BLK_INDEX]) }
        arr2[BR_CLOSE]  := {|| dbCloseAll() }
        arr2[BR_COLOR]       := t_arr[US_COLOR]
        arr2[BR_TITUL]       := t_arr[US_TITUL]
        arr2[BR_TITUL_COLOR] := t_arr[US_TITUL_COLOR]
        arr2[BR_FL_INDEX]    := t_arr[US_FL_INDEX]
        arr2[BR_COLUMN]      := t_arr[US_COLUMN]
        arr2[BR_ARR_BROWSE]  := t_arr[US_ARR_BROWSE]
        arr2[BR_EDIT]        := {|nk, ob| f1_e_u_spr(nk, ob, 'edit')}
        edit_browse(arr2)
      else
        popup_edit(t_arr[US_BASE], __pr1, T_COL - 5, 22, , , , 'fdel_u_spr', , , , , , ;
                  t_arr[US_TITUL], t_arr[US_TITUL_COLOR])
      endif
    case k == 12
      del_d_u_spr()
  endcase
  if k > 10
    j := int(val(right(lstr(k), 1)))
    if between(k, 11, 19)
      si1 := j
    endif
  endif
  return NIL

//
Function f1_e_u_spr(nKey, oBrow, regim, blk_index)
  Local ret := -1, __pole_kod, _len_pole_kod, f_dostup
  Local buf, fl := .f., rec, rec1, i, j, k := 19, tmp_color

  do case
    case regim == 'open'
      G_Use(t_arr[US_BASE], , '__US')
      if blk_index == NIL
        index on upper(name) to tmp___us
      else
        eval(blk_index)
      endif
      if t_arr[US_BLK_FILTER] != NIL
        eval(t_arr[US_BLK_FILTER])  // ���� ���� 䨫���樨 ��
      endif
      go top
      ret := !eof()
    case regim == 'edit'
      if nKey == K_INS
        if (__pole_kod := ( fieldnum('KOD') > 0 ))
          _len_pole_kod := fieldsize(fieldnum('KOD'))
        endif
        i := 0
        if __pole_kod // ��� �� � ����� KOD
          i := int(val(replicate('9', _len_pole_kod)))
        elseif type('max_dop_rec') == 'N'
          i := max_dop_rec
        endif
        if i > 0
          rec := recno()
          if t_arr[US_BLK_FILTER] != NIL
            set filter to
          endif
          j := 0
          dbeval({|| ++j } )
          if t_arr[US_BLK_FILTER] != NIL
            eval(t_arr[US_BLK_FILTER])  // ���� ���� 䨫���樨 ��
          endif
          goto (rec)
          if j >= i
            func_error(4, '������⢮ ����ᥩ ���⨣�� ' + lstr(i) + '. ���������� ����饭�!')
            return ret
          endif
        endif
      endif
      do case
        case nKey == K_INS .or. nKey == K_ENTER
          rec := recno()
          Private gl_area := {1, 0, 23, pc2, 0}
          save screen to buf
          if nkey == K_INS .and. !fl_found
            colorwin(pr1 + 3, pc1, pr1 + 3, pc2, 'N/N', 'W+/N')
          endif
          for i := 1 to len(t_arr[US_EDIT_SPR])
            --k
            tmp1 := t_arr[US_EDIT_SPR, i, A__NAME]
            tmp := 'm' + tmp1
            Private &tmp
            if nKey == K_ENTER
              &tmp := __us->&tmp1
            else
              &tmp := t_arr[US_EDIT_SPR, i, A__INIT]
            endif
            if (tmp2 := is_element(t_arr[US_EDIT_SPR, i], A__FIND)) != NIL
              tmp1 := 'm1' + tmp1
              Private &tmp1 := &tmp
              &tmp := eval(tmp2, &tmp)
            endif
          next
          tmp_color := setcolor(cDataCScr)
          box_shadow(k,t_arr[US_LEFT], 22, t_arr[US_RIGHT], , ;
                       if(nKey == K_INS, '����������', '������஢����'), cDataPgDn)
          setcolor(cDataCGet)
          shirina := t_arr[US_RIGHT] - t_arr[US_LEFT]
          do while .t.
            old_set := __SetCentury( 'on' )
            for i := 1 to len(t_arr[US_EDIT_SPR])
              tmp := 'm' + t_arr[US_EDIT_SPR, i, A__NAME]
              tmp1 := shirina - 3 - len(t_arr[US_EDIT_SPR, i, A__SAY])
              if t_arr[US_EDIT_SPR, i, A__PICTURE] == NIL
                if type(tmp) == 'C'
                  mpic := if(len(&tmp) > tmp1, '@S' + lstr(tmp1), '')
                elseif t_arr[US_EDIT_SPR, i, A__TYPE] == 'N'
                  mpic := replicate('9', t_arr[US_EDIT_SPR, i, A__LEN])
                  if t_arr[US_EDIT_SPR, i, A__DEC] > 0
                    mpic := stuff(mpic, len(mpic) - t_arr[US_EDIT_SPR, i, A__DEC], 1, '.')
                  endif
                else
                  mpic := ''
                endif
              elseif type(tmp) == 'C' .and. len(&tmp) > tmp1
                mpic := t_arr[US_EDIT_SPR, i, A__PICTURE] + '@S' + lstr(tmp1)
              else
                mpic := t_arr[US_EDIT_SPR, i, A__PICTURE]
              endif
              @ k + 1 + i, t_arr[US_LEFT] + 2 say t_arr[US_EDIT_SPR, i, A__SAY] ;
                      get &tmp picture mpic
              GetList[i]:reader := t_arr[US_EDIT_SPR, i, A__BLOCK]
              GetList[i]:preBlock := is_element(t_arr[US_EDIT_SPR, i], A__WHEN)
              GetList[i]:postBlock := is_element(t_arr[US_EDIT_SPR, i], A__VALID)
            next
            status_key('^<Esc>^ - ��室 ��� �����;  ^<Enter>^ - ���⢥ত���� �����')
            myread()
            __SetCentury( old_set )
            if lastkey() != K_ESC .and. f_Esc_Enter(1)
              if empty(mname)
                func_error(4, '������� �� ��� ���ଠ��!')
                Loop
              endif
              select __US
              f_dostup := .t.
              if nKey == K_INS
                if t_arr[US_BLK_FILTER] != NIL
                  set filter to
                endif
                f_dostup := AddRecN()
                if t_arr[US_BLK_FILTER] != NIL
                  eval(t_arr[US_BLK_FILTER])  // ���� ���� 䨫���樨 ��
                endif
              endif
              if f_dostup
                if nKey == K_INS
                  fl_found := .t.
                  rec := recno()
                  if fieldnum('kod') > 0
                    replace kod with rec
                  endif
                  if t_arr[US_BLK_WRITE] != NIL
                    eval(t_arr[US_BLK_WRITE])  // ������ ��㣨� �����
                  endif
                else
                  G_RLock(forever)
                endif
                for i := 1 to len(t_arr[US_EDIT_SPR])
                  tmp1 := t_arr[US_EDIT_SPR, i, A__NAME]
                  tmp := 'm' + tmp1
                  if is_element(t_arr[US_EDIT_SPR, i], A__FIND) != NIL
                    tmp2 := 'm1' + tmp1
                    replace &tmp1 with &tmp2
                  else
                    replace &tmp1 with &tmp
                  endif
                next
                UNLOCK
                COMMIT
              endif
              oBrow:goTop()
              goto (rec)
              ret := 0
            elseif nKey == K_INS .and. !fl_found
              ret := 1
            endif
            exit
          enddo
          select __US
          setcolor(tmp_color)
          restore screen from buf
        case nKey == K_DEL
          if fdel_u_spr(__us->(recno())) .and. f_Esc_Enter(2)
            DeleteRec()
            go top
            oBrow:goTop()
            ret := 0
            if eof()
              ret := 1
            endif
          endif
      endcase
  endcase
  return ret

//
Function fdel_u_spr(mkod)
  Local fl, buf := save_maxrow(), tmp_select := select()

  stat_msg('�ந�������� �஢�ઠ �� ����稥 ������ ��ப� � ��㣨� ����� ������.')
  fl := eval(t_arr[US_BLK_DEL], mkod)  // ������ .t., �᫨ ����� 㤠����
  if !fl
    func_error(4, '������ ��ப� ��������� � ��㣨� ����� ������. �������� ����饭�!')
  endif
  if tmp_select > 0
    select (tmp_select)
  endif
  rest_box(buf)
  return fl

//
Static Function input_u_spr(r, c)
  Static sk
  Local k := popup_edit(t_arr[US_BASE], r, c, 22, sk, PE_RETURN, , , , , , , , ;
                        t_arr[US_TITUL], t_arr[US_TITUL_COLOR])

  if k != NIL
    sk := k[1]
    k[2] := alltrim(k[2])
  endif
  return k

//
Static Function del_d_u_spr()
  Local buf := savescreen(), s1, s2, k1, k2

  if !empty(t_arr[US_SEMAPHORE])
    if G_SCount(sem_task) > 1
      return func_error('� ����� ������ �������� ��������� ����饭�. ����⠥� ��㣠� �����.')
    endif
    G_SLock(sem_vagno)
  endif
  n_message({'����� ०�� �।�����祭 ��� 㤠����� ����� ��ப�', ;
            '"' + t_arr[US_ROD_PADEG] + '" � ��७�� �ᥩ', ;
            '�⭮��饩�� � ��� ���ଠ樨 ��㣮� ��ப�'}, , ;
            cColorStMsg, cColorStMsg, , , cColorSt2Msg)
  f_message({'�롥�� 㤠�塞�� ��ப�'}, , color1, color8, 0)
  if (k1 := input_u_spr(__pr1, T_COL - 7)) != NIL
    s1 := k1[2]
    restscreen(buf)
    f_message({'�롥�� ��ப�, �� ������ ��७����� ���ଠ��', ;
              '�� <.. ' + s1 + ' ..>'}, , ;
              color1, color8, 0)
    if (k2 := input_u_spr(__pr1, T_COL - 7)) != NIL
      restscreen(buf)
      if k1[1] == k2[1]
        func_error(4, '��� ࠧ� ��࠭� ���� � � �� ���祭�� ' + t_arr[US_IM_PADEG])
      else
        restscreen(buf)
        s2 := k2[2]
        f_message({'����塞�� ��ப�:', ;
                 '"' + s1 + '".', ;
                 '��� ���ଠ�� ��७����� � ��ப�:', ;
                 '"' + s2 + '".'},, ;
                  color1, color8)
        if f_Esc_Enter('㤠�����', .t.)
          mywait()
          eval(t_arr[US_BLK_DUBL], k1[1], k2[1])
          //
          G_Use(t_arr[US_BASE])
          goto (k1[1])
          DeleteRec(.t.)
          close databases
          stat_msg('������ �����襭�!')
          music_m('OK')
          INKEY(2)
        endif
      endif
    endif
  endif
  restscreen(buf)
  if !empty(t_arr[US_SEMAPHORE])
    G_SUnLock(sem_vagno)
  endif
  return .t.
