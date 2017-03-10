#include "fileio.ch"
#include "function.ch"

************************ Функции работы с ini.файлами **************************
* GetIniVar(cFile, arr)    - вернуть массив значений переменных (типа "C")     *
* GetIniSect(cFile, cSect) - вернуть содержимое секции {{"наим.","знач."},...} *
* SetIniVar(cFile, arr)    - запись массива переменных в ini.файл              *
* SetIniSect(cFile, cSect, arr) - (пере)запись секции в ini.файл               *
********************************************************************************

Static tmp_file := "____file.tmp"

***** вернуть массив значений необходимых переменных (типа "C")
Function GetIniVar(cFile, arr)
// cFile - ini.файл
// arr - массив из "троек": {cSect, cKey, cDefault}
Local alen := len(arr), ret, aexit, nSect, nKey, fp, ;
      is_Sect := .f., s, i, j, k, sVar
ret := array(alen) ; aexit := array(alen) ; afill(aexit,.f.)
aeval(arr, {|x,i| ret[i] := x[3] } )
if !("." $ cFile)
  cFile += ".ini"
endif
if file(cFile)
  aeval(arr, {|x,i| arr[i,1] := upper(x[1]), arr[i,2] := upper(x[2]) } )
  fp := fopen( cFile, FO_READ + FO_SHARED)
  do while !feof(fp)
    s := alltrim(fReadLn(fp))
    s := cut_comment(s)  // отрезать завершающий комментарий
    if !(empty(s) .or. left(s,1) == ";")
      if left(s,1) == "[" .and. right(s,1) == "]"
        if is_Sect
          if ver_array(aexit, {|x| x })
            exit
          endif
          is_Sect := .f.
        endif
        s := alltrim(substr(s,2,len(s)-2))
        if (i := ascan(arr, {|x| x[1] == upper(s) } )) > 0
          is_Sect := .t. ; nSect := arr[i,1]
        endif
      elseif is_Sect  // если нашли секцию
        if (k := at("=",s)) > 0
          nKey := upper(rtrim(left(s,k-1)))
          if (j := ascan(arr, {|x| x[1] == nSect .and. x[2] == nKey} )) > 0
            sVar := ltrim(substr(s,k+1))
            ret[j] := sVar ; aexit[j] := .t.
            if ver_array(aexit, {|x| x })
              exit
            endif
          endif
        endif
      endif
    endif
  enddo
  fclose(fp)
endif
return ret

*

***** вернуть двумерный массив содержимого секции {{"наим.","знач."},...}
Function GetIniSect(cFile, cSect)
Local ret := {}, nSect, fp, is_Sect := .f., s, i, j, k, sVar
if !("." $ cFile)
  cFile += ".ini"
endif
if file(cFile)
  cSect := upper(cSect)
  fp := fopen( cFile, FO_READ + FO_SHARED)
  do while !feof(fp)
    s := alltrim(fReadLn(fp))
    s := cut_comment(s)  // отрезать завершающий комментарий
    if !(empty(s) .or. left(s,1) == ";")
      if left(s,1) == "[" .and. right(s,1) == "]"
        if is_Sect
          exit
        endif
        s := alltrim(substr(s,2,len(s)-2))
        if cSect == upper(s)
          is_Sect := .t.
        endif
      elseif is_Sect  // если нашли секцию
        if (k := at("=",s)) > 0
          aadd(ret, { rtrim(left(s,k-1)), ltrim(substr(s,k+1)) } )
        endif
      endif
    endif
  enddo
  fclose(fp)
endif
return ret

*

***** запись массива переменных в ini.файл
Function SetIniVar(cFile, arr)
// arr - массив из "троек": {cSect, cKey, cValue}
Local nSect, nKey, fp, fp1, is_Sect := .f., s, s1, i, j, k, ;
      bak_file, last_Sect := "", arr1 := {}
if !("." $ cFile)
  cFile += ".ini"
endif
for i := 1 to len(arr)
  arr[i,1] := upper(arr[i,1])
  arr[i,2] := upper(arr[i,2])
  do case
    case valtype(arr[i,3]) == "D"
      arr[i,3] := dtos(arr[i,3])
    case valtype(arr[i,3]) == "N"
      arr[i,3] := lstr(arr[i,3])
  endcase
next
if !file(cFile)  // если не было файла - пишем первый раз
  asort(arr,,,{|x,y| x[1] < y[1] } )
  fp := fcreate(cFile)
  for i := 1 to len(arr)
    if !(last_Sect == arr[i,1])
      fwrite(fp,"["+arr[i,1]+"]"+eos)
      last_Sect := arr[i,1]
    endif
    fwrite(fp,arr[i,2]+"="+arr[i,3]+eos)
  next
  fclose(fp)
