***** удалить файл с длинным именем
Function del_longfile(cFile)
delete file (cFile)
return !file(cFile)

***** копировать файл с коротким (или длинным) именем в файл с длинным именем
Function copy_longfile(cOld,cNew)
copy file (cOld) to (cNew)
return file(cNew)
