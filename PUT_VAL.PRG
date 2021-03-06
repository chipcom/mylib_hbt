#include "function.ch"

***** �८�ࠧ����� �᫮ � ��ப�; �᫨ ��� == 0, � ������ �஡���
Function put_val(v,l,d,c)
Local s
DEFAULT l TO 10, d TO 0, c TO " "
s := lstr(v,19,d)
if empty(val(s))
  s := replicate(c,l)
else
  if len(s) > l
    s := replicate("*",l)
  else
    s := padleft(s,l,c)
  endif
endif
return s

***** �������� ��᫥���� ��� ��� � ���.������ �� �஡��� (�������)
Function put_kop(v,l)
Local s := lstr(v,20,2)
if len(s) <= l
  s := padl(s,l)
  if right(s,3) == ".00"
    s := left(s,l-3)+space(3)
  endif
else  // �᫨ ����砥��� ��ப� � ����� ����� ����室����
  if right(s,3) == ".00"
    s := beforatnum(".",s)  // � �뢮��� ��� ������
    s := padl(s,l)
  else
    s := padr(s,l)
  endif
endif
return s

***** �᫨ = 0, � �뢥�� �஡���
Function put_kopE(v,l)
Local s := put_kop(v,l)
if alltrim(s) == "0"
  s := space(l)
endif
return s

***** �������� ��᫥���� ��� ��� � ���.������ �� �஡��� (�������)
Function lput_kop(v,fl)      // � ���� �஡��� ᫥��
Local s := put_kop(v,20)
DEFAULT fl TO .f.
if fl
  s := rtrim(s)  // ���� �஡��� �ࠢ�
endif
return ltrim(s)

***** �८�ࠧ����� ���� � ��ப�; �᫨ ��� �����, � ������ �஡���
Function put_date(d)
Local k := if(__SetCentury(), 10, 8)
return if(empty(d), space(k), dtoc(d))

***** 㬥���� �᫮ n � l ᨬ�����, max ���-�� ���.������ - d
Function umest_val(n,l,d,yes_zero,yes_plus)
Local s, k
DEFAULT l TO 10, d TO 0, yes_zero TO .f., yes_plus TO .f.
s := lstr(n,19,d)
if empty(val(s))
  s := padl(iif(yes_zero, "0", ""), l)
else
  if d > 0
    do while (c := right(s,1)) == "0" .or. c == "."
      s := substr(s,1,len(s)-1)
      if c == "." ; exit ; endif
    enddo
  endif
  if n > 0 .and. yes_plus
    s := "+"+s
  endif
  if len(s) > l
    if "." $ s
      if (k := at(".",s)) > l+1
        s := replicate("*",l)
      else
        s := substr(s,1,l)
        if right(s,1) == "."
          s := substr(s,1,l-1)
        endif
      endif
    else
      s := replicate("*",l)
    endif
  else
    s := padleft(s,l)
  endif
endif
return padleft(s,l)

***** 㬥���� �㬬� n � l ᨬ����� (������� ���� ���४⭮ �룫拉��)
Function umest_kop(n,l,d)
Local s
DEFAULT d TO 2
s := umest_val(n,l,d)
if substr(s,l-1,1) == "." ;     // �᫨ ⮫쪮 ���� ���� ��᫥ ����⮩
     .and. left(s,1) == " "  // � � ����� �� ���� ����
  s := substr(s,2)+"0"    // � ��������� �஡��� ���� ���� ������ (�������)
endif
return s
