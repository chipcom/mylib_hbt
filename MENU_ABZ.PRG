#include "function.ch"

*****
Function menu_abzac(_mtop, _mleft, _file_abz, _file, _reg_print)
Local _buf := savescreen(), __mas1 := {}, __mas2, _j, _i, _maxl := 0,;
      _mright, _mbottom, s
if (s := search_file(_file_abz)) == NIL
  return func_error(4,"Не обнаружен файл "+_file_abz)
endif
_file_abz := s
if (s := search_file(_file)) == NIL
  return func_error(4,"Не обнаружен файл "+_file)
endif
_file := s
mywait()
ft_use(_file_abz)
do while !ft_eof()
  if !empty(_line := ltrim(ft_readln()))
    _i := at(" ",_line)
    aadd(__mas1, { substr(_line,_i+1), int(val(_line)) } )
  endif
  ft_skip()
enddo
ft_use()
if (_j := len(__mas1)) == 0
  restscreen(_buf)
  return func_error(4,'Нет информации!')
endif
//asort(__mas1,,,{|x,y| x[1] < y[1]})
__mas2 := array(_j)
aeval(__mas1, {|x,i| __mas2[i] := x[1], _maxl := max(_maxl,len(x[1])) } )
_mright := _mleft + _maxl + 3
if _mright > 77
  _mright := 77 ; _mleft := 74 - _maxl
  if _mleft < 2 ; _mleft := 2 ; endif
endif
_mbottom := _mtop + _j + 1
if _mbottom > 22 ; _mbottom := 22 ; endif
_i := 1
Private recno_v_text
do while .t.
  status_key("^<Esc>^ - выход;  ^<Enter>^ - выбор раздела для просмотра/печати")
  if (_i := popup(_mtop,_mleft,_mbottom,_mright,__mas2,_i,,.t.)) > 0
    recno_v_text := __mas1[_i,2]
    viewtext(_file,,,,.t.,,,_reg_print)
    restscreen(_buf)
  else
    exit
  endif
enddo
restscreen(_buf)
return NIL
