#include 'function.ch'

*****
Function is_server(dir_s)
  // dir_s - ���� � 䠩�-�ࢥ��
  Local tmp_file, fp, err, s_err

  if empty(dir_s)
    return nil
  endif
  tmp_file := dir_s + '_t' + lstr(seconds(), 15, 0) + '.$$$'
  if (fp := fcreate(tmp_file)) == -1
    s_err := '�� �����㦥� ���� ����㯠 � 䠩�-�ࢥ��: ' + dir_s
    err := ferror()
    do case
      case err == 4
        s_err := '���誮� ����� ������� 䠩���'
      case err == 5
        s_err := '�⪠���� � ����㯥 � 䠩�-�ࢥ��'
      case err == 8
        s_err := '��� �����'
      case err == 15
        s_err := '����୮ 㪠���� ��� ��᪠ �ࢥ�'
      case err == 19
        s_err := '����⪠ ����� �� ���饭�� ��� (�ࢥ�)'
      case err == 21
        s_err := '��᪮��� �ࢥ� �� ��⮢'
      case err == 29
        s_err := '�訡�� ����� �� 䠩�-�ࢥ�'
      case err == 32
        s_err := '����襭�� ᮢ���⭮�� �ᯮ�짮����� �ࢥ�'
      case err == 33
        s_err := '����襭�� ����� �ࢥ�'
    endcase
    s_err += '! ��� �訡�� ' + lstr(err)
    func_error(s_err)
    SET COLOR TO
    SET CURSOR ON
    CLS
    QUIT
  endif
  fclose(fp)
  delete file (tmp_file)
  return nil
