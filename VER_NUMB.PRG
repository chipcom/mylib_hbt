// �㭪�� �஢�ન ��ப� �� �, �⮡� �� �� ᨬ���� �뫨 ��஢묨
Function ver_number(s)

  if empty(s)
    return .f.
  endif   // �᫨ ��ப� ����� - ������ .f.
  return EMPTY(CHARREPL('0123456789', s, SPACE(10)))