else
  for i := 1 to len(arr)
    if (j := ascan(arr1, {|x| x[1] == arr[i,1]} )) == 0
      aadd(arr1, {arr[i,1], {}, .f. } ) ; j := len(arr1)
    endif
    aadd(arr1[j,2], {arr[i,2],arr[i,3],.f.} )
  next
  bak_file := substr(cFile,1,len(cFile)-4)+".bak"
  fp1 := fcreate(tmp_file)
  fp := fopen( cFile, FO_READ + FO_SHARED)
  do while !feof(fp)
    s := s1 := alltrim(fReadLn(fp))
    s := cut_comment(s)  // отрезать завершающий комментарий
    if left(s,1) == "[" .and. right(s,1) == "]" .and. is_Sect
      // дописываем в существующую секцию новые переменные
      for j := 1 to len(arr1[i,2])
        if !arr1[i,2,j,3]
          fwrite(fp1,arr1[i,2,j,1]+"="+arr1[i,2,j,2]+eos)
          arr1[i,2,j,3] := .t.
        endif
      next
    endif
    if empty(s) .or. left(s,1) == ";"
      if !empty(s1)
        fwrite(fp1,s1+eos)
      endif
    else
      if left(s,1) == "[" .and. right(s,1) == "]"
        fwrite(fp1,eos+s1+eos)
        if is_Sect
          is_Sect := .f.
        endif
        s := alltrim(substr(s,2,len(s)-2))
        if (i := ascan(arr1, {|x| x[1] == upper(s) } )) > 0
          is_Sect := .t. ; nSect := arr1[i,1] ; arr1[i,3] := .t.
        endif
      elseif is_Sect  // если нашли секцию
        if (k := at("=",s)) > 0
          nKey := upper(rtrim(left(s,k-1)))
          if (j := ascan(arr1[i,2], {|x| x[1] == nKey } )) > 0
            fwrite(fp1,rtrim(left(s,k-1))+"="+arr1[i,2,j,2]+eos)
            arr1[i,2,j,3] := .t.
          else
            fwrite(fp1,s1+eos)
          endif
        endif
      else
        fwrite(fp1,s1+eos)
      endif
    endif
  enddo
  if is_Sect  // дописываем в существующую секцию новые переменные
    for j := 1 to len(arr1[i,2])
      if !arr1[i,2,j,3]
        fwrite(fp1,arr1[i,2,j,1]+"="+arr1[i,2,j,2]+eos)
        arr1[i,2,j,3] := .t.
      endif
    next
  endif
  // дописываем новые секции
  for i := 1 to len(arr1)
    if !arr1[i,3]
      fwrite(fp1,eos+"["+arr1[i,1]+"]"+eos)
      for j := 1 to len(arr1[i,2])
        fwrite(fp1,arr1[i,2,j,1]+"="+arr1[i,2,j,2]+eos)
      next
    endif
  next
  fclose(fp)
  fclose(fp1)
  copy file (cFile) to (bak_file)
  copy file (tmp_file) to (cfile)
  delete file (tmp_file)
endif
return NIL

*

***** запись секции в ini.файл
Function SetIniSect(cFile, cSect, arr)
// cSect - наименование секции
// arr - двумерный массив: {{cKey, cValue}, {...,...}, ...}
Local nSect, nKey, fp, fp1, is_Sect := .f., s, s1, i, j, k, ;
      bak_file, last_Sect := "", arr1 := {}
if !("." $ cFile)
  cFile += ".ini"
endif
for i := 1 to len(arr)
  arr[i,1] := upper(arr[i,1])
  do case
    case valtype(arr[i,2]) == "D"
      arr[i,2] := dtos(arr[i,2])
    case valtype(arr[i,2]) == "N"
      arr[i,2] := lstr(arr[i,2])
  endcase
next
asort(arr,,,{|x,y| x[1] < y[1] } )
if !file(cFile)
  fp := fcreate(cFile)
  fwrite(fp,"["+cSect+"]"+eos)
  for i := 1 to len(arr)
    fwrite(fp,arr[i,1]+"="+arr[i,2]+eos)
  next
  fclose(fp)
else
  bak_file := substr(cFile,1,len(cFile)-4)+".bak"
  fp1 := fcreate(tmp_file)
  fp := fopen( cFile, FO_READ + FO_SHARED)
  do while !feof(fp)
    s := s1 := alltrim(fReadLn(fp))
    s := cut_comment(s)  // отрезать завершающий комментарий
    if left(s,1) == "[" .and. right(s,1) == "]"
      if is_Sect
        is_Sect := .f.
      endif
      s := alltrim(substr(s,2,len(s)-2))
      if upper(s) == upper(cSect)
        is_Sect := .t.
      else
        fwrite(fp1,eos+s1+eos)
      endif
    elseif !is_Sect  // если не наша секция
      if !empty(s1)
        fwrite(fp1,s1+eos)
      endif
    endif
  enddo
  // дописываем новую секцию
  fwrite(fp1,eos+"["+cSect+"]"+eos)
  for i := 1 to len(arr)
    fwrite(fp1,arr[i,1]+"="+arr[i,2]+eos)
  next
  fclose(fp)
  fclose(fp1)
  copy file (cFile) to (bak_file)
  copy file (tmp_file) to (cfile)
  delete file (tmp_file)
endif
return NIL

*

***** отрезать завершающий комментарий
Static Function cut_comment(s)
if "//" $ s
  s := rtrim(beforatnum("//",s,1))
endif
return s
