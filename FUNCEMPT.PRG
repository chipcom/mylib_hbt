#include "inkey.ch"

***** �� �த������� �� GET-�� ���� �����頥� .f. � ��砥 ���⮩ ��६�����
Function func_empty(n)
Local fl := .t.
if empty(n) .and. lastkey() != K_UP
  fl := func_error(3,"������ ���� �� ������ ���� �����.")
  keyboard ""
endif
return fl
