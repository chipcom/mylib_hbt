#include "function.ch"
#include "comp_shb.ch"

***** Компилятор шаблонов
Function comp_shb(in_file,out_file)
Local i, k, _fp, _f_out, _s, err, fl_one, _buf := savescreen(), mas_err
mas_err := {"преждевременное появление FUNCTION", ;            // ERR__CTRL
            "преждевременное появление ENDDO",  ;              // ERR__ENDDO
            "преждевременное появление ELSE, ELSEIF, ENDIF", ; // ERR__ENDIF
            "ошибка записи в файл библиотеки", ;               // ERR__LIB
            "нет FUNCTION", ;                                  // ERR__FUNC
            "функция с таким именем уже определена" ;          // ERR__NAME
           }
Private _tmp_array := {}, _cur := 1, mas_save := {{},{}}, kol_func := 0, ;
        _j := 0, stack_stm := {}, i_level := 0, tip_stm, r_func, ;
        stack_ctr := stacknew(), stack_do := stacknew(), ;
        do_level := 0, s_cont := "", arr_function := {}

default in_file to "FUNCTION.DBU"      ////////////
//
// stack_stm
//      - тип оператора (do,if,exit ...)
//      - номер элемента в массиве
//      - номер строки в исходном файле
//      - уровень вложенности управляющей структуры
//  stack_ctr
//      - тип структуры предыдущего уровня (tip_stm := func, do, if)
if (fl_one := (type("CCOLORSTMS") != "C"))
  f_first()
endif
if !file(in_file)
  if fl_one
    restscreen(_buf)
    ?
    ? "На диске нет файла - "+in_file
    ?
    mybell(2,ERR)
  else
    func_error("На диске нет файла - "+in_file)
  endif
  return .f.
endif
if fl_one
  @ row(),0 say "COMP_SHB - line " color "W/N"
endif
if out_file == NIL
  out_file := substr(in_file,1,rat(".",in_file))+"dbc"  ////////////
endif
_f_out := fcreate(out_file)
// записать стандартный заголовок библиотеки
fwrite(_f_out,padr("BML("+chr(5)+chr(0)+chr(14),14,chr(0)))
_fp := fopen(in_file,0)
do while !feof(_fp)
  ++_j
  if fl_one
    @ row(),16 say lstr(_j) color "W+/N"
  endif
  _s := alltrim(fReadLn(_fp))
  if ( err := get_token(_s) ) == ERR__NO
    // продолжить
  elseif err == -1 // слово "RETURN"
    if len(mas_save[1]) > 0
      // осуществить запись в выходной файл (библиотеку)
      i := len(arr_function)
      arr_function[i,2] := fseek(_f_out,0,1)  // запомнить позицию начала ф-ии
      for i := 2 to len(mas_save[1])
        r_func := len(mas_save[2,i-1])
        mas_save[1,i-1,3] := mas_save[1,i,2] - 1
        if mas_save[2,i-1,r_func,2] <> T__RET
          aadd(mas_save[2,i-1], {mas_save[1,i-1,3],T__RET,"",99999})
        endif
      next
      mas_save[1,kol_func,3] := 99999
      r_func := len(mas_save[2,kol_func])
      if mas_save[2,kol_func,r_func,2] <> T__RET
        aadd(mas_save[2,kol_func], {mas_save[1,kol_func,3],T__RET,"",99999})
      endif
      if _ftsavesub(mas_save[2,1],_f_out) < 0 // записать содержимое функции
        err := ERR__LIB ; exit
      endif
      i := len(arr_function)
      k := fseek(_f_out,0,1)  // запомнить позицию конца ф-ии
      arr_function[i,3] := k - arr_function[i,2]  // запомнить длину ф-ии
    endif
    mas_save := {{},{}} ; kol_func := 0
  else
    exit  // выход по ошибке
  endif
