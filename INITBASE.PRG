#include "function.ch"

***** ���樠������ �� (।���஢���� ���ன �����⢫���� f_edit_spr)
Function init_base(file_base,string,gmenu,len_key,func_index,fl_NET,arr_ind)
// file_base -  ��� �� � ��⥬ � ���७���
// string     - ��ப� ⥪�� � ���᭥���� ᮤ�ন���� ��
// gmenu -      㪠��⥫� �� ���樠�������騩 ���ᨢ
// len_key -    ����� ���� kod (��� 0 � ��砥 ������⢨� � �� ���� KOD)
// func_index - ������������ �㭪樨 ������஢���� ��
// fl_NET -     䫠�, 㪠�뢠�騩, ��� ᮧ������ ��, - �� �ࢥ� ��� ���
// arr_ind    - ���ᨢ �������� 䠩��� (�⮡� ᤥ���� �� �࠭���樮��묨)
Local i, k, adbf
DEFAULT len_key TO 0, fl_NET TO .f.
adbf := if(len_key==0, {}, {{"kod","N",len_key,0}})
for i := 1 to len(gmenu)
  k := aclone(gmenu[i])
  asize(k,4)
  aadd(adbf,aclone(k))
next
reconstruct(file_base, adbf, func_index, string, fl_NET, arr_ind)
return NIL
