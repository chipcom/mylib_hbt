*****
Function del_dbf_file(lfile)
Local fl := .t.
delete file (lfile)
if file(lfile)
  fl := func_error(4,'База данных "'+upper(lfile)+'" занята другим приложением!')
endif
return fl
