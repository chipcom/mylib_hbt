***** �� 䠬����, ����� � ������ ������ "������� �.�."
Function fam_i_o(s,arr_fio)
Local s1 := alltrim(s)
if valtype(arr_fio) == "A" .and. len(arr_fio) >= 3
  s1 := alltrim(arr_fio[1])+" "+left(arr_fio[2],1)+"."
  if !empty(arr_fio[3])
    s1 += left(arr_fio[3],1)+"."
  endif
elseif !("." $ s) // �� ��ࠡ��뢠��, �᫨ �� 㦥 䠬���� � ���樠���� (���� �窨)
  s1 := token(s," ",1)
  if numtoken(s," ") > 1
    s1 += " "+left(token(s," ",2),1)+"."
  endif
  if numtoken(s," ") > 2
    s1 += left(token(s," ",3),1)+"."
  endif
endif
return s1
