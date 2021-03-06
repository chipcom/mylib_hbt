#include "fileio.ch"
#include "inkey.ch"
#include "function.ch"

// �㭪樨, �������騥 ࠡ��� � ⥪�⮢� 䠩���, ��� � ����� ������

static mrecno := 0
static offset := 0
static fhandle := -1
static c := ""
static c_size := 1024
static last_rec := 0
static last_off := 0
static isEof := .f.
static last_page := 0

***** ������ (�������) 䠩�
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

***** ����� �� ����� ��ப�
Function ft_GoTop()
isEof := .f.
offset := 0
mrecno := 1
return 1

***** ������ ����� ⥪�饩 ��ப�
Function ft_RecNo()
return mrecno

***** ����� �� ��᫥���� ��ப�
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

***** ��६������� ���। (�����) �� "n" ��ப (��� �� ���� �� n=nil)
Function ft_Skip(n)
return ft_Skip1( if(n == NIL, 1, n) )

***** ��६������� ���। (�����) �� "recs" ��ப
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

***** ������ ⥪���� ��ப�
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

***** ������ ������⢮ ��ப
Function ft_LastRec()
Local old_rec := mrecno, old_offset := offset
ft_GoBottom()
mrecno := old_rec
offset := old_offset
return last_rec

***** ����� 䠩�� ?
Function ft_Eof()
return isEof

***** ����� �� ��ப� ����� "target"
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

***** ������ ���ᨬ����� ����� ��ப�
Function ft_StrLen()
Local s, width := 50, rec := ft_RecNo(), fl_1 := .f.
ft_GoTop()
do while !ft_Eof()
  if (s := ft_ReadLn()) == chr(12) .or. s == "FF" // ���� 2 ��࠭���
    if fl_1 ; exit ; endif          // ���⠫� 2-� ��࠭���
    fl_1 := .t.    // ���⠫� 1-� ��࠭���
  else
    width := max(width,len(s))
  endif
  ft_Skip()
enddo
ft_GoTo(rec)
return width

***** ������ ࠧ��� 䠩�� � �����
Function ft_FileSize()
Local icurpos, ifilesize
icurpos   := fseek(fhandle, 0, FS_RELATIVE)
ifilesize := fseek(fhandle, 0, FS_END)
fseek(fhandle, icurpos, FS_SET)
return ifilesize

***** ������ ������⢮ ���⮢
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