enddo
fclose(_fp)
if err <= ERR__NO    // 0 или -1
  i := fseek(_f_out,0,1)  // запомнить позицию начала оглавления
  fseek(_f_out,10,0)   // встать на 11-й байт
  // записать позицию начала оглавления
  fwrite(_f_out,l2bin(i))
  fseek(_f_out,i,0)    // встать на начало оглавления
  // Структура оглавления библиотеки:
  for i := 1 to len(arr_function)
    // байт с 1 по 13: наименование ф-ии (дополнено справа символами chr(0))
    fwrite(_f_out,padr(arr_function[i,1],13,chr(0)))
    // следующие 3 байта: "B.."
    fwrite(_f_out,padr("B",3,chr(0)))
    // следующие 4 байта: позиция начала ф-ии в данной библиотеке
    fwrite(_f_out,l2bin(arr_function[i,2]))
    // следующие 4 байта: длина ф-ии в данной библиотеке
    fwrite(_f_out,l2bin(arr_function[i,3]))
  next
endif
fclose(_f_out)
if err > ERR__NO
  public_row_edit := _j     //////////////////////
  _flag_error := .t.        ////////////////
  if fl_one
    restscreen(_buf)
    ?
    ? "Ошибка в строке "+lstr(_j)+": "+mas_err[err]
    ?
    mybell(2,ERR)
  else
    func_error(4,"Ошибка в строке "+lstr(_j)+": "+mas_err[err])
  endif
  return .f.
endif
if fl_one
  restscreen(_buf)
  @ row(),0 say "COMP_SHB - сформирован файл " color "W/N"
  @ row(),col() say out_file color "W+/N"
  ?
endif
return .t.

*

*****
Static Function get_token(_s)
Local len_msave, _err := ERR__NO, _k
Private _tmp, _word1, _word2
//
if empty(_s) ; return _err ; endif     // пустая строка
if left(_s,1) == "*" ; return _err ; endif  // строка комментария
if left(_s,1) == "#" // строка #define, #line и т.п.
  if lower(left(_s,5)) == "#line"    // если были строки #include => #line
    _j := int(val(substr(_s,6))) - 1  // то скорректировать текущий номер строки
  endif
  return _err
endif
if (_k := at("//",_s)) > 0
  if _k == 1 ; return _err ; endif  // строка комментария
  _s := rtrim(left(_s, _k-1)) // отбросить комментарии в конце строки
endif
if right(_s,1) == ";"
  s_cont += rtrim(substr(_s,1,len(_s)-1))+" "
  return _err
else
  if len(s_cont) > 0
    _s := s_cont + _s
    s_cont := ""
  endif
endif
Private _cur_string := _s
_tmp := _s
_word1 := upper(token(_tmp," ",1))
_word2 := upper(token(_tmp," ",2))
do case
  case _word1 == "FUNCTION"
    _tmp := ltrim(substr(_tmp,10))
    if ascan(arr_function, {|x,i| upper(x[1]) == upper(_tmp)}) > 0
      return ERR__NAME
    endif
    if i_level == 0
      i_level := 0
      tip_stm := T__FUNC
      aadd(mas_save[1], {_tmp, _j, 0})
      aadd(arr_function, {_tmp,0,0})
      kol_func++
      aadd(mas_save[2], {})
      stack_stm := {}
      stack_ctr := stacknew()
      stack_do := stacknew()
      aadd(stack_stm, { T__FUNC, 0, _j, i_level} )
    else
      _err := ERR__CTRL
    endif
  case _word1 == "DO" .and. _word2 == "WHILE"
    _err := exec_do_while()
  case _word1 == "WHILE"  // если предварительно запущен препроцессор
    _err := exec_do_while()
  case _word1 == "LOOP"
   _err := exec_loop()
  case _word1 == "EXIT"
    _err := exec_exit()
  case _word1 == "ENDDO"
    _err := exec_enddo()
  case _word1 == "IF"
    _err := exec_if()
  case _word1 == "ELSEIF"
    _err := exec_elif()
  case _word1 == "ELSE"
    _err := exec_else()
  case _word1 == "ENDIF"
    _err := exec_endif()
  case _word1 == "PRIVATE" .or. _word1 == "LOCAL"
    if _word1 == "PRIVATE"
      _tmp := ltrim(substr(_tmp,9))
    else
      _tmp := ltrim(substr(_tmp,7))
    endif
    aadd(mas_save[2,kol_func],{_j,T__DEF,{},0})
    len_msave := len(mas_save[2,kol_func])
    for _k := 1 to numtoken(_tmp,",")
      aadd(mas_save[2,kol_func,len_msave,S__CONT], alltrim(token(_tmp,",",_k)) )
    next
    mas_save[2,kol_func,len_msave,4] := len_msave + 1
  case _word1 == "BLOCK"
    _tmp := ltrim(substr(_tmp,7))
    if (k := at(":=",_tmp)) > 0
      aadd(mas_save[2,kol_func],{_j,T__DEF,{rtrim(left(_tmp,k-1))},0})
      len_msave := len(mas_save[2,kol_func])
      mas_save[2,kol_func,len_msave,4] := len_msave + 1
      aadd(mas_save[2,kol_func], {_j,T__STM,;
        rtrim(left(_tmp,k-1))+':=comp_block("'+ltrim(substr(_tmp,k+2))+'")',0})
      len_msave := len(mas_save[2,kol_func])
      mas_save[2,kol_func,len_msave,4] := len_msave + 1
    endif
  case _word1 == "RETURN"   // выйти из шаблона без просмотра файла
    _tmp := ltrim(substr(_tmp,8))
    aadd(mas_save[2,kol_func],{_j,T__RET,_tmp,99999})
    if i_level == 0 // проверка на то, что оператор RETURN - последний в функции
      _err := -1   // !!!
    endif
  otherwise  // выполнение процедуры (синтаксис блока кода)
    aadd(mas_save[2,kol_func],{_j,T__STM,_tmp,0})
    len_msave := len(mas_save[2,kol_func])
    mas_save[2,kol_func,len_msave,4] := len_msave + 1
