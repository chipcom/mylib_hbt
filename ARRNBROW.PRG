#include "function.ch"
#include "inkey.ch"

*****
FUNCTION Arrn_Browse( nTop, nLeft, nBottom, nRight, arr, arr1, nI,;
                      mfunction, mcolor, titul, titul_color, ;
                      fl_noclear, arr_mouse, mPicture, bGetFunc, fl_ins_del, ;
                      arr_Browse, func_del, func_step )
// nTop, nLeft, nBottom, nRight - ������� ����
// arr  - ��ᬠ�ਢ���� (।����㥬�) ��㬥�� ���ᨢ
// arr1 - ��㬥�� ���ᨢ (� ��ࢮ� ����७�� - ����� �⮫��,
//                          �� ��஬ - ��������� �⮫��,
//                          � ���쥬 ����易�.���� ���� ��� 梥� �⮫�� )
// nI - �� ����� ����� ����� �� �室� � ����
// mfunction - �㭪��, ��뢠���� �� ����⨨ ��।������� ������
// mcolor - 梥� ����
// titul, titul_color - ��������� � ��� 梥�
// fl_noclear - ���.����稭�, 㪠�뢠���, ����⠭�������� �� ��࠭
// arr_mouse - ���ᨢ �����⥩ ��� ���
// mPicture - ���ᨢ ���� ����� ��� �뢮��/।���஢���� �������
//   ���ਬ�� - {{2,0},{11,2},,,}
//              ����� {2,0}  - 1-� ��-� - �᫮, �뢮����, ��� STR(n,2,0)
//                    {11,2} - 2-�� ��-� - �᫮, �뢮����, ��� STR(n,11,2)
//                    ��⠫�� ��-�� - ⨯� "C" � "D"
// bGetFunc - ���� ���� ��� ।���஢���� � �ଥ :
//   bGetFunc := {|b, ar, nDim, nElem, nKey| TestGet(b, ar, nDim, nElem, nKey)}
//   ����� b       - 㪠��⥫� �� ��ꥪ� TBrowse
//         ar      - 㪠��⥫� �� ��㬥�� ���ᨢ
//         nDim    - ����� ।����㥬�� ������� (�� ��࠭�)
//         nElem   - ����� ⥪�饩 ��ப� � ���ᨢ�
//         nKey    - ��� ����⮩ ������
//         TestGet - ��� �㭪樨 ।���஢����
// fl_ins_del - ���ᨢ �� ��� �����᪨� ����稭, ࠧ����� ���
//              �������� � ०��� ।���஢����:
//              1) ��⠢�� ��ப,
//              2) 㤠����� ��ப,
//              3) ���������� ��ப � �����
// arr_Browse - ���ᨢ 㬮�砭�� ��� TBrowse:
//              1 - oBrowse:headSep
//              2 - oBrowse:colSep
//              3 - oBrowse:footSep
//              4 - oBrowse:colorSpec
//              5 - ��ப� ᨬ�����, �� ��ࠡ��뢠���� �⠭����� ��ࠧ��
//                  �� ���᪥ �� ��砫�� �㪢��
// func_del   - �㭪��, �஢������, ࠧ�蠥��� �� 㤠����� ������ ��ப�,
//              � ��� � ��।����� 3 ��ࠬ���:
//              1 - ��� 1 ��� 2 (1 - �஢�ઠ �� �����⨬���� 㤠�����,
//                                 2 - ����⢨� ��᫥ 㤠�����)
//              2 - ⥪��� "��ப�" ��㬥୮�� ���ᨢ�
//              3 - ����� ⥪�饩 ��ப�
// func_step  - �㭪��, ��뢠���� �� ������ 蠣� TBrowse (�ᮢ����)
//              � ��� � ��।����� 3 ��ࠬ���:
//              1 - ⥪��� "��ப�" ��㬥୮�� ���ᨢ�
//              2 - ����� ⥪�饩 ��ப�
//              3 - ����� ⥪�饩 �������
LOCAL lCont := .T., nKey, buf, t_color := setcolor()
Local oBrowse, COUNT, i, j, NSTR, fl_edit := (VALTYPE(bGetFunc) == "B"),;
      fl_mouse := .f., x_mouse := 0, y_mouse := 0, km, cType,;
      buf1 := save_maxrow(), tmp, oColumn, is_append := .f., fl_rbrd := .t.,;
      color_find, static_find := "", buf_static, len_static,;
      nsec := seconds(), period := 300
DEFAULT nI TO 1, fl_noclear TO .f., mfunction TO "", ;
        fl_ins_del TO {.t.,.t.,.t.}, func_del TO "",;
        arr_Browse TO {'���',' � ','���',,"*+-"}, func_step TO ""
