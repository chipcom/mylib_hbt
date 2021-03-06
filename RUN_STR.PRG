#include "inkey.ch"
#include "function.ch"

***** 27.03.17 ������ ��ப�
Function RunStr(CString,NRow,NCol1,NCol2,CColor,NInterval,NDelay)
//  CString   - ᮤ�ঠ��� ����饩 ��ப�
//  NRow      - ����� ��ப�
//  NCol1     - ����� �࠭�� (�� 㬮�砭�� 0)
//  NCol2     - �ࠢ�� �࠭�� (�� 㬮�砭�� 80)
//  CColor    - 梥� ��� �뢮�� ��ப� (�� 㬮�砭�� ⥪�騩 梥�)
//  NInterval - ᪮���� ᤢ��� � �����ᥪ㭤�� (�� 㬮�砭�� 254 ��)
//  NDelay    - �६� �������� � ᥪ㭤�� (�� 㬮�砭�� 0 - ��᪮��筮���)
Local len_string, width, tmp_color := setcolor(), s, i := 1, j, k,;
      fl_exit := .f., fl_delay, t_delay := 0, buf
DEFAULT NCol1 TO 0, NCol2 TO maxcol(), NInterval TO 112, NDelay TO 0
CString := alltrim(CString)
width := NCol2 - NCol1 + 1
if (len_string := len(CString)) < width
  CString := padr(CString,width)
else
  CString += "   "
endif
len_string := len(CString)
setcursor(0)
if CColor != NIL
  setcolor(CColor)
endif
@ NRow,NCol1 say space(width)
fl_delay := (NDelay > 0)
do while if(fl_delay, (NDelay > t_delay), .t.)
  if inkey() != 0
    fl_exit := .t.
    exit
  endif
  buf := savescreen(NRow,NCol1+1,NRow,NCol2)
  restscreen(NRow,NCol1,NRow,NCol2-1,buf)
  @ NRow,NCol2 say substr(CString,i,1)
  i++
  if i > len_string ; i := 1 ; endif
  if fl_delay
    t_delay += (NInterval/1000)
  endif
  Millisec(NInterval)
enddo
setcolor(tmp_color)
return if(fl_exit, lastkey(), 27)  // ������ ��᫥���� ����⮩ ������

***** 27.03.17 �뢮� ��אַ㣮�쭨�� � ᮮ�饭��� (��᫥���� ��ப� - ������)
FUNCTION N_MESSAGE(cLine,;      // ���ᨢ ��ப (���ᨬ� 6 ��ப)
                   arr_dop,;    // �������⥫�� ���ᨢ ��ப (���ᨬ� 2 ��ப�)
                   cBorColor,;  // ��ப� 梥� ��� ࠬ��
                   cBoxColor,;  // ��ப� 梥� ��� ⥪��
                   nStartRow,;  // ���孨� �� ࠬ�� (99 - 業�஢���)
                   nStartCol,;  // ����� ������� ࠬ�� (99 - 業��஢���)
                   cRunColor)   // ��ப� 梥� ��� ����饩 ��ப�
DEFAULT arr_dop TO {"","������ ���� �������"}
aeval(arr_dop, {|x| aadd(cLine,x) } )
return F_MESSAGE(cLine, "W", cBorColor, cBoxColor, nStartRow, nStartCol, .t., cRunColor)
