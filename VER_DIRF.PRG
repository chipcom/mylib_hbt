#include 'function.ch'

// �஢���� ����⢮����� ��⠫��� � ���४⭮� ��� 䠩��
Function VerDirFile(d)
  Local lfile, ldir
  // ������ ��� 䠩�� ��� ���
  lfile := StripPath(d)
  if !filevalid(lfile)
    func_error(4, '�����४⭮� ��� 䠩��: ' + upper(lfile))
    return NIL
  endif
  // ������ ���� ��� ����� 䠩��
  ldir := KeepPath(d)
  is_server(ldir, cur_dir)
  return d