endcase
return _err

*

*****
Static Function exec_if()     // Реализация оператора IF
Local k_usl := atnum("IF",upper(_tmp),1), _err := ERR__NO , k
Local usl := ltrim(substr(_tmp,k_usl+2))
//
if len(stack_stm) == 0
  return ERR__FUNC
endif
aadd(mas_save[2,kol_func],{_j,T__IF,usl,0,0})
k := len(mas_save[2,kol_func])
mas_save[2,kol_func,k,4] := k + 1
i_level += 1
aadd(stack_stm, { T__IF, k, _j, i_level} )
stackpush(stack_ctr,tip_stm)
tip_stm := T__IF
return _err

*****
Static Function exec_elif()     // Реализация оператора ELSEIF
Local _err := ERR__NO, k
Local k_usl := atnum("ELSEIF",upper(_tmp),1)
Local usl := ltrim(substr(_tmp,k_usl+6))
//
if len(stack_stm) == 0
  return ERR__FUNC
endif
if tip_stm == T__DO
  return ERR__ENDIF
endif
aadd(mas_save[2,kol_func],{_j,T__GO,"",0})
aadd(mas_save[2,kol_func],{_j,T__ELIF,usl,0,0})
k := len(mas_save[2,kol_func])
mas_save[2,kol_func,k,4] := k + 1
aadd(stack_stm, { T__ELIF, k, _j, i_level} )
return _err

*****
Static Function exec_else()     // Реализация оператора ELSE
Local _err := ERR__NO, k
//
if len(stack_stm) == 0
  return ERR__FUNC
endif
if tip_stm == T__DO
  return ERR__ENDIF
endif
aadd(mas_save[2,kol_func],{_j,T__GO,"",0})
  aadd(mas_save[2,kol_func],{_j,T__ELIF,".t.",0,0})
//aadd(mas_save[2,kol_func],{_j,T__ELSE,"",0})
k := len(mas_save[2,kol_func])
  mas_save[2,kol_func,k,4] := k + 1
  aadd(stack_stm, { T__ELIF, k, _j, i_level} )
//aadd(stack_stm, { T__ELSE, k, _j, i_level} )
return _err

*****
Static Function exec_endif()  // обработка ENDIF
Local k, _err := ERR__NO, k_end
//
if len(stack_stm) == 0
  return ERR__FUNC
else
  k := stackgettop()
endif
if tip_stm == T__DO
  return ERR__ENDIF
