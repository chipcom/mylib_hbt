#include "function.ch"
#include "comp_shb.ch"

***** ��������� 蠡�����
Function comp_shb(in_file,out_file)
Local i, k, _fp, _f_out, _s, err, fl_one, _buf := savescreen(), mas_err
mas_err := {"�०���६����� ������ FUNCTION", ;            // ERR__CTRL
            "�०���६����� ������ ENDDO",  ;              // ERR__ENDDO
            "�०���६����� ������ ELSE, ELSEIF, ENDIF", ; // ERR__ENDIF
            "�訡�� ����� � 䠩� ������⥪�", ;               // ERR__LIB
            "��� FUNCTION", ;                                  // ERR__FUNC
            "�㭪�� � ⠪�� ������ 㦥 ��।�����" ;          // ERR__NAME
           }
Private _tmp_array := {}, _cur := 1, mas_save := {{},{}}, kol_func := 0, ;
        _j := 0, stack_stm := {}, i_level := 0, tip_stm, r_func, ;
        stack_ctr := stacknew(), stack_do := stacknew(), ;
        do_level := 0, s_cont := "", arr_function := {}

default in_file to "FUNCTION.DBU"      ////////////
//
// stack_stm
//      - ⨯ ������ (do,if,exit ...)
//      - ����� ������� � ���ᨢ�
//      - ����� ��ப� � ��室��� 䠩��
//      - �஢��� ���������� �ࠢ���饩 ��������
//  stack_ctr
//      - ⨯ �������� �।��饣� �஢�� (tip_stm := func, do, if)
if (fl_one := (type("CCOLORSTMS") != "C"))
  f_first()
endif
if !file(in_file)
  if fl_one
    restscreen(_buf)
    ?
    ? "�� ��᪥ ��� 䠩�� - "+in_file
    ?
    mybell(2,ERR)
  else
    func_error("�� ��᪥ ��� 䠩�� - "+in_file)
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
// ������� �⠭����� ��������� ������⥪�
fwrite(_f_out,padr("BML("+chr(5)+chr(0)+chr(14),14,chr(0)))
_fp := fopen(in_file,0)
do while !feof(_fp)
  ++_j
  if fl_one
    @ row(),16 say lstr(_j) color "W+/N"
  endif
  _s := alltrim(fReadLn(_fp))
  if ( err := get_token(_s) ) == ERR__NO
    // �த������
  elseif err == -1 // ᫮�� "RETURN"
    if len(mas_save[1]) > 0
      // �����⢨�� ������ � ��室��� 䠩� (������⥪�)
      i := len(arr_function)
      arr_function[i,2] := fseek(_f_out,0,1)  // ��������� ������ ��砫� �-��
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
      if _ftsavesub(mas_save[2,1],_f_out) < 0 // ������� ᮤ�ন��� �㭪樨
        err := ERR__LIB ; exit
      endif
      i := len(arr_function)
      k := fseek(_f_out,0,1)  // ��������� ������ ���� �-��
      arr_function[i,3] := k - arr_function[i,2]  // ��������� ����� �-��
    endif
    mas_save := {{},{}} ; kol_func := 0
  else
    exit  // ��室 �� �訡��
  endif
enddo
fclose(_fp)
if err <= ERR__NO    // 0 ��� -1
  i := fseek(_f_out,0,1)  // ��������� ������ ��砫� ����������
  fseek(_f_out,10,0)   // ����� �� 11-� ����
  // ������� ������ ��砫� ����������
  fwrite(_f_out,l2bin(i))
  fseek(_f_out,i,0)    // ����� �� ��砫� ����������
  // ������� ���������� ������⥪�:
  for i := 1 to len(arr_function)
    // ���� � 1 �� 13: ������������ �-�� (��������� �ࠢ� ᨬ������ chr(0))
    fwrite(_f_out,padr(arr_function[i,1],13,chr(0)))
    // ᫥���騥 3 ����: "B.."
    fwrite(_f_out,padr("B",3,chr(0)))
    // ᫥���騥 4 ����: ������ ��砫� �-�� � ������ ������⥪�
    fwrite(_f_out,l2bin(arr_function[i,2]))
    // ᫥���騥 4 ����: ����� �-�� � ������ ������⥪�
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
    ? "�訡�� � ��ப� "+lstr(_j)+": "+mas_err[err]
    ?
    mybell(2,ERR)
  else
    func_error(4,"�訡�� � ��ப� "+lstr(_j)+": "+mas_err[err])
  endif
  return .f.
