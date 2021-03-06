#include "function.ch"

Static loc_error := 0

***** �ࠢ����� ���� ���ᨢ�� �� ����������
***** � ������ % ��ᮢ���⨬��� (���� ��ᮢ���⨬���)
Function ret_diff_arrays(x1,x2)
// �����頥� 0, �᫨ ࠧ��୮�� ���ᨢ�� �� ᮢ������
// ���� �����頥� ���� ��ᮢ������� (�� �⭮襭�� � 1), ���ਬ��: 0.21 � �.�.
Local kol_k := 0, koln_sovpad := 0
if __comp_arr(x1,x2,@kol_k,@koln_sovpad) == 0 .or. kol_k <= 0
  return 0
endif
return (koln_sovpad/kol_k)

*****
Function __comp_arr(x1,x2,kol_poz,kol_nsovp)
// �����頥��� ���祭��:
// 0 - �᫨ � ���ᨢ�� ������� ࠧ���� � ⨯�� ������ ��� ࠧ��୮��
// 1 - ��ଠ��� ��室 => � ��६����� kol_poz (����� ���ᨢ�) �
//   kol_nsovp (���-�� ��ᮢ�������) �� ����� ���������� �������� ���祭��
LOCAL i, fl := .t., vr
SET EXACT ON
if LEN(x1) != LEN(x2) // �᫨ ࠧ��୮�� �� ⥪�饬� ����७�� �� ࠢ��
  RETURN loc_error
endif
FOR i := 1 TO LEN(x1)
  if VALTYPE(x1[i]) == "A"
    vr := __comp_arr(x1[i],x2[i],@kol_poz,@kol_nsovp)
    if vr == (loc_error)
      RETURN loc_error
    endif
  elseif valtype(x1[i]) == valtype(x2[i])
    ++kol_poz
    if valtype(x1[i]) == "C"
      if upper(x1[i]) != upper(x2[i]) ; ++kol_nsovp ; endif
    else
      if x1[i] != x2[i] ; ++kol_nsovp ; endif
    endif
  else      // �᫨ ⨯� ������ �� ⥪�饬� ����७�� �� ᮢ������
    RETURN loc_error
  endif
NEXT
RETURN (1)
