#include "function.ch"

***** �८�ࠧ����� �᫮ � ��ப� � 㤠���� ��᫥���� �㫨 � �������� ������
Function dellastnul(n,d)  // d ������ ���� ����� ���
Local s, c
DEFAULT d TO 4
if d <= 0
  d := 1
endif
s := lstr(n,19,d)
do while (c := right(s,1)) == "0" .or. c == "."
  s := substr(s,1,len(s)-1)
  if c == "." ; exit ; endif
enddo
RETURN s
