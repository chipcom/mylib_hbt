#include "fileio.ch"
#include "inkey.ch"
#include "function.ch"

// Функции, имитирующие работу с текстовым файлом, как с базой данных

static mrecno := 0
static offset := 0
static fhandle := -1
static c := ""
static c_size := 1024
static last_rec := 0
static last_off := 0
static isEof := .f.
static last_page := 0

***** открыть (закрыть) файл
Function ft_Use(fname)
isEof := .f.
if fname == NIL .or. fhandle >= 0
  fclose( fhandle )
  c := NIL
  fhandle := -1
  mrecno := offset := last_rec := last_off := last_page := 0
endif
if fname != NIL
  fhandle := fopen( fname, FO_READ + FO_SHARED)
  offset := 0
  mrecno := 1
endif
return fhandle

***** встать на первую строку
Function ft_GoTop()
isEof := .f.
offset := 0
mrecno := 1
return 1

***** вернуть номер текущей строки
Function ft_RecNo()
return mrecno

***** встать на последнюю строку
Function ft_GoBottom()
Local x, t, k
isEof := .f.
if last_rec > 0
  mrecno := last_rec
  offset := last_off
else
  do while .t.
    fseek( fhandle, offset, FS_SET )
    t := if((t := memory(1)) > 4, 4000, t*1000)
    c := space(t)
    if (k := fread( fhandle, @c, t )) != t
      c := left(c,k)
    endif
    t := x := 0
    do while (x := atnum(eos, c, 1, x)) > 0
      t := x
      ++x
      ++mrecno
    enddo
    if t > 0
      offset += t + 1
    else
      exit
    endif
  enddo
  c := NIL
  last_rec := mrecno
  last_off := offset
endif
return last_rec

***** переместиться вперед (назад) на "n" строк (или на одну при n=nil)
Function ft_Skip(n)
return ft_Skip1( if(n == NIL, 1, n) )

***** переместиться вперед (назад) на "recs" строк
static Function ft_Skip1( recs )
Local x, tmp_rec := mrecno, read_pos, read_len, y, k
isEof := .F.
if recs > 0
  for y := 1 to recs
    fseek( fhandle, offset, FS_SET )
    c := space(c_size)
    if (k := fread( fhandle, @c, c_size )) != c_size
      c := left(c,k)
    endif
    if (x := at(eos, c)) > 0
      offset += x + 1
      ++mrecno
    else
      exit
    endif
  next
elseif recs < 0
  recs := -recs
  if (recs := mrecno - recs) < 1
    recs := 1
  endif
  do while mrecno > recs
    if offset - c_size - 2 < 0
      read_pos := 0
      read_len := offset - 2
    else
      read_pos := offset - c_size - 2
      read_len := c_size
    endif
    fseek( fhandle, read_pos, FS_SET )
    c := space(read_len)
    fread( fhandle, @c, read_len )
    if (x := atnum(eos, c)) == 0
      offset := 0
      mrecno := 1
      exit
    else
      offset := read_pos + x + 1
      --mrecno
    endif
  enddo
endif
if tmp_rec == mrecno
  isEof := .t.
endif
return mrecno

***** вернуть текущую строку
Function ft_ReadLn()
Local x, k
fseek( fhandle, offset, FS_SET )
c := space(c_size)
if (k := fread( fhandle, @c, c_size )) != c_size
  c := left(c,k)
endif
if (x := at(eos, c)) == 0
  x := len(c := rtrim(c))+1
endif
return left(c,x-1)

***** венуть количество строк
Function ft_LastRec()
Local old_rec := mrecno, old_offset := offset
ft_GoBottom()
mrecno := old_rec
offset := old_offset
return last_rec

***** конец файла ?
Function ft_Eof()
return isEof

***** встать на строку номер "target"
Function ft_GoTo(target)
Local last := 0, k := if(mrecno > target, -1, 1)
do while mrecno != target
  last := mrecno
  ft_Skip1(k)
  if mrecno == last .or. ft_Eof()
    exit
  endif
enddo
return NIL

***** вернуть максимальную длину строки
Function ft_StrLen()
Local s, width := 50, rec := ft_RecNo(), fl_1 := .f.
ft_GoTop()
do while !ft_Eof()
  if (s := ft_ReadLn()) == chr(12) .or. s == "FF" // первые 2 страницы
    if fl_1 ; exit ; endif          // прочитали 2-ю страницу
    fl_1 := .t.    // прочитали 1-ю страницу
  else
    width := max(width,len(s))
  endif
  ft_Skip()
enddo
ft_GoTo(rec)
return width

***** вернуть размер файла в байтах
Function ft_FileSize()
Local icurpos, ifilesize
icurpos   := fseek(fhandle, 0, FS_RELATIVE)
ifilesize := fseek(fhandle, 0, FS_END)
fseek(fhandle, icurpos, FS_SET)
return ifilesize

***** вернуть количество листов
Function ft_CountPage()
Local rec, s
if last_page == 0
  last_page := 1
  rec := ft_RecNo()
  ft_GoTop()
  do while !ft_Eof()
    if (s := ft_ReadLn()) == chr(12) .or. s == "FF"
      ++last_page
    endif
    ft_Skip()
  enddo
  ft_GoTo(rec)
endif
return last_page
