#include 'function.ch'

// �஢�ઠ �ࠢ ����㯠 (����� ���� PUBLIC ��६����� pravo_write)
Function ver_dostup(fl)

  DEFAULT fl TO .t.
  if !pravo_write
    return func_error(4, '����襭�� �ࠢ ����㯠 �� ' + if(fl, '������', '㤠�����') + '!')
  endif
  return .t.
