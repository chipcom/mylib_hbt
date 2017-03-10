#include "fileio.ch"
#include "function.ch"
#include "inkey.ch"

***** выполнить блок кода для каждой строки текстового файла
Function feval(name_file, blk)
Local fp
if file(name_file)
  fp := fopen(name_file, FO_READ + FO_SHARED)
  do while !feof(fp)
    eval(blk, fReadLn(fp))
  enddo
  fclose(fp)
endif
return NIL

***** определить, не конец ли файла
Function feof(ihandle)
Local icurpos, ifilesize
icurpos   := fseek(ihandle, 0, FS_RELATIVE)
ifilesize := fseek(ihandle, 0, FS_END)
fseek(ihandle, icurpos, FS_SET)
return icurpos >= ifilesize

#define COUNT_Chars  64

***** чтение очередной строки из текстового файла
Function freadln(ihandle)
Local icurpos, ifilesize, buf := space(COUNT_Chars), ;
      n := COUNT_Chars, n1, k := 0, m1, m2, fl := .f.
icurpos   := fseek(ihandle, 0, FS_RELATIVE)
ifilesize := fseek(ihandle, 0, FS_END)
do while .t.
  fseek(ihandle, icurpos, FS_SET)
  n1 := fread(ihandle, @buf, n)
  if fseek(ihandle, 0, 1) >= ifilesize
    exit
  endif
  if at(eos, buf) > 0 .or. at(Hos, buf) > 0
    exit
  endif
  buf += space(COUNT_Chars)
  n += COUNT_Chars
enddo
m1 := at(eos, buf)
m2 := at(Hos, buf)
if m1 == 0 .and. m2 == 0
  fl := .t.
  k := n1
elseif m1 == 0
  k := m2 + 1
elseif m2 == 0
  k := m1 + 1
else
  k := min(m1,m2) + 1
endif
if k <= 0
  return ""
endif
fseek(ihandle, icurpos+k, FS_SET)
return left(buf, if(fl,k,k-2))
