#include "function.ch"
#include "edit_spr.ch"

***** ������ ������������ (name) 祣�-� �� ���� (kod) � ���� ������
Function retpopupedit
Local mm := "", tmp_select := select()
parameters name_base, mkod
if R_Use(name_base)  // �� �⥭��
  if fieldnum("KOD") > 0 // �᫨ � ���� ������ ���� ���� "KOD"
    locate for FIELD->kod == mkod
    mm := if(found(), rtrim(FIELD->name), "")
  else  // ���� ࠡ�⠥� �� ������ �����
    goto (mkod)
    mm := if(!eof() .and. !deleted(), rtrim(FIELD->name), "")
  endif
  use
endif
if tmp_select > 0
  select(tmp_select)
endif
if empty(mm)
  mm := space(10)
endif
return mm