endif
aadd(mas_save[2,kol_func],{_j,T__ENDIF,"",0})
k := len(mas_save[2,kol_func])
k_end := k + 1
mas_save[2,kol_func,k,4] := k_end
aadd(stack_stm, { T__ENDIF, k, _j, i_level} )
//
// найти все упр. операторы для данного i_level до начального if
//
for i := len(stack_stm) to 1 step -1                     // найти IF
  if stack_stm[i,4] == i_level .and. stack_stm[i,1] == T__IF
    mas_save[2,kol_func,stack_stm[i,2],5] := k
    tip_stm := stackpop(stack_ctr)
    exit
  endif
  if stack_stm[i,4] == i_level .and. stack_stm[i,1] == T__ELIF
    mas_save[2,kol_func,stack_stm[i,2],5] := k
    k := stack_stm[i,2]
    mas_save[2,kol_func,stack_stm[i,2],4] := k+1
    mas_save[2,kol_func,stack_stm[i,2]-1,4] := k_end      // пустышка
  endif
  if stack_stm[i,4] == i_level .and. stack_stm[i,1] == T__ELSE
    mas_save[2,kol_func,stack_stm[i,2],4] := k+1
    mas_save[2,kol_func,stack_stm[i,2]-1,4] := k_end      // пустышка
    k := stack_stm[i,2]
  endif
next
i_level -= 1
return _err

*

*****
Static Function exec_do_while()     // Реализация цикла DO WHILE
Local k, _err := ERR__NO
Local k_usl := atnum("WHILE",upper(_tmp),1)
Local usl := ltrim(substr(_tmp,k_usl+5))
//
if len(stack_stm) == 0
  return ERR__FUNC
endif
aadd(mas_save[2,kol_func],{_j,T__DO,usl,0,0})
k := len(mas_save[2,kol_func])
mas_save[2,kol_func,k,4] := k + 1
i_level += 1
stackpush(stack_do,do_level)
do_level := i_level
aadd(stack_stm, { T__DO, k, _j, i_level} )
stackpush(stack_ctr,tip_stm)
tip_stm := T__DO
return _err

*****
Static Function exec_enddo()   // Реализация оператора ENDDO
Local _err := ERR__NO, k
//
if len(stack_stm) == 0
  _err := ERR__FUNC
endif
if tip_stm == T__IF
  return ERR__ENDDO
endif
aadd(mas_save[2,kol_func],{_j,T__ENDDO,"",0})      // переход на DO WHILE
k := len(mas_save[2,kol_func])
aadd(stack_stm, { T__ENDDO, k, _j, i_level} )
//
//         найти все управляющие операторы DO - ENDDO данного уровня
//
for i := len(stack_stm) to 1 step -1                     // найти DO WHILE
  if stack_stm[i,4] == i_level .and. stack_stm[i,1] == T__DO
    mas_save[2,kol_func,k,4] := stack_stm[i,2]
    mas_save[2,kol_func,stack_stm[i,2],5] := k+1
    tip_stm := stackpop(stack_ctr)
//    k := i
    exit
  endif
  if stack_stm[i,4] == do_level .and. stack_stm[i,1] == T__EXIT
    mas_save[2,kol_func,stack_stm[i,2],4] := k+1
  endif
next
i_level -= 1
do_level := stackpop(stack_do)
return _err

*****
Static Function exec_exit()   // Реализация оператора EXIT (выход из цикла)
Local _err := ERR__NO, k
//
if len(stack_stm) == 0
  _err := ERR__FUNC
endif
aadd(mas_save[2,kol_func],{_j,T__EXIT,"",0})       // выход за ENDDO
k := len(mas_save[2,kol_func])
aadd(stack_stm, { T__EXIT, k, _j, do_level} )
return _err

*****
Static Function exec_loop()   // Реализация оператора LOOP (продолжение цикла)
Local _err := ERR__NO, k, i
//
if len(stack_stm) == 0
  _err := ERR__FUNC
endif
aadd(mas_save[2,kol_func],{_j,T__LOOP,"",0})       // переход на DO WHILE
k := len(mas_save[2,kol_func])
aadd(stack_stm, { T__LOOP, k, _j, do_level} )
for i := len(stack_stm) to 1 step -1                     // найти DO WHILE
  if stack_stm[i,4] == do_level .and. stack_stm[i,1] == T__DO
    mas_save[2,kol_func,k,4] := stack_stm[i,2]
    exit
  endif
next
return _err
