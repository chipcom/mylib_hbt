#include "function.ch"
#include "edit_spr.ch"
#include "inkey.ch"
#include "getexit.ch"

*
* !!! �᫨ � �� ��� ���� "kod", � ��। �맮��� �㭪樨 popup_edit
* ���� ��।����� private-��६����� "max_dop_rec" (���ᨬ��쭮� ���-�� ����ᥩ)
*

// ���⨪��쭮� ���� �� ᮤ�ন���� "���⮩" ���� ������
//                                   (� ������������ ।���஢����)
FUNCTION popup_edit
PARAMETERS __name_b, __t, __mleft, __b, __mkod, __regim_edit, __col, ;
           __func_del, __s_error, __uslovie, __blk, __mpict, __top_bot, ;
           __tit, __tit_color
// __name_b  - ��� ���� ������ (��易⥫�� ���� - kod � name)
//                             (��� ⮫쪮 ���� name)
// __t       - ��ப� ���孥�� ������ 㣫�
// __mleft   - ������� ���孥�� ������ 㣫�
// __b       - ������ ��ப�
// __mkod    - ��� �� �室�
// __regim_edit - ०�� ࠡ���
// PE_EDIT       1 // (��� �� 㬮�砭��) - ����������, ।-�� � 㤠�����
// PE_APP_SPACE  2 // ���������� � ������ ���� � �� �஡��� ������ {0,""}
// PE_APP      2.5 // ���������� � ������ ����
// PE_SPACE      3 // ������ ���� � �� �஡��� ������ {0,""}
//                 // (� ०��� ।���஢���� f_edit_spr)
// PE_RETURN     4 // ���� ������ ���� (��� �� popup)
// PE_VIEW       5 // ��ᬮ��
// __col      - 梥� (��� ��� ��ப�)
// __func_del - ������������ �㭪樨 ��� �஢�ન �����⨬��� 㤠�����
//            (� ��� ��� ��ࠬ��� ���뫠���� �஢��塞� ���)
//            (������ .t. � ��砥 ࠧ�襭�� 㤠�����, ���� .f.)
// __s_error  - ᮮ�饭�� �� �訡�� �� ������⢨� ����室���� ����ᥩ
// __uslovie  - ���� FOR-�᫮��� ��� ���᪠ � �� (�᫨ ����� ����� ����)
// __blk      - ���� ���� ��� ����� ��㣨� ����� (�᫨ ����� ����� ����)
// __mpict    - 蠡��� PICTURE ��� ����� ������ � ���� name
// __top_bot  - ���९��� ������ ��� ������ �࠭��� ����
//              �����᪮� ���祭�� (�� 㬮�砭�� .t. - ������)
// __tit, __tit_color - ��������� � ��� 梥�
PRIVATE n_el, mch, tmp, __mright, Mcolor := setcolor(), __buf, s_msg,;
        ch, ch_kod, ll, __buf1 := save_maxrow(), __tmp_select := select(),;
        __pole_kod, _len_pole_kod, __fl_found, __last_oper
DEFAULT __regim_edit TO PE_EDIT, __col TO color0, __func_del TO "", ;
        __mpict TO "", __top_bot TO .t.
mywait()
if !R_Use(__name_b)
  if __tmp_select > 0
    select (__tmp_select)
  endif
  rest_box(__buf1) ; return NIL
endif
if __regim_edit >= PE_SPACE
  tmp := 0
  dbeval({|| tmp++}, __uslovie)
  if tmp == 0
    use
    if __s_error != NIL
      func_error(3,__s_error)
    endif
    if __tmp_select > 0
      select (__tmp_select)
    endif
    rest_box(__buf1) ; return NIL
  endif
  if __top_bot
    __b := __t+tmp+1
  else
    __t := __b-tmp-1
  endif
endif
if (__pole_kod := ( fieldnum("KOD") > 0 ))
  _len_pole_kod := fieldsize(fieldnum("KOD"))
endif
ll := fieldsize(fieldnum("NAME"))
use
if ll <= 0
  func_error("� ���� ������ ��� ���� <NAME>")
  if __tmp_select > 0
    select (__tmp_select)
  endif
  rest_box(__buf1) ; return NIL
endif
if __mleft < 0
  __mleft := 0
endif
__mright := __mleft + ll + 3
if __mright > maxcol()-2
  __mright := maxcol()-2 ; __mleft := maxcol() - ll - 5
  if __mleft < 0
    __mleft := 0
  endif
endif
if __mright - __mleft < ll + 3
  __mpict += "@S"+lstr(__mright - __mleft - 3)
endif
if __t < 0
  __t := 0
endif
if __b > maxrow()-2
  __b := maxrow()-2
endif
__buf := save_box(__t,__mleft,__b+1,__mright+2)
do case
  case __regim_edit == PE_EDIT
    s_msg := "<Esc> - ��室; <Enter> - ।���஢����; <Delete> - 㤠�����; <Ins> - ����������"
  case __regim_edit == PE_APP_SPACE
    s_msg := "<Esc> - ��室;  <Enter> - �롮�;  <�஡��> - ���⪠ ����;  <Ins> - ����������"
  case __regim_edit == PE_APP
    s_msg := "<Esc> - ��室;  <Enter> - �롮�;  <Ins> - ����������"
  case __regim_edit == PE_SPACE
    s_msg := "<Esc> - ��室;  <Enter> - �롮�;  <�஡��> - ���⪠ ����"
  case __regim_edit == PE_RETURN
    s_msg := "<Esc> - ��室;  <Enter> - �롮�"
  case __regim_edit == PE_VIEW
    s_msg := "<Esc> - ��室"
