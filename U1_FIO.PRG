#include 'function.ch'

// �८�ࠧ����� ��ப� �.�.�. (� GET'�) � ��ଠ�쭮�� ���� :
// �.�. ��ࢠ� �㪢� � ᫮�� ���������, ��⠫�� �����쪨�
Function upper1_fio(i_var)
  Local i, l, tmp, s := '', c, fl := .t.

  if i_var == NIL  // �.�. �८�ࠧ������ ��६����� � GET'�
    tmp := &(readvar())
  else
    tmp := i_var
  endif
  l := len(tmp)
  tmp := lower(alltrim(tmp))  // �� � ������ ॣ����
  tmp := charone(' ', tmp)     // ��⠢��� �� ������ �஡���
  for i := 1 to len(tmp)
    c := substr(tmp, i, 1)
    if isletter(c)
      if fl  // �.�. �� ��ࢠ� �㪢� � ᫮��
        c := upper(c)
      endif
      fl := .f.
    else
      fl := .t.
    endif
    s += c
  next
  if i_var == NIL  // �.�. �८�ࠧ������ ��६����� � GET'�
    &(readvar()) := padr(s, l)
    return .t.
  endif
  return padr(s, l)
