#include "function.ch"

***** �㬬� �ய���� � த�⥫쭮� ������
function ssumma_r
local k := 0, t := "", s, l
parameters n,r
if type("n") == "C"
  n := val(n)
endif
s := lstr(n,15,0)
if left(s,1) == "-"
  msign := "����� " ; s := substr(s,2)
endif
Private rod_m_w := if(pcount() == 1, "�", "�")
if n == 0
  return "���"
endif
do while .t.
  l := len(s)
  k++
  t := ssummaF(right(s,3),k)+t
  if l <= 3
    exit
  endif
  s := left(s,l-3)
enddo
return alltrim(t)

*****
Static function ssumma2(ch)
local n := int(val(ch)),;
      mas := {"�����", "���������", "��������", "�ਭ����",;
              "���ୠ���", "��⭠���", "��⭠���",;
              "ᥬ�����", "��ᥬ�����", "����⭠���"}
return " "+mas[n+1]

*****
Static function ssumma20(ch)
local n := int(val(ch)),;
      mas := {"������", "�ਤ��", "�ப�", "��⨤����",;
              "��⨤����", "ᥬ������", "���쬨�����",;
              "���ﭮ��"}
return " "+mas[n-1]

*****
Static function ssumma3(ch,m)
local n := int(val(ch)),;
      mas := {"������", "����", "���", "�����", "���",;
              "���", "ᥬ�", "���쬨", "�����"}
if m == 2 .or. (m == 1 .and. rod_m_w == "�")
  mas[1] := "�����"
endif
return " "+mas[n]

*****
Static function ssumma1(ch)
local n := int(val(ch)),;
      mas := {"��", "������", "�����", "�������","�����",;
              "�����", "ᥬ���", "���쬨��", "�������"}
return " "+mas[n]

*****
Static function ssummaN(kk, n3, flag)
local mast := {"�����", "�����", "�����"},;
      masM := {"��������", "���������", "���������"},;
      masB := {"������ठ", "������म�", "������म�"},;
      i := 3, s := " "
if !flag
  if n3 == 1
    i := 1
  elseif n3 < 5
    i := 2
  endif
endif
do case
  case kk == 1
    s += masT[i]
  case kk == 2
    s += masM[i]
  case kk == 3
    s += masB[i]
endcase
return s

******
Static function ssummaF(s,k)
local fl := .t., l := len(s), t := "", s1 := " ", s2 := " ",;
      s3 := right(s,1)
if l > 1
  s2 := left(right(s,2),1)
endif
if l > 2
  s1 := left(s,1)
endif
if s2 == "1"
  t := ssumma2(s3)
elseif s3 == "0"
  if s2 != "0"
    t := ssumma20(s2)
  endif
else
  t := ssumma3(s3,k)
  fl := .f.
  if s2 != "0" .and. s2 != " "
    t := ssumma20(s2)+t
  endif
endif
if s1 != " " .and. s1 != "0"
  t := ssumma1(s1)+t
endif
if k > 1 .and. !(s1 == "0" .and. s2 == "0" .and. s3 == "0")
  t += ssummaN(k-1,int(val(s3)),fl)
endif
return t
