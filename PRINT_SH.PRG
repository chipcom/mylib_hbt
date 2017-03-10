#include "inkey.ch"
#include "function.ch"

// если функции, используемые в #proc, больше нигде не вызываются
// в программе, перед вызовом print_shablon() их необходимо
// объявить, как EXTERNAL

EXTERNAL comp_block, put_val

***** печать по шаблону
Function print_shablon( __in_file,_param,_out_file,_fl_view )
// __in_file - наименование файла шаблона
// _param    - массив параметров для шаблона (как параметры для функции)
// _out_file - наименование текстового файла для вывода документа
// _fl_view  - логическое значение, указывающее на то, выводить ли
//             полученный документ с помощью функции viewtext
Local _tmp_array, _buf24 := save_maxrow(), _in_file, cMessage
if __in_file == NIL
  return func_error(4,"Нет имени файла шаблона.")
else
  if !("." $ __in_file)
    __in_file += ".shb"
  endif
endif
if (_in_file := search_file(__in_file)) == NIL
  return func_error(4,"Не обнаружен файл "+__in_file)
endif
DEFAULT _param TO {}
DEFAULT _out_file TO StripPath(beforatnum(".",_in_file)) + ".txt"
DEFAULT _fl_view TO .t.
*
WaitStatus("Подождите, работаю ... ")
ft_use(_in_file)
fp := fcreate(_out_file) ; n_list := 1 ; tek_stroke := 0
private bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
private _tmp, _tmp1, width := 60, height := 60, regim := 1, ;
        _arr_do := {}, _arr_if := {}, _word1, _word2, _k, ;
        _rec_title := 0, _rec1_title := 0, _flag_param := .f., ;
        _cur_string := "", _flag_1list := .t., outlist := .f., ;
        _arr_var := {}, _flag_var := .f., _flag_i_var := .f., ;
        r_margin := .f., _fl_return := .f., _yes_FF := .t., yes_albom := .f.
BEGIN SEQUENCE
ft_gotop()
do while !ft_eof()
  UpdateStatus()
  if len(_tmp_array := get_token()) > 0
    for _k := 1 to len(_tmp_array)
      _tmp1 := _tmp_array[_k]
      Private &_tmp1
    next
    if _flag_param // присвоение формальных параметров
      // если параметров в шаблоне больше, чем длина массива _param,
      // то оставшиеся параметры будут иметь значение NIL
      for _k := 1 to min(len(_param),len(_tmp_array))
        _tmp1 := _tmp_array[_k]
        &_tmp1 := _param[_k]
      next
      _flag_param := .f.
    endif
  endif
  if _fl_return ; exit ; endif
  ft_skip()
enddo
RECOVER USING error
  cMessage := ErrorMessage(error)
  _tmp := "Ошибка в "+lstr(ft_recno())+" строке файла "+__in_file
  func_error(4,_tmp)
  func_error(4,cMessage)
  if type("DIR_SERVER") != "C"
    Private dir_server := ""
  endif
  _tmp := dtoc(date())+"  "+sectotime(seconds())+"  "+StripPath(exename())+eos+;
          _tmp+eos+cMessage+eos+replicate("*",79)+eos
  strfile(_tmp,dir_server+"error.txt",.t.)
END
ERRORBLOCK(bSaveHandler)
close databases
fclose(fp)
ft_use()
del_err_compiler()
rest_box(_buf24)
if _fl_view .and. !_fl_return
  viewtext(_out_file,,,,(width > 80),,,regim,,,,_yes_FF)
endif
return {width,height,regim,_out_file,yes_albom}

