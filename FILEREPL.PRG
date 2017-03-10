#include "function.ch"
#include "edit_spr.ch"

*****
Function filerepl(cSearchFor, name_file, cReplace)
// заменить подстроку cSearchFor на cReplace во всех строках файла name_file
Local tmp_file := "__tmp__.txt", lfp, s
fp := fcreate(tmp_file) ; n_list := 1 ; tek_stroke := 0
lfp := fopen(name_file)
do while !feof(lfp)
  s := fReadLn(lfp)
  s := atrepl(cSearchFor, s, cReplace)
  add_string(s)
enddo
fclose(fp)
fclose(lfp)
delete file (name_file)
copy file (tmp_file) to (name_file)
delete file (tmp_file)
return NIL
