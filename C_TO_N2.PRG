Static ss := 16  // ��⥬� ��᫥��� - ��⭠����筠�

***** �८�ࠧ����� ��� �᫠ (�� 0 �� 15) � ���� ᨬ���
Function N2_TO_C(a,b)
return chr( cton( ntoc(a,ss) + ntoc(b,ss), ss ) )

***** �८�ࠧ����� ᨬ��� � ��� �᫠ (�� 0 �� 15)
Function C_TO_N2(c)
Local a := asc(c)
c := ntoc( a, ss )
if a < ss  // �᫨ �᫮ �� �室� < 15 (�.�. ��ࢮ� �� ���� �ᥫ 0)
  c := "0"+c
endif
return { cton(substr(c,1,1),ss), cton(substr(c,2,1),ss) }