*****
Static Function get_token()
Local _priv_arr := {}, _rec, _tmp_string
if left(ltrim(_cur_string := ft_readln()),1) == "#"
  if "//" $ _cur_string  // отрезать завершающий комментарий
    _cur_string := rtrim(beforatnum("//",_cur_string,1))
  endif
  _tmp := ltrim(_cur_string)
  _word1 := lower(token(_tmp," ",1))
  _word2 := lower(token(_tmp," ",2))
  do case
    case _word1 == "#proc"  // выполнение процедуры (синтаксис блока кода)
      eval(COMPILE(ltrim(substr(_tmp,6))))
    case _word1 == "#formfeed"
      if tek_stroke > height
        _rec := ft_recno()
        add_string(chr(12))
        // вывести заголовок N-го листа
        if _rec1_title == 0
          _rec1_title := _rec_title
        endif
        n_list++ ; tek_stroke := 0
        if outlist
          next_list(width)
        endif
        print_title(_rec1_title)
        ft_goto(_rec)
      endif
    case _word1 == "#private"  // объявление PRIVATE-переменных
      _tmp := ltrim(substr(_tmp,9))
      for _k := 1 to numtoken(_tmp,",")
        aadd(_priv_arr, alltrim(token(_tmp,",",_k)))
      next
    case (_word1 == "#do" .and. _word2 == "while") .or. _word1 == "while"
      exec_do_while()
    case _word1 == "#loop"
      exec_loop()
    case _word1 == "#exit"
      exec_exit()
    case _word1 == "#enddo"
      exec_enddo()
    case _word1 == "#if"
      exec_if("if")
    case _word1 == "#elseif" .or. _word1 == "#else"
      scan_endif()
    case _word1 == "#var" .or. _word1 == "#i_var"
      // объявление переменных для печати документа
      _k := if(_word1 == "#var", 5, 7)
      if left((_tmp := ltrim(substr(_tmp,_k))),1) == "$"
        if (_k := at(" ",_tmp)) > 0
          aadd(_arr_var, { int(val(substr(_tmp,2))), ;
                           ltrim(substr(_tmp,_k)), ;
                           ft_recno(), ;
                           (_word1 == "#var");
                         };
              )
        endif
        if _word1 == "#var" ; _flag_var := .t.
        else ; _flag_i_var := .t.
        endif
      endif
    case _word1 == "#name"
      // пропустить наименование документа
    case _word1 == "#albom"    // альбомная печать
      yes_albom := .t.
    case _word1 == "#width"    // ширина документа
      width := int(val(_word2))
    case _word1 == "#height"   // кол-во строк на листе
      height := int(val(_word2))
    case _word1 == "#regim"    // режим печати (от 1 до 6)
      regim := int(val(_word2))
    case _word1 == "#outlist"  // выводить ли номер листа, начиная со 2-го
      outlist := .t.
    case _word1 == "#parameters" // формальные параметры
      _tmp := ltrim(substr(_tmp,12))
      for _k := 1 to numtoken(_tmp,",")
        aadd(_priv_arr, alltrim(token(_tmp,",",_k)))
      next
      _flag_param := .t.
    case _word1 == "#title" .or. _word1 == "#subtitle"  // заголовок
      if _word1 == "#title"
        _rec_title := ft_recno()
      elseif _word1 == "#subtitle"
        _rec1_title := ft_recno()
      endif
      ft_skip()
      do while !ft_eof()
        if lower(left(ltrim(_cur_string := ft_readln()),9)) == "#endtitle"
          exit
        endif
        ft_skip()
      enddo
    case _word1 == "#para_begin"  // начало форматируемого абзаца
      _tmp_string := ""
      ft_skip()
      do while !ft_eof()
        if lower(left(ltrim(_cur_string := ft_readln()),6)) == "#para_"
          ft_skip(-1) // назад на строку, если вместо #para_end
                      // стоит опять #para_begin
          exit
        endif
        if left(ltrim(_cur_string),2) != "//"  // пропустить комментарий
          _tmp_string += _cur_string + " "
        endif
        ft_skip()
      enddo
      _tmp_string := put_str_sh(_tmp_string,.f.)
      _tmp_string := para_format(_tmp_string,width,r_margin)
      for _k := 1 to textcount(_tmp_string)
        add_string(rtrim(textline(_tmp_string,_k)))
      next
    case _word1 == "#para_end"
      // окончание форматируемого абзаца
    case _word1 == "#r_margin" // выравнивать абзацы по правому краю
      r_margin := .t.
    case _word1 == "#release"  // удалить переменные #var и #i_var из памяти
      _arr_var := {} ; _flag_var := .f. ; _flag_i_var := .f.
    case _word1 == "#return"   // выйти из шаблона без дальнейшего
      _fl_return := .t.        // просмотра файла
  endcase
elseif left(ltrim(_cur_string),2) != "//"   // пропустить комментарий
  if _flag_1list
    _rec := ft_recno() ; _tmp_string := _cur_string
    // вывести заголовок первого листа
    if _rec_title == 0
      _rec_title := _rec1_title
    endif
    print_title(_rec_title)
    _flag_1list := .f.
    ft_goto(_rec) ; _cur_string := _tmp_string
  endif
  put_str_sh(_cur_string)
endif
return _priv_arr

*****
Static function print_title(_rec)
if _rec > 0
  ft_goto(_rec) ; ft_skip()
  do while !ft_eof()
    if lower(left(ltrim(_cur_string := ft_readln()),9)) == "#endtitle"
      exit
    elseif left(ltrim(_cur_string),2) != "//"   // пропустить комментарий
      put_str_sh(_cur_string)
    endif
    ft_skip()
  enddo
endif
return NIL

