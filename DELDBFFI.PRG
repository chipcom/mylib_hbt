*****
Function del_dbf_file(lfile)
Local fl := .t.
delete file (lfile)
if file(lfile)
  fl := func_error(4,'���� ������ "'+upper(lfile)+'" ����� ��㣨� �ਫ�������!')
endif
return fl
