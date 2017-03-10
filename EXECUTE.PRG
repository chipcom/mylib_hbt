#include "fileio.ch"
#include "inkey.ch"
#include "function.ch"

// если используются функции, которые больше нигде не вызываются
// в программе, перед вызовом execute() их необходимо объявить, как EXTERNAL

EXTERNAL comp_block

Static _arr_function
Static __in_file := "FUNCTION.SHB"

***** выполнить функцию из файла "FUNCTION.SHB"
Function execute(func_name)
// func_name  - наименование функции (строка в кавычках) (можно по русски)
Local _i, _j := 0, _blk, _fp, _s, _par_array, _in_file, cMessage
if _arr_function == NIL
  if (_in_file := search_file(__in_file)) == NIL
    func_error(4,"Не обнаружен файл "+__in_file)
    return 0
  endif
  _i := 0
  _arr_function := {}
  _blk := {|s| ++_i, s := upper(alltrim(s)), ;
               if(left(s,8) == "FUNCTION", ;
                      aadd(_arr_function, {ltrim(substr(s,9)),_i,0}), NIL) ;
          }
  feval(_in_file, _blk)
  for _i := 2 to len(_arr_function)
    _arr_function[_i-1,3] := _arr_function[_i,2] - 1
  next
  if len(_arr_function) > 0
    _arr_function[len(_arr_function),3] := 99999
  endif
endif
func_name := upper(func_name)
if (_i := ascan(_arr_function, {|x| func_name == x[1]})) == 0
  func_error(4,"В файле "+__in_file+" нет функции "+func_name)
  return 0
endif
Private _tmp_array := {}, _cur := 1
_fp := fopen(_in_file, FO_READ + FO_SHARED)
//_fp := fopen(_in_file, FO_READ )
do while _j <= _arr_function[_i,3] .and. !feof(_fp)
  Inc( _j )
  _s := fReadLn(_fp)
  if between(_j, _arr_function[_i,2], _arr_function[_i,3])
    aadd( _tmp_array, upper(ltrim(_s)) )
  endif
enddo
fclose(_fp)
private bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
private _tmp, _tmp1, _arr_do := {}, _arr_if := {}, _word1, _word2, _k, ;
        _arr_var := {}, _fl_return := .f., _param_return := 0
BEGIN SEQUENCE
do while _cur <= len(_tmp_array)
  if len(_par_array := get_token(_tmp_array[_cur])) > 0
    for _k := 1 to len(_par_array)
      _tmp1 := _par_array[_k]
      Private &_tmp1
    next
  endif
  if _fl_return ; exit ; endif
  Inc( _cur )
enddo
RECOVER USING error
  cMessage := ErrorMessage(error)
  _tmp := "Ошибка в "+lstr(_arr_function[_i,2]+_cur-1)+;
                                            " строке файла "+__in_file
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
del_err_compiler()
return _param_return

*****
Static Function get_token(_s)
Local _priv_arr := {}, _rec, _tmp_string
if left(_s,1) == "*" ; return {} ; endif  // строка кмментария
if (_k := at("//",_s)) > 0
  if _k == 1 ; return {} ; endif  // строка кмментария
  _s := rtrim(left(_s, _k-1)) // отбросить комментарии в конце строки
endif
Private _cur_string := _s
_tmp := _s
_word1 := token(_tmp," ",1)
_word2 := token(_tmp," ",2)
do case
  case _word1 == "FUNCTION"
    //
  case _word1 == "DO" .and. _word2 == "WHILE"
    exec_do_while()
  case _word1 == "LOOP"
    exec_loop()
  case _word1 == "EXIT"
    exec_exit()
  case _word1 == "ENDDO"
    exec_enddo()
  case _word1 == "IF"
    exec_if("IF")
  case _word1 == "ELSEIF" .or. _word1 == "ELSE"
    scan_endif()
  case _word1 == "ENDIF"
    //
  case _word1 == "PRIVATE"  // объявление PRIVATE-переменных
    _tmp := ltrim(substr(_tmp,9))
    for _k := 1 to numtoken(_tmp,",")
      aadd(_priv_arr, alltrim(token(_tmp,",",_k)))
    next
  case _word1 == "LOCAL"   // объявление LOCAL-переменных
    _tmp := ltrim(substr(_tmp,7))
    for _k := 1 to numtoken(_tmp,",")
      aadd(_priv_arr, alltrim(token(_tmp,",",_k)))
    next
  case _word1 == "RETURN"   // выйти из шаблона без просмотра файла
    _fl_return := .t.
    _tmp := ltrim(substr(_tmp,8))
    _param_return := eval( COMPILE( _tmp ) )
  otherwise  // выполнение процедуры (синтаксис блока кода)
    eval( COMPILE( _tmp ) )
endcase
return _priv_arr

*****
Static Function exec_if(_s)     // Реализация оператора IF
Local _i := 0, usl := ltrim(afteratnum(_s,_tmp,1))
if !&usl
  Inc( _cur )
  do while _cur <= len(_tmp_array)
    _tmp := _cur_string := _tmp_array[_cur]
    _word1 := token(_tmp," ",1)
    if _word1 == "IF" .or. _word1 == "ELSEIF" .or. ;
                              _word1 == "ELSE" .or. _word1 == "ENDIF"
      if _word1 == "IF"
        Inc( _i )
      elseif _word1 == "ELSEIF" .and. _i == 0
        exec_if("ELSEIF")
        exit
      elseif _word1 == "ELSE" .and. _i == 0
        exit
      elseif _word1 == "ENDIF"
        if _i > 0 ; Dec( _i )
        else     ; exit
        endif
      endif
    endif
    _cur++
  enddo
endif
return NIL

*****
Static Function scan_endif()  // найти последний оператор конструкции IF-ENDIF
Local _i := 0
Inc( _cur )
do while _cur <= len(_tmp_array)
  _tmp := _cur_string := _tmp_array[_cur]
  _word1 := token(_tmp," ",1)
  do case
    case _word1 == "IF"
      Inc( _i )
    case _word1 == "ENDIF"
      if _i > 0
        Dec( _i )
      else
        exit
      endif
  endcase
  Inc( _cur )
enddo
return NIL

*****
Static Function exec_do_while()     // Реализация цикла DO WHILE
Local usl := ltrim(afteratnum("WHILE",_tmp,1))
if &usl
  aadd(_arr_do, _cur)
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
_cur := _i-1  // встать на строку, предшествующую DO WHILE
return NIL

*****
Static Function scan_enddo()  // найти последний оператор конструкции DO WHILE
Local _i := 0
Inc( _cur )
do while _cur <= len(_tmp_array)
  _tmp := _cur_string := _tmp_array[_cur]
  _word1 := token(_tmp," ",1)
  _word2 := token(_tmp," ",2)
  do case
    case _word1 == "DO" .and. _word2 == "WHILE"
      Inc( _i )
    case _word1 == "ENDDO"
      if _i > 0
        Dec( _i )
      else
        exit
      endif
  endcase
  Inc( _cur )
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
exec_enddo()
return NIL
