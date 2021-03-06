#include "function.ch"
#include "inkey.ch"

*****
FUNCTION Alpha_Browse( nTop, nLeft, nBottom, nRight, ;
                       mfunction, mcolor, titul, titul_color, ;
                       fl_index, fl_noclear, arr_block, ;
                       m1function, n_func, arr_mouse, arr_Browse )
// nTop, nLeft, nBottom, nRight - ������� ����
// mfunction - �㭪�� ��� ��⠢����� �⮫�殢 TBrowse
// mcolor - 梥� TBrowse
// titul, titul_color - ��������� � ��� 梥�
// fl_index - ���.����稭�, 㪠�뢠���, �ந�����஢��� �� �� �� ��䠢���
// fl_noclear - ���.����稭�, 㪠�뢠���, ����⠭�������� �� ��࠭
// arr_block - ���ᨢ ������ ����
//             1 - ���� ���� Top
//             2 - ���� ���� Bottom
//             3 - ���� ���� Skip
//             4 - ��ப�, ������塞�� � ��砫� FIND ��� ���᪠ �� ���.�㪢�
//             5 - �᫮��� ��� �஢�ન ���᪠ �� ��砫쭮� �㪢�
//                 (�� ��ன ��ࠬ��� � �㭪樨 ����� ���� Skip)
// m1function - �㭪��, ��뢠���� �� ������ 蠣� TBrowse (�ᮢ����)
// n_func - �㭪��, ��뢠���� �� ����⨨ ��।������� ������
// arr_mouse - ���ᨢ �����⥩ ��� ���
// arr_Browse - ���ᨢ ��㣨� ��ࠬ��஢ ��� TBrowse:
//              1 - oBrowse:headSep
//              2 - oBrowse:colSep
//              3 - oBrowse:footSep
//              4 - oBrowse:colorSpec
//              5 - .t. ��� .f. (�� 㬮�砭�� .f.) - � ��砥 .t. ����頥�
//                  ��室 �� <Enter> (<Enter> ��ࠡ��뢠���� �-��� n_func)
//              6 - "�६� �� ࠧ���" � ᥪ㭤��, �� 㬮�砭�� - 60 ᥪ.
//                  �᫨ = 0, � ��� ᠬ����⥫쭮�� ��室� �� Browse
//              7 - ��ப� ᨬ�����, �� ��ࠡ��뢠���� �⠭����� ��ࠧ��
//                  �� ���᪥ �� ��砫�� �㪢��
//              8 - .t. ��� .f. (�� 㬮�砭�� .f.) - � ��砥 .t. �뢮���
//                  �ࠢ� �� ⠡���� ������ �ப��⪨ - �� 㬥�⭮, �᫨
//                  DBF-䠩� �� �ந�����஢�� � ��࠭�� �����஢��
LOCAL lCont := .T., nKey := 256, buf := savescreen(), ;
      t_color := setcolor(), i, j, nsec := seconds(), ;
      fl_mouse, x_mouse := 0, y_mouse := 0, km, fl_rbrd := .f., COUNT, NSTR,;
      color_find, static_find := "", buf_static, len_static
Private oBrowse, tmp, pr1, pr2, pc1, pc2
DEFAULT fl_index TO .t., fl_noclear TO .f., mfunction TO "", ;
        m1function TO "", n_func TO "", ;
        arr_Browse TO {'���',' � ','���',NIL,.f.,60,"*+-",.f.}
if len(arr_Browse) < 8
  asize(arr_Browse,8)
endif
DEFAULT arr_Browse[1] TO '���',;
        arr_Browse[2] TO ' � ',;
        arr_Browse[3] TO '���',;
        arr_Browse[5] TO .f.  ,;
        arr_Browse[6] TO 60   ,;
        arr_Browse[7] TO "*+-",;
        arr_Browse[8] TO .f.
if !empty(m1function) .and. !("(" $ m1function)
  m1function += "()"
endif
if !empty(n_func) .and. "(" $ n_func
  n_func := beforatnum("(",n_func)
endif
if mcolor != NIL
  setcolor(mcolor)
endif
if !arr_Browse[5]  // �᫨ �� ।����㥬
  status_key("^^"+if(fl_index," ��� ��砫쭠� �㪢�","")+;
             " - ��ᬮ��;  ^<Esc>^ - ��室;  ^<Enter>^ - �롮�")
endif
pr1 := nTop; pr2 := nBottom; pc1 := nLeft; pc2 := nRight
box_shadow(nTop,nLeft,nBottom,nRight,mcolor,titul,titul_color)
// �������� ������ TBrowse ��ꥪ�
oBrowse := TBrowseDB(nTop+1, nLeft+1, nBottom, nRight-1)
//  ������� ��⠭���� TBrowse
oBrowse:headSep := arr_Browse[1]
oBrowse:colSep  := arr_Browse[2]
oBrowse:footSep := arr_Browse[3]
if arr_Browse[4] != NIL
  oBrowse:colorSpec := arr_Browse[4]
endif
nKey := &(mfunction+"(oBrowse)")   // ���������� �⮫�殢
if arr_block != NIL .and. valtype(arr_block) == "A"
  oBrowse:goTopBlock := arr_block[1]
  oBrowse:goBottomBlock := arr_block[2]
  oBrowse:skipBlock := arr_block[3]
