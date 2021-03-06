#include "set.ch"
#include "function.ch"

*****
FUNCTION FindFirst( xValue, fl_softseek )
DEFAULT fl_softseek TO .f.
// ��६�頥� 㪠��⥫� �� ����� ������, ᮮ⢥�������� �᫮���
DBSEEK( xValue, fl_softseek )
RETURN (NIL)

*****
FUNCTION FindLast( xValue, ascend_des, is_value, i1, i2 )
// ��६�頥� 㪠��⥫� �� ��᫥���� ������, ᮮ⢥�������� �᫮���
// ascend_des := 1 - ������� 䠩� ASCENDING (�� 㬮�砭��)
// ascend_des := -1 - ������� 䠩� DESCENDING
// is_value := .t. - ���� �����᭮�� ���� ��ࠡ��뢠���� �㭪樥� STR()
//  i1 - ��砫쭠� ������ �����᭮�� ���� ��� �㭪樨 STR() (㬮��.=1)
//  i2 - ����筠� ������ �����᭮�� ���� ��� �㭪樨 STR() (㬮��.=len(����))
LOCAL lSeek := SET(_SET_SOFTSEEK, .T.), k, s1, s2, s3, v
DEFAULT ascend_des TO 1, is_value TO .f.
// ���� �����, ᫥���饩 �ࠧ� �� ��᫥���� �������, 㤮���⢮���饩
// �᫮��� ���᪠
if is_value  // ���� ��ப� -> �᫮
  Store "" to s1, s2, s3
  k := LEN(xValue)
  DEFAULT i1 TO 1, i2 TO k
  if i1 > 1
    s1 := left(xValue,i1-1)
  endif
  v := val(substr(xValue,i1,i2-i1+1)) + ascend_des ; s2 := str(v,i2-i1+1)
  if i2 < k
    s3 := right(xValue,k-i2)
  endif
  DBSEEK(s1+s2+s3)
else
  DBSEEK(SUBSTR(xValue,1, LEN(xValue)-1)+;
         CHR(ASC(SUBSTR(xValue, LEN(xValue)))+ascend_des))
endif
// �����饭�� ����� �� ���� ������, �.�. �� ��᫥���� ������,
// 㤮���⢮������ �᫮��� ���᪠
DBSKIP(-1)
SET(_SET_SOFTSEEK, lSeek)
RETURN (NIL)

*****
FUNCTION SkipPointer(nSkip, condition)
// ��ࠢ��� ��६�饭��� 㪠��⥫� ����� ����� �����ﬨ,
// 㤮���⢮���騬� �᫮��� 䨫���樨
LOCAL nNumMoved := 0
DEFAULT condition TO ".t."
DO WHILE !EOF() .AND. !BOF() .AND. nNumMoved != nSkip .AND. &(condition)
  IF nSkip > 0
    DBSKIP()
    Inc(nNumMoved)
  ELSE
    DBSKIP(-1)
    Dec(nNumMoved)
  ENDIF
ENDDO
DO CASE
  CASE EOF()   // �� ���⨦���� ���� 䠩��
    DBSKIP(-1)
    Dec(nNumMoved)
  CASE BOF()       // �� ���⨦���� ��砫� 䠩�� ����室��� 㢥�����
    Inc(nNumMoved) // ���祭�� ���稪� �� 1; ��६���� 㪠��⥫� �����
                   // �� �㦭�, ⠪ ��� �� 㦥 ��室���� �� ��ࢮ� �����
    DBSKIP()       // 蠣 ���।
    DBSKIP(-1)     // 蠣 �����  - �⮡� ���� ��⠭���� BOF()
  CASE !(&(condition)) // �᫨ 㪠��⥫� ��襫 �� �।��� �᫮��� 䨫���.
    IF nSkip > 0    //  �᫨ 㪠��⥫� ����� ��६�頫�� ���।, �
      DBSKIP(-1)    //  ����室��� ��६����� 㪠��⥫� �� ���� ������ �����
      Dec(nNumMoved)//  � 㬥����� ���祭�� ���稪� �� 1
    ELSE              // �᫨ 㪠��⥫� ����� ��६�頫�� �����, �
      DBSKIP()        // ����室��� ��६����� 㪠��⥫� �� ���� ������
      Inc(nNumMoved)  // ���। � 㢥����� ���祭�� ���稪� �� 1
    ENDIF
ENDCASE
RETURN (nNumMoved)
