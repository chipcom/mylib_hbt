// ����樨 ��� �࠭���� ���� � "���祭���" �ଠ� (�4)
// �ਬ��: ��室��� ���     - 21.08.1990
//         १���� DTOS()  - "19900821"
//         १���� DTOC4() - chr(19)+chr(90)+chr(08)+chr(21) = "Z"
// �ਬ�砭��: �� ������� ���� �������� ��室�� �������筮 DTOS()

*****
Function c4tod(s)
Local d, m, y
if s == space(4) ; return ctod("") ; endif
d := strzero(asc(substr(s,4,1)), 2)
m := strzero(asc(substr(s,3,1)), 2)
y := strzero(asc(substr(s,1,1)), 2) + strzero(asc(substr(s,2,1)), 2)
set date german
return ctod(d+"."+m+"."+y)

*****
Function dtoc4(d)
Local i, s, s1 := ""
if empty(d) ; return space(4) ; endif
s := dtos(d)
for i := 1 to 4
  s1 += chr(val(substr(s,i*2-1,2)))
next
return s1