endcase
do while .t.
  mywait()
  ch := {} ; ch_kod := {}
  if !R_Use(__name_b)
    mch := 0
    exit
  endif
  if __pole_kod
    dbeval({|| aadd(ch,FIELD->name+str(FIELD->kod))}, __uslovie)
  else
    dbeval({|| aadd(ch,FIELD->name+str( recno() ) ) }, __uslovie)
  endif
  use
  asort(ch,,,{|x,y| upper(x) < upper(y) } )
  aeval(ch, {|x,i| aadd(ch_kod,int(val(substr(x,ll+1)))), ch[i] := left(ch[i],ll)})
  n_el := IF(__mkod == NIL, 1, ascan(ch_kod,__mkod))
  stat_msg(s_msg,.f.)
  mark_keys({"<Esc>","<Enter>","<Delete>","<�஡��>","<Ins>"})
  __last_oper := 0
  if !(__fl_found := (len(ch_kod) > 0)) .and. __regim_edit < PE_SPACE
    ch_kod := {1} ; ch := {space(ll)}
    keyboard chr(K_INS)
  endif
  mch := popup(__t,__mleft,__b,__mright,ch,n_el,__col,.t.,"i1_func",;
                                     __regim_edit,__tit,__tit_color)
  if mch == 0 .or. !__fl_found .or. ;
                      (__regim_edit != PE_EDIT .and. __last_oper != K_INS)
    exit
  endif
enddo
rest_box(__buf) ; rest_box(__buf1)
SETCOLOR(Mcolor)
if __tmp_select > 0
  select (__tmp_select)
endif
RETURN if(mch == 0 .or. !__fl_found, NIL, ;
                 if(lastkey() == K_SPACE, {0,""}, {ch_kod[mch], ch[mch]}))

*

*****
FUNCTION i1_func(keystroke, sel)
Local srow := row(), scol := col(), i, j, tmp, fl_exit := .f.,;
      tmp_color := setcolor(), buf, buf24, f_dostup := .t., fl,;
      s_msg := "^<Esc>^ - ��室 ��� �����;  ^<Enter>^ - ���⢥ত���� �����"
DO CASE
  CASE keystroke == K_INS .and. __regim_edit < PE_SPACE
    i := 0 ; fl := .t.
    if __pole_kod // ��� �� � ����� KOD
      i := int(val(replicate("9",_len_pole_kod)))
    elseif type("max_dop_rec") == "N"  // ��� �� ⮫쪮 � ����� NAME
      i := max_dop_rec
    endif
    if i > 0 .and. R_Use(__name_b,,,,,.t.)
      j := 0
      dbeval({|| ++j } )
      Use
      if j >= i
        fl := func_error(4,"������⢮ ����ᥩ ���⨣�� "+lstr(i)+". ���������� ����饭�!")
      endif
    endif
    if fl .and. ver_dostup(.t.)
      buf24 := save_maxrow()
      buf := box_shadow(__b-2,__mleft,__b,__mright,cDataCScr,;
                       "����������",cDataCSay)
      status_key(s_msg)
      tmp := space(ll)
      if type("_PE_str_ins") == "C" .and. !empty(_PE_str_ins)
        tmp := padr(_PE_str_ins,ll)
        keyboard chr(K_END)
      endif
      setcolor(cDataCGet)
      @ __b-1,__mleft+2 get tmp picture __mpict
      myread({"confirm"})
      if lastkey() != K_ESC .and. !empty(tmp)
        if G_Use(__name_b)
          if (f_dostup := AddRecN())
            __mkod := recno()
            if __pole_kod
              replace kod with __mkod
            endif
            if __blk != NIL
              eval(__blk)
            endif
            __last_oper := K_INS
            fl_exit := __fl_found := .t.
            replace name with tmp
          endif
          use
        endif
      endif
      rest_box(buf) ; rest_box(buf24)
    endif
    if !__fl_found ; fl_exit := .t. ; endif
  CASE keystroke == K_ENTER
    if ver_dostup(.t.)
      buf24 := save_maxrow()
      status_key(s_msg)
      tmp := ch[sel]
      @ srow,__mleft+2 get tmp picture __mpict
      myread({"confirm"})
      if lastkey() != K_ESC .and. !empty(tmp)
        if G_Use(__name_b)
          __mkod := ch_kod[sel]
          if __pole_kod
            locate for FIELD->kod == __mkod
          else
            goto (__mkod)
          endif
          f_dostup := G_RLock()
          if f_dostup
            fl_exit := .t.
            replace name with tmp
            ch[sel] := tmp
          endif
          use
        endif
      endif
      rest_box(buf24)
    endif
  CASE keystroke == K_DEL .and. __regim_edit == PE_EDIT
    if ver_dostup(.f.)
      if !(i := empty(__func_del))
        i := &(__func_del+"("+lstr(ch_kod[sel])+")")
      endif
      if i .and. f_Esc_Enter(2)
        if G_Use(__name_b)
          goto (ch_kod[sel])
          DeleteRec(.t.)
          use
          adel(ch_kod, sel) ; asize(ch_kod, len(ch_kod)-1)
          adel(ch, sel)     ; asize(ch, len(ch)-1)
          fl_exit := .t.
        endif
      endif
    endif
ENDCASE
setcolor(tmp_color)
RETURN if(fl_exit, 1, 0)
