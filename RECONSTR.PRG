#include "set.ch"
#include "function.ch"

***** 12.10.17 ᮧ���� ��� �����ࠨ���� 䠩� ��
Function reconstruct(file_base,;  // ��� 䠩�� ���� ������
                     struct_dbf,; // ��㬥�� ���ᨢ � �⠫����� ������ன ��
                     func_index,; // ������������ �-��, � ���ன ᮧ������ ������� 䠩�� ��� ������ ��
                     lstring,;    // ��ப� ⥪�� � ���᭥���� ᮤ�ন���� ��
                     fl_NET)      // 䫠�, 㪠�뢠�騩, ��� ᮧ������ ��, - �� �ࢥ� ��� ���
Static sdbf := ".dbf"
Static err_2_task := "����⭮��� ����୮�� ����᪠ �����!"
Local adbf, fl := .f., lOldDeleted, lrec, i, is_time, buf := save_maxrow()
DEFAULT func_index TO "", lstring TO "", fl_NET TO .f.
file_base := lower(file_base)
if !(right(file_base,4) == sdbf)
  file_base += sdbf
endif
if !hb_FileExists(file_base)
  if !empty(lstring)
    stat_msg("����! ��������� ���� ������ �� "+lstring)
  endif
  dbcreate(file_base,struct_dbf)
  fl := .t.
elseif control_base(2)
  if !G_Use(file_base,,,.t.,!fl_NET)
    err_msg(err_2_task)
  endif
  adbf := dbstruct()
  lrec := lastrec()
  is_time := (lrec > 1000)
  use
  if !compare_arrays(adbf,struct_dbf)
    if !empty(lstring)
      stat_msg("����! �����ࠨ������ ���� ������ �� "+lstring)
    endif
    dbcreate("tmp",struct_dbf)
    if !G_Use("tmp",,,.t.,.t.)
      err_msg(err_2_task)
    endif
    vrec := (recsize()*lrec+header()+1)*1.3
    if diskspace() < vrec
      func_error("�� ��᪥ �� 墠⠥� "+lstr(vrec-diskspace(),15,0)+;
                                      " ���� ��� �����஥��� ���� ������")
      f_end()
    endif
    close databases
    //
    if is_time
      showtime(maxrow(),72,.f.,"G+/R")
    endif
    lOldDeleted := SET(_SET_DELETED, .F.)
    use tmp new
    append from (file_base) codepage "RU866"
    close databases
    //
    create_copy_reconsrtuct_file(file_base)
    //
    do while ferase(file_base) != 0
    enddo
    if fl_NET
      copy file tmp.dbf to (file_base)
      delete file tmp.dbf
    else
      rename tmp.dbf to (file_base)
    endif
    SET(_SET_DELETED, lOldDeleted)
    if is_time
      showtime()
    endif
    fl := .t.
  endif
endif
rest_box(buf)
if fl .and. !empty(func_index)
  if !("(" $ func_index)
    func_index += "()"
  endif
  if fl_NET
    G_Use(file_base,,,.t.,.t.)
  else
    use (file_base)
  endif
  fl := &(func_index)
endif
close databases
return NIL

***** 12.10.17 ᮧ����� ����� 䠩�� �� ४������樨 � �����⠫��� RECONSTRUCTION 
Static Function create_copy_reconsrtuct_file(file_base)
Static cslash := "\"
Local name_file := '_'+dtos(sys_date)+charrem(":",hour_min(seconds()))+"_"+StripPath(file_base)
Local name_dir := KeepPath(file_base)+cslash+'RECONSTRUCTION'
if !hb_DirExists(name_dir)
  if hb_DirCreate(name_dir) != 0
    return NIL // ���������� ᮧ���� �����⠫�� ��� �����
  endif
endif
name_dir += cslash
copy file (file_base) to (name_dir+name_file)
return NIL
