#include 'set.ch'
#include 'function.ch'

// �஢�ઠ �� �, ���� ����� � ⥪�饬 ��⠫��� ��� �� ���
Function verify_task(name_task, _path)
  Local fl, old_set_path

  name_task := upper(name_task)
  if !('.' $ name_task)
    name_task += '.EXE'
  endif
  old_set_path := SET(_SET_PATH, GETENV('PATH'))
  fl := FILE(name_task)
  SET(_SET_PATH, old_set_path)
  if !fl .and. pcount() > 1
    _path := upper(beforatnum('\', exename())) + '\'
    if file(_path + name_task)   // ᭠砫� ��⠫�� ����᪠ �����
      fl := .t.
    else
      if type('DIR_SERVER') != 'C'
        Private dir_server := ''
      endif
      if file(dir_server + name_task)  // ��⠫�� �� 䠩�-�ࢥ�
        _path := dir_server
        fl := .t.
      endif
    endif
  endif
  if !fl
    func_error('��� ����㯠 � ����� ' + name_task)
  endif
  return fl