if len(arr_Browse) < 5
  asize(arr_Browse,5)
endif
DEFAULT arr_Browse[1] TO '���',;
        arr_Browse[2] TO ' � ',;
        arr_Browse[3] TO '���',;
        arr_Browse[5] TO '*+-'

Private last_k := 2, parr := arr, nInd := nI, _num_col
if mcolor != NIL
  setcolor(mcolor)
endif
if !empty(func_step) .and. "(" $ func_step
  func_step := beforatnum("(",func_step)
endif
if (COUNT := len(arr)) == 0
  return 0
endif
nInd := if(nInd <= 0, 1, if(nInd > COUNT, COUNT, nInd))
buf := box_shadow(nTop,nLeft,nBottom,nRight,mcolor,titul,titul_color)
oBrowse:= TBrowseNew(nTop+1, nLeft+1, nBottom, nRight-1)
oBrowse:headSep := arr_Browse[1]
oBrowse:colSep  := arr_Browse[2]
oBrowse:footSep := arr_Browse[3]
if arr_Browse[4] != NIL
  oBrowse:colorSpec := arr_Browse[4]
endif
color_find := color_find(oBrowse:colorSpec)     // =============
buf_static := save_box(nTop,nLeft,nTop,nRight)  // =============
len_static := nRight - nLeft - 3                // =============
if valtype(mPicture) == "A"
  asize(mPicture, len(arr1))
endif
for i := 1 to len(arr1)
  tmp := "parr[nInd,"+lstr(arr1[i,1])+"]"
  if valtype(mPicture) == "A" .and. valtype(mPicture[i]) == "A"
    tmp := "STR("+tmp+","+lstr(mPicture[i,1])+","+lstr(mPicture[i,2])+")"
  endif
  oColumn := TBColumnNew(arr1[i,2], COMPILE(tmp))
  if len(arr1[i]) > 2 .and. valtype(arr1[i,3])=="B" .and. arr_Browse[4] != NIL
    oColumn:colorBlock := arr1[i,3]
  else
    oColumn:colorBlock := {|| NIL }
  endif
  oBrowse:addColumn(oColumn)
next
NSTR := oBrowse:rowCount
nTop += nBottom-nTop-NSTR-1
@ nTop, nLeft  say "�"
@ nTop, nRight say "�"
if fl_edit
  fl_rbrd := (!fl_ins_del[1] .and. !fl_ins_del[2] .and. !fl_ins_del[3])
endif
if fl_rbrd .and. NSTR < COUNT .and. NSTR > 4
  @ nTop+1,nRight    say chr(30)
  @ nBottom-1,nRight say chr(31)
  for i := nTop+2 to nBottom-2
    @ i,nRight say chr(176)
  next
  @ nTop+last_k,nRight say chr(8)
else
  fl_rbrd := .f.
endif
oBrowse:goTopBlock := ;
     {|| nInd := 1, right_side(fl_rbrd, nInd, COUNT, nTop, nRight, NSTR) }
oBrowse:goBottomBlock := ;
     {|| nInd := COUNT, right_side(fl_rbrd, nInd, COUNT, nTop, nRight, NSTR) }
oBrowse:skipBlock := ;
     { |nSkip, nVar|  nVar := nInd,;
        nInd := IF(nSkip > 0, MIN(COUNT,nInd+nSkip), MAX(1,nInd+nSkip)),;
        right_side(fl_rbrd, nInd, COUNT, nTop, nRight, NSTR), nInd - nVar }
if fl_edit
  tmp := "^<Esc>^-��室"
  if fl_ins_del[1]
    tmp += "; ^<Ins>^-��⠢�� ��ப�"
  endif
  if fl_ins_del[2]
    tmp += "; ^<Del>^-㤠����� ��ப�"
  endif
  if fl_ins_del[3]
    tmp += "; ^<>^-�������� � �����"
  endif
  if len(tmp) < 57
    tmp += "; ^<Enter>^-।���஢����"
  elseif len(tmp) < 64
    tmp += "; ^<Enter>^-।���."
  endif
  status_key(tmp)
else
  fl_mouse := SETPOSMOUSE()
endif
if (i := nInd) > COUNT-NSTR
  oBrowse:goBottom()
  for tmp := COUNT-1 TO i STEP -1
    oBrowse:up()
  next