endif
if fl_one
  restscreen(_buf)
  @ row(),0 say "COMP_SHB - ��ନ஢�� 䠩� " color "W/N"
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
if empty(_s) ; return _err ; endif     // ����� ��ப�
if left(_s,1) == "*" ; return _err ; endif  // ��ப� ���������
if left(_s,1) == "#" // ��ப� #define, #line � �.�.
  if lower(left(_s,5)) == "#line"    // �᫨ �뫨 ��ப� #include => #line
    _j := int(val(substr(_s,6))) - 1  // � ᪮�४�஢��� ⥪�騩 ����� ��ப�
  endif
  return _err
endif
if (_k := at("//",_s)) > 0
  if _k == 1 ; return _err ; endif  // ��ப� ���������
  _s := rtrim(left(_s, _k-1)) // ������ �������ਨ � ���� ��ப�
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
  case _word1 == "WHILE"  // �᫨ �।���⥫쭮 ����饭 �९�����
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
  case _word1 == "RETURN"   // ��� �� 蠡���� ��� ��ᬮ�� 䠩��
    _tmp := ltrim(substr(_tmp,8))
    aadd(mas_save[2,kol_func],{_j,T__RET,_tmp,99999})
    if i_level == 0 // �஢�ઠ �� �, �� ������ RETURN - ��᫥���� � �㭪樨
      _err := -1   // !!!
    endif
  otherwise  // �믮������ ��楤��� (ᨭ⠪�� ����� ����)
    aadd(mas_save[2,kol_func],{_j,T__STM,_tmp,0})
    len_msave := len(mas_save[2,kol_func])
    mas_save[2,kol_func,len_msave,4] := len_msave + 1
endcase
return _err

*

*****
Static Function exec_if()     // ��������� ������ IF
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
Static Function exec_elif()     // ��������� ������ ELSEIF
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
Static Function exec_else()     // ��������� ������ ELSE
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
Static Function exec_endif()  // ��ࠡ�⪠ ENDIF
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
// ���� �� ��. ������� ��� ������� i_level �� ��砫쭮�� if
//
for i := len(stack_stm) to 1 step -1                     // ���� IF
  if stack_stm[i,4] == i_level .and. stack_stm[i,1] == T__IF
    mas_save[2,kol_func,stack_stm[i,2],5] := k
    tip_stm := stackpop(stack_ctr)
    exit
  endif
  if stack_stm[i,4] == i_level .and. stack_stm[i,1] == T__ELIF
    mas_save[2,kol_func,stack_stm[i,2],5] := k
    k := stack_stm[i,2]
    mas_save[2,kol_func,stack_stm[i,2],4] := k+1
    mas_save[2,kol_func,stack_stm[i,2]-1,4] := k_end      // �����誠
  endif
  if stack_stm[i,4] == i_level .and. stack_stm[i,1] == T__ELSE
    mas_save[2,kol_func,stack_stm[i,2],4] := k+1
    mas_save[2,kol_func,stack_stm[i,2]-1,4] := k_end      // �����誠
    k := stack_stm[i,2]
  endif
next
i_level -= 1
return _err

*

*****
Static Function exec_do_while()     // ��������� 横�� DO WHILE
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
Static Function exec_enddo()   // ��������� ������ ENDDO
Local _err := ERR__NO, k
//
if len(stack_stm) == 0
  _err := ERR__FUNC
endif
if tip_stm == T__IF
  return ERR__ENDDO
endif
aadd(mas_save[2,kol_func],{_j,T__ENDDO,"",0})      // ���室 �� DO WHILE
k := len(mas_save[2,kol_func])
aadd(stack_stm, { T__ENDDO, k, _j, i_level} )
//
//         ���� �� �ࠢ���騥 ������� DO - ENDDO ������� �஢��
//
for i := len(stack_stm) to 1 step -1                     // ���� DO WHILE
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
Static Function exec_exit()   // ��������� ������ EXIT (��室 �� 横��)
Local _err := ERR__NO, k
//
if len(stack_stm) == 0
  _err := ERR__FUNC
endif
aadd(mas_save[2,kol_func],{_j,T__EXIT,"",0})       // ��室 �� ENDDO
k := len(mas_save[2,kol_func])
aadd(stack_stm, { T__EXIT, k, _j, do_level} )
return _err

*****
Static Function exec_loop()   // ��������� ������ LOOP (�த������� 横��)
Local _err := ERR__NO, k, i
//
if len(stack_stm) == 0
  _err := ERR__FUNC
endif
aadd(mas_save[2,kol_func],{_j,T__LOOP,"",0})       // ���室 �� DO WHILE
k := len(mas_save[2,kol_func])
aadd(stack_stm, { T__LOOP, k, _j, do_level} )
for i := len(stack_stm) to 1 step -1                     // ���� DO WHILE
  if stack_stm[i,4] == do_level .and. stack_stm[i,1] == T__DO
    mas_save[2,kol_func,k,4] := stack_stm[i,2]
    exit
  endif
next
return _err
