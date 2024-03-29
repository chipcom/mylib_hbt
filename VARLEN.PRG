#include 'function.ch'

// ������ ����� ��६����� ��� ⨯�
Function varlen(expAny, sPicture)
  Local vt := VALTYPE(expAny), is_picture := (valtype(sPicture) == 'C'), lp

  if is_picture
    lp := len_picture(sPicture)
  endif
  do case
    case vt == 'C'
      if is_picture .and. lp > len(expAny)
        return lp  // �᫨ ���� 蠡��� ��� ����� ⥫�䮭� � �.�.
      else
        RETURN len(expAny)
      endif
    case vt == 'D'
      RETURN len(dtoc(date()))  // 8 ��� 10 � ����ᨬ��� �� SET CENTURY
    case vt == 'N'
      if is_picture
        return lp
      else
        return len(str(expAny))
      endif
    case vt == 'L'
      return 3  // .t. ��� .f.
  endcase
  return 0

//
Static Function len_picture(s)

  if left(s, 1) == '@'
    s := alltrim(substr(s, 3))
  endif
  return len(s)