endif
DO WHILE lCont
  if nKey != 0
    oBrowse:refreshCurrent()  // ��⠭�������� ⥪�饩 ��ப� �⠭����� 梥�
    oBrowse:forcestable()  // �⠡�������
    if !fl_edit .and. oBrowse:colCount > 1
      // �뤥����� 梥⮬ �ᥩ ⥪�饩 ��ப�
      i := 2
      if arr_Browse[4] != NIL
        tmp := (oBrowse:getColumn(1)):colorBlock
        i := eval(tmp)
        if valtype(i) == "A"
          i := i[2]
        else
          i := 2
        endif
      endif
      oBrowse:colorRect({oBrowse:rowPos,1,oBrowse:rowPos,oBrowse:colCount},{i,i})
      oBrowse:forcestable()  // �⠡�������
    endif
    if !empty(func_step)
      _num_col := oBrowse:colPos
      tmp := &(func_step+"(parr[nInd],nInd,_num_col)")
    endif
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
              keyboard CHR(K_SH_TAB)  //  keysend(CHR(0)+CHR(15),.t.) // KS_SH_TAB
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
      if nKey == 0 .and. arr_mouse != NIL
        if (i := ascan(arr_mouse, {|x| between(x_mouse,x[2],x[4]) .and. ;
                                       between(y_mouse,x[1],x[3])})) > 0
          clear_mouse()
          //aeval(arr_mouse[i,5], {|x| keysend(x,.t.)})
        endif
      endif
    endif
  endif*/
  if nKey == 0
    nKey := INKEYTRAP()
  endif
  if nKey == 0
    if period > 0 .and. seconds() - nsec > period
      // �᫨ �� �ண��� ���������� [period] ᥪ., � ��� �� �㭪樨
      nKey := K_ESC
    endif
  else
    nsec := seconds()
  endif
  if nKey != 0 .and. valtype(arr[1,arr1[1,1]]) == "C" ;      // =============
        .and. !fl_edit .and. ;
     !((((len(static_find) > 0 .and. nKey == 32) .or. between(nKey,33,255)) ;
        .and. !(chr(nKey) $ arr_Browse[5])) .or. nKey == K_BS) // =============
    static_find := "" ; rest_box(buf_static)                   // =============
  endif                                                        // =============
  DO CASE
    CASE nKey == K_UP .or. nKey == K_SH_TAB
      if fl_edit .and. fl_ins_del[3] .and. nInd == COUNT ;
                   .and. is_append  // 㤠���� ��᫥���� ������ ��ப�
        asize(arr, COUNT-1) ; COUNT--
        if nInd > COUNT ; nInd := COUNT ; endif
        oBrowse:refreshAll()
        is_append := .f.
      else
        FT_MHIDECRS(fl_mouse) ; oBrowse:up()
      endif
    CASE nKey == K_DOWN .or. nKey == K_TAB
      if fl_edit .and. fl_ins_del[3] .and. nInd == COUNT ;
                          .and. !is_append  // ���������� ��ப� � �����
        asize(arr, COUNT+1) ; COUNT++
        arr[nInd+1] := array(len(arr[nInd]))
        for i := 1 to len(arr[nInd])
          cType := VALTYPE(arr[nInd,i])
          do case
            case cType == "C"
              arr[nInd+1,i] := space(len(arr[nInd,i]))
            case cType == "N"
              arr[nInd+1,i] := 0
            case cType == "L"
              arr[nInd+1,i] := .f.
            case cType == "D"
              arr[nInd+1,i] := ctod("")
          endcase
        next
        nInd++
        EVAL(bGetFunc, oBrowse, arr, oBrowse:colPos, nInd, K_DOWN )
        oBrowse:goTop() ; oBrowse:goBottom() ; oBrowse:refreshAll()
        is_append := .t.
      else
        FT_MHIDECRS(fl_mouse) ; oBrowse:down()
      endif
    CASE nKey == K_PGUP
      FT_MHIDECRS(fl_mouse) ; oBrowse:pageUp()
    CASE nKey == K_PGDN
      FT_MHIDECRS(fl_mouse) ; oBrowse:pageDown()
    CASE nKey == K_HOME .or. nKey == K_CTRL_PGUP .or. nKey == K_CTRL_HOME
      FT_MHIDECRS(fl_mouse) ; oBrowse:goTop()
    CASE nKey == K_END .or. nKey == K_CTRL_PGDN .or. nKey == K_CTRL_END
      FT_MHIDECRS(fl_mouse) ; oBrowse:goBottom()
    CASE nKey == K_ENTER .and. !fl_edit
      lCont := .F.
    CASE nKey == K_ESC
      lCont := .F.
    CASE nKey != 0 .and. ;
        ((((len(static_find) > 0 .and. nKey == 32) .or. between(nKey,33,255)) ;
               .and. !(chr(nKey) $ arr_Browse[5])) .or. nKey == K_BS) ;
                      .and. valtype(arr[1,arr1[1,1]]) == "C" .and. !fl_edit
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
        i := arr1[1,1]
        if (i := ascan(arr, {|x| static_find <= left(upper(x[i]),tmp)} )) > 0
          if i < COUNT-NSTR+1
            oBrowse:goTop()
            nInd := i
            oBrowse:refreshAll()
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
    CASE nKey != 0 .and. !empty(mfunction)
      FT_MHIDECRS(fl_mouse)
      tmp := mfunction+"("+lstr(nKey)+","+lstr(nInd)+")"
      if (i := &tmp) == 0         // �㭪�� ������ �������� 0 ���
        COUNT := len(arr)         // ���������� TBrowse, ���� -1 (��祣�)
        if nInd > COUNT
          nInd := COUNT
        endif
        oBrowse:refreshAll()
      elseif i == 1               // ��� 1 ��� ��室� �� ����
        lCont := .f.
      endif
      nKey := 256
