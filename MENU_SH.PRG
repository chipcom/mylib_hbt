#include "function.ch"

*****
Function menu_shablon(_mtop, _mleft, _maska, _color, _fl_print, _fl_current)
Static si := 1
Local _buf := savescreen(), __mas1 := {}, __mas2, _j, _i, _maxl := 0,;
      _mright, _mbottom, s_path, ;
      _msg := "^<Esc>^ - выход;  ^<Enter>^ - выбор документа для печати"
DEFAULT _mleft TO 2, _maska TO "*.shb", _color TO color0, _fl_print TO .t.,;
        _fl_current TO .t.
if (_j := adir(_maska)) == 0
  return func_error(4,'Не обнаружено файлов шаблонов "'+_maska+'".')
endif
mywait()
s_path := KeepPath(_maska)
__mas2 := array(_j) ; adir(_maska, __mas2)
if !empty(s_path)
  aeval(__mas2, {|x,i| __mas2[i] := s_path + "\" + x } )
endif
for _i := 1 to _j
  ft_use(__mas2[_i])
  do while !ft_eof()
    if lower(left((_line := ltrim(ft_readln())),5)) == "#name"
      aadd(__mas1, { alltrim(substr(_line,6)), __mas2[_i] } )
      exit
    endif
    ft_skip()
  enddo
  ft_use()
next
if (_j := len(__mas1)) == 0
  restscreen(_buf)
  return func_error(4,'В файлах шаблонов "'+_maska+'" отсутствует директива "#name".')
elseif _j == 1 .and. !_fl_print
  restscreen(_buf)
  return __mas1[1,2]
endif
asort(__mas1,,,{|x,y| upper(x[1]) < upper(y[1])})
__mas2 := array(_j)
aeval(__mas1, {|x,i| __mas2[i] := x[1], _maxl := max(_maxl,len(x[1])) } )
_mright := _mleft + _maxl + 3
if _mright > 77
  _mright := 77 ; _mleft := 74 - _maxl
  if _mleft < 2 ; _mleft := 2 ; endif
endif
_mbottom := _mtop + _j + 1
if _mbottom > 22 ; _mbottom := 22 ; endif
if _fl_current ; _i := si ; else ; _i := 1 ; endif
status_key(_msg)
do while (_i := popup(_mtop,_mleft,_mbottom,_mright,__mas2,_i,_color,.t.)) > 0
  si := _i
  if !_fl_print // не выводить шаблон, а вернуть имя файла
    restscreen(_buf)
    return __mas1[_i,2]
  endif
  print_shablon(__mas1[_i,2],{row()+1,col()})
  restscreen(_buf)
  stat_msg(_msg)
enddo
restscreen(_buf)
return ""