endif
color_find := color_find(oBrowse:colorSpec)     // =============
buf_static := save_box(nTop,nLeft,nTop,nRight)  // =============
len_static := nRight - nLeft - 3                // =============
nTop += nBottom-nTop-oBrowse:rowCount-1
@ nTop, nLeft  say "�"
@ nTop, nRight say "�"
if arr_Browse[8]
  NSTR := oBrowse:rowCount
  COUNT := lastrec()
  if NSTR < COUNT .and. NSTR > 4 .and. ;
                 !(arr_block != NIL .and. valtype(arr_block) == "A")
    fl_rbrd := .t.
    Private last_k := 2
    @ nTop+1,nRight    say chr(30)
    @ nBottom-1,nRight say chr(31)
    for i := nTop+2 to nBottom-2
      @ i,nRight say chr(176)
    next
    @ nTop+last_k,nRight say chr(8)
    oBrowse:goTopBlock := ;
         {|| dbGoTop(), right_side(fl_rbrd, recno(), COUNT, nTop, nRight, NSTR) }
    oBrowse:goBottomBlock := ;
         {|| dbGoBottom(), right_side(fl_rbrd, recno(), COUNT, nTop, nRight, NSTR) }
    oBrowse:skipBlock := ;
         { |nSkip,n| n:=SkipPointer(nSkip,".t."), right_side(fl_rbrd, recno(), COUNT, nTop, nRight, NSTR), n }
  endif
endif
fl_mouse := SETPOSMOUSE()
if type("alpha_1_rect") != "L"
  Private alpha_1_rect := .f.
endif
DO WHILE lCont   // ������ 横� ��ᬮ��
  if nKey != 0
    oBrowse:refreshCurrent()  // ��⠭�������� ⥪�饩 ��ப� �⠭����� 梥�
    oBrowse:forcestable()  // �⠡�������
    if oBrowse:colCount > 1 .and. !alpha_1_rect
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
    if !empty(m1function) ; tmp := &m1function ; endif
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
              keyboard chr(K_TAB)  //  keysend(CHR(9)+CHR(15),.t.)  // KS_TAB
            next
          else
            for j := 1 to i-y_mouse
              keyboard chr(K_SH_TAB)  //  keysend(CHR(0)+CHR(15),.t.) // KS_SH_TAB
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
  if fl_index .and. nKey != 0 .and. ;                          // =============
     !((((len(static_find) > 0 .and. nKey == 32) .or. between(nKey,33,255)) ;
        .and. !(chr(nKey) $ arr_Browse[7])) .or. nKey == K_BS) // =============
    static_find := "" ; rest_box(buf_static)                   // =============
  endif                                                        // =============
  if arr_Browse[6] > 0
    if nKey == 0
      if seconds() - nsec > arr_Browse[6]   // �᫨ �� �ண��� ����������,
        keyboard chr(K_ESC)                 // � ��� �� �㭪樨
      endif
    else
      nsec := seconds()
    endif
  endif
  DO CASE  // ��ࠡ�⪠ ������� ������
    CASE nKey == K_LEFT .and. alpha_1_rect
      FT_MHIDECRS(fl_mouse) ; oBrowse:left()
    CASE nKey == K_RIGHT .and. alpha_1_rect
      FT_MHIDECRS(fl_mouse) ; oBrowse:right()
    CASE nKey == K_UP .or. nKey == K_SH_TAB
      FT_MHIDECRS(fl_mouse) ; oBrowse:up()
    CASE nKey == K_DOWN .or. nKey == K_TAB
      FT_MHIDECRS(fl_mouse) ; oBrowse:down()
    CASE nKey == K_PGUP ;  FT_MHIDECRS(fl_mouse) ; oBrowse:pageUp()
    CASE nKey == K_PGDN ;  FT_MHIDECRS(fl_mouse) ; oBrowse:pageDown()
    CASE nKey == K_HOME .or. nKey == K_CTRL_PGUP .or. nKey == K_CTRL_HOME
      FT_MHIDECRS(fl_mouse) ; oBrowse:goTop()
    CASE nKey == K_END .or. nKey == K_CTRL_PGDN .or. nKey == K_CTRL_END
      FT_MHIDECRS(fl_mouse) ; oBrowse:goBottom()
    CASE nKey == K_ESC .OR. (nKey == K_ENTER .and. !arr_Browse[5])
      lCont := .F.
    CASE fl_index .and. nKey != 0 .and. indexord() > 0 .and. ;
          ((((len(static_find) > 0 .and. nKey == 32) .or. between(nKey,33,255)) ;
             .and. !(chr(nKey) $ arr_Browse[7])) .or. nKey == K_BS)
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
        if arr_block != NIL .and. valtype(arr_block) == "A" ;
                            .and. len(arr_block) > 3
          tmp := arr_block[4] + static_find
        else
          tmp := static_find
        endif
        dbseek(tmp,.t.)
        if arr_block != NIL .and. valtype(arr_block) == "A" ;
                            .and. len(arr_block) > 4 .and. !&(arr_block[5])
          DBSKIP(-1)
        ENDIF
        IF EOF()
          oBrowse:goBottom()
        ELSE
          oBrowse:refreshAll()
        ENDIF
      endif
    CASE nKey != 0 .and. !empty(n_func)
      FT_MHIDECRS(fl_mouse)
      if (i := &(n_func+"("+lstr(nKey)+",oBrowse)")) == 0
        oBrowse:refreshAll()   // �㭪�� ������ �������� 0 ���
      elseif i == 1            // ���������� TBrowse, ���� -1 (��祣�)
        lCont := .f.           // ��� 1 ��� ��室� �� TBrowse
      endif
      nsec := seconds()
      nKey := 256
  ENDCASE
ENDDO
if fl_mouse
  clear_mouse()
  FT_MHIDECRS()
endif
setcolor(t_color)
if !fl_noclear
  restscreen(buf)
endif
RETURN (nKey != K_ESC)
