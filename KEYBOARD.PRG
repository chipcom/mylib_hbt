***** ������� ��� �� ������� ������� "NumLock"
Function f_NumLock(name_ini)
Local k := GetIniVar(name_ini,{{"keyboard","NumLock","on"}})
if k[1] != NIL .and. !(upper(k[1]) == "OFF")
  ksetnum(.t.)  // ������� NumLock
endif
return NIL
