#include "function.ch"

*****
Function search_file(_fname,par)
// par = 1 - ��稭��� � ��⠫��� ����᪠ �����
// par = 2 - ��稭��� � ��⠫��� ��� ������
Local ret, _path := upper(beforatnum("\",exename()))+"\"
DEFAULT par TO 1
if par == 1 .and. file(_path+_fname)         // ᭠砫� ��⠫�� ����᪠ �����
  ret := _path+_fname
else
  if type("DIR_SERVER") != "C"
    Private dir_server := ""
  endif
  if file(dir_server+_fname)  // ��⠫�� �� 䠩�-�ࢥ�
    ret := dir_server+_fname
  elseif file(_fname)         // ⥪�騩 ��⠫��
    ret := _fname
  endif
  if ret == NIL .and. par == 2 .and. file(_path+_fname) // ��⠫�� ����᪠ �����
    ret := _path+_fname
  endif
endif
return ret

***** �ࠢ��쭮 ���⠢��� ����砭�� � ᫮�� "䠩�" � ����ᨬ��� �� ���-��
Function num_files(i)
Local t := str(i,3), s1, s2, s := "䠩���"
s1 := right(t,1)
s2 := left(right(t,2),1)
if s2 != "1"
  if s1 == "1"
    s := "䠩�"
  elseif s1 == "2" .or. s1 == "3" .or. s1 == "4"
    s := "䠩��"
  endif
endif
return ltrim(t)+" "+s