*****
Static Function put_str_sh(_s, _fl_out)
Local _j, _j1, _k := 1, _n, _s1, _mas_v := {}, _tmp_rec := ft_recno()
DEFAULT _fl_out TO .t.
if "$" $ _s
  if _flag_i_var // вставка переменных #i_var
    do while (_j := atnum("$",_s,_k)) > 0
      _s1 := "" ; _j1 := _j ; Inc( _j )
      do while substr(_s,_j,1) $ "0123456789"
        _s1 += substr(_s,_j,1)
        Inc( _j )
        if _j > len(_s)
          exit
        endif
      enddo
      _n := int(val(_s1))
      if (_j := ascan(_arr_var, {|x| x[1] == _n})) > 0 .and. !_arr_var[_j,4]
        aadd(_mas_v, {_j1, _n} )
      endif
      Inc( _k )
    enddo
    for _j := len(_mas_v) to 1 step -1
      if (_j1 := ascan(_arr_var, {|x| x[1] == _mas_v[_j,2]})) > 0
        ft_goto(_arr_var[_j1,3])
        _s1 := eval(COMPILE(_arr_var[_j1,2]))
        _s := stuff(_s, _mas_v[_j,1], len(lstr(_mas_v[_j,2]))+1, _s1)
      endif
    next
    _mas_v := {}
  endif
  if _flag_var  // замена переменных #var
    do while (_j := at("$",_s)) > 0
      _s1 := "" ; _j1 := _j
      do while substr(_s,_j,1) $ "$0123456789"
        _s1 += substr(_s,_j,1)
        posrepl(@_s, " ", _j)
        Inc( _j )
        if _j > len(_s)
          exit
        endif
      enddo
      aadd(_mas_v, {_j1, int(val(substr(_s1,2)))} )
    enddo
    _s += space(232)
    for _j := 1 to len(_mas_v)
      if (_j1 := ascan(_arr_var, {|x| x[1] == _mas_v[_j,2]})) > 0
        ft_goto(_arr_var[_j1,3])
        _s1 := eval(COMPILE(_arr_var[_j1,2]))
        posrepl(@_s, _s1, _mas_v[_j,1])
      endif
    next
  endif
  ft_goto(_tmp_rec)
endif
if _fl_out
  add_string(rtrim(_s))
endif
return rtrim(_s)

*****
Static Function exec_if(_s)     // Реализация оператора IF
Local _i := 0, usl := ltrim(afteratnum(_s,lower(_tmp),1))
if !&usl
  ft_skip()
  do while !ft_eof()
    if left(ltrim(_cur_string := ft_readln()),1) == "#"
      _tmp := ltrim(_cur_string)
      _word1 := lower(token(_tmp," ",1))
      if eq_any(_word1,"#if","#elseif","#else","#endif")
        if _word1 == "#if"
          Inc( _i )
        elseif _word1 == "#elseif" .and. _i == 0
          exec_if("elseif")
          exit
        elseif _word1 == "#else" .and. _i == 0
          exit
        elseif _word1 == "#endif"
          if _i > 0 ; Dec( _i )
          else     ; exit
          endif
        endif
      endif
    endif
    ft_skip()
  enddo
endif
return NIL

*****
Static Function scan_endif()  // найти последний оператор конструкции IF-ENDIF
Local _i := 0
ft_skip()
do while !ft_eof()
  if left(ltrim(_cur_string := ft_readln()),1) == "#"
    _tmp := ltrim(_cur_string)
    _word1 := lower(token(_tmp," ",1))
    do case
      case _word1 == "#if"
        Inc( _i )
      case _word1 == "#endif"
        if _i > 0
          Dec( _i )
        else
          exit
        endif
    endcase
  endif
  ft_skip()
enddo
return NIL

*****
Static Function exec_do_while()     // Реализация цикла DO WHILE
Local usl := ltrim(afteratnum("while",lower(_tmp),1))
if &usl        // если выполняется условие после #do while,
  aadd(_arr_do, ft_recno())  // то запомнить номер этой строки в стеке "DO"
else           // иначе пропустить весь цикл
  scan_enddo()
endif
return NIL

*****
Static Function exec_enddo()   // Реализация оператора ENDDO
Local _i, _klen
if (_klen := len(_arr_do)) == 0  // если не было оператора DO WHILE
  _i := 2 + "0"  // искусственно генерируем ошибку в данной строке
endif
_i := _arr_do[_klen]
if _klen == 1
  _arr_do := {}
else
  asize(_arr_do, _klen-1)
endif
ft_goto(_i-1)  // встать на строку, предшествующую DO WHILE
return NIL

*****
Static Function scan_enddo()  // найти последний оператор конструкции DO WHILE
Local _i := 0
ft_skip()
do while !ft_eof()
  if left(ltrim(_cur_string := ft_readln()),1) == "#"
    _tmp := ltrim(_cur_string)
    _word1 := lower(token(_tmp," ",1))
    _word2 := lower(token(_tmp," ",2))
    do case
      case _word1 == "#do" .and. _word2 == "while"
        Inc( _i )
      case _word1 == "#enddo"
        if _i > 0
          Dec( _i )
        else
          exit
        endif
    endcase
  endif
  ft_skip()
enddo
return NIL

*****
Static Function exec_exit()   // Реализация оператора EXIT (выход из цикла)
Local _i, _klen
if (_klen := len(_arr_do)) == 0  // если не было оператора DO WHILE
  _i := 2 + "0"  // искусственно генерируем ошибку в данной строке
endif
_i := _arr_do[_klen]
if _klen == 1
  _arr_do := {}
else
  asize(_arr_do, _klen-1)
endif
scan_enddo()
return NIL

*****
Static Function exec_loop()   // Реализация оператора LOOP (продолжение цикла)
exec_enddo()        // аналогично выполнению оператора #ENDDO
return NIL

***** если необходимо, сделать перевод страницы в шаблоне
Function formfeed(k)
DEFAULT k TO 0
if tek_stroke > height-k
  add_string("FF")
  n_list++ ; tek_stroke := 0
endif
return NIL