// ����� ��������������
    CASE nKey == K_INS .and. fl_ins_del[1] // ��⠢�� ��ப�
      if fl_edit
        asize(arr, COUNT+1) ; Inc(COUNT)
        ains(arr, nInd) ; arr[nInd] := array(len(arr[nInd+1]))
        for i := 1 to len(arr[nInd+1])
          cType := VALTYPE(arr[nInd+1,i])
          do case
            case cType == "C"
              arr[nInd,i] := space(len(arr[nInd+1,i]))
            case cType == "N"
              arr[nInd,i] := 0
            case cType == "L"
              arr[nInd,i] := .f.
            case cType == "D"
              arr[nInd,i] := ctod("")
          endcase
        next
        EVAL(bGetFunc, oBrowse, arr, oBrowse:colPos, nInd, K_INS )
        oBrowse:refreshAll()
      endif
    CASE nKey == K_DEL .and. fl_ins_del[2]  //  㤠����� ��ப�
      if fl_edit .and. ver_dostup(.f.)  //  㤠����� ��ப�
        if !(tmp := empty(func_del))
          tmp := &(func_del+"(1,parr[nInd],nInd)")
        endif
        if tmp .and. f_Esc_Enter(2)
          if !empty(func_del)
            tmp := &(func_del+"(2,parr[nInd],nInd)")
          endif
          if COUNT == 1
            for i := 1 to len(arr[nInd])
              cType := VALTYPE(arr[nInd,i])
              do case
                case cType == "C"
                  arr[nInd,i] := space(len(arr[nInd,i]))
                case cType == "N"
                  arr[nInd,i] := 0
                case cType == "L"
                  arr[nInd,i] := .f.
                case cType == "D"
                  arr[nInd,i] := ctod("")
              endcase
            next
          else
            adel(arr, nInd)
            asize(arr, COUNT-1) ; Dec(COUNT)
            if nInd > COUNT ; nInd := COUNT ; endif
          endif
          EVAL(bGetFunc, oBrowse, arr, oBrowse:colPos, nInd, K_DEL )
          oBrowse:refreshAll()
        endif
      endif
    CASE (nKey == K_SH_F2 .or. nKey == 256+K_SH_F2) .and. fl_edit
      tmp := arr1[oBrowse:colPos,1]
      if valtype(arr[nInd,tmp]) == "C"
        arr[nInd,tmp] := padr(retcalcval("C"), len(arr[nInd,tmp]))
        keyboard chr(K_ENTER)
      elseif valtype(arr[nInd,tmp]) == "N"
        arr[nInd,tmp] := retcalcval("N")
        if valtype(mPicture)=="A" .and. valtype(mPicture[oBrowse:colPos])=="A"
          arr[nInd,tmp] := round(arr[nInd,tmp], mPicture[oBrowse:colPos,2])
        endif
        keyboard chr(K_ENTER)
      endif
    CASE nKey != 0 .and. fl_edit  // ।���஢���� ������� ���ᨢ�
      IF between(nKey, 33, 249) .AND. CHR(nKey) != ";"
        KEYBOARD CHR(nKey)
      ENDIF
      if EVAL(bGetFunc, oBrowse, arr, oBrowse:colPos, nInd, nKey)
        is_append := .f.
      endif
      COUNT := len(arr) // �� �� ��砩, �᫨ ��������� ࠧ��� ���ᨢ�
  ENDCASE
ENDDO
if fl_mouse
  clear_mouse()
  FT_MHIDECRS()
endif
setcolor(t_color)
rest_box(buf1)
if !fl_noclear
  rest_box(buf)
endif
return if(nKey == K_ESC, 0, nInd)
