#include "fileio.ch"
#include "function.ch"
#include "comp_shb.ch"
#include "error.ch"

// �᫨ �ᯮ������� �㭪樨, ����� ����� ����� �� ��뢠����
// � �ணࠬ��, ��। �맮��� exec_shb() �� ����室��� �����, ��� EXTERNAL

Static _arr_function, _in_file, _old_file

EXTERNAL comp_block

***************************
function exec_shb(func_name)
local tmp_arr, _i, _par_array, _j, _k, in_file, cMessage, buf, ;
      _fp, buf4 := space(4), buf13 := space(13), offset, nl
if type("task_shb") == "C"    // Public-��६����� � �����
  in_file := upper(task_shb)
else
  in_file := "FUNCTION.CHB"
endif
if _arr_function == NIL .or. !(_old_file == in_file)
  if (_in_file := search_file(in_file)) == NIL
    func_error(4,"�� �����㦥� 䠩� "+in_file)
    return 0
  endif
  _fp := fopen(_in_file,FO_READ+FO_SHARED)  // ������ 䠩� ������⥪�
  fseek(_fp,10,0)         // ����� �� 11-� ����
  fread(_fp,@buf4,4)      // ��� ��室����
  offset := bin2l(buf4)   //    ��砫� ���������� ?
  fseek(_fp,offset,0)     // ����� �� ��砫� ���������� ������⥪�
  _arr_function := {}
  do while .t.
    if fread(_fp,@buf13,13) != 13
      exit
    endif
    nl := 13
    for _i := len(buf13) to 1 step -1
      if substr(buf13,_i,1) == chr(0)
        nl := _i-1
      endif
    next
    aadd(_arr_function, {left(buf13,nl),0,0} )  // �������� �㭪樨
    _i := len(_arr_function)
    fseek(_fp,3,1)  // �ய����� 3 ᨬ����
    fread(_fp,@buf4,4)
    _arr_function[_i,2] := bin2l(buf4)  // ������ ��砫� �㭪樨
    fread(_fp,@buf4,4)
    _arr_function[_i,3] := bin2l(buf4)  // ࠧ��� �㭪樨 � �����
  enddo
  fclose(_fp)
  _old_file := in_file
endif
func_name := upper(alltrim(func_name))
if (_i := ascan(_arr_function, {|x,i| func_name == upper(x[1])})) == 0
  func_error(4,"� 䠩�� "+in_file+" ��� �㭪樨 "+func_name)
  return 0
endif
buf := savescreen()
private _tmp_array, _cur := 1
_fp := fopen(_in_file,FO_READ+FO_SHARED)  // ������ 䠩� ������⥪�
fseek(_fp,_arr_function[_i,2],0)     // ����� �� ��砫� �㭪樨
_tmp_array := _ftrestsub(_fp)  // ����� ⥫� �㭪樨 � ���ᨢ
fclose(_fp)
private bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
private usl, _tmp1, _fl_return := .f., _param_return := 0
BEGIN SEQUENCE
do while .t.
  do case
    case _tmp_array[_cur,S__TYPE] == T__RET
      _fl_return := .t.
      usl := _tmp_array[_cur,S__CONT]
      _param_return := eval( COMPILE( usl ) )
    case _tmp_array[_cur,S__TYPE] == T__DEF
      _j := len(_tmp_array[_cur,S__CONT])
      if _j > 0
        for _k := 1 to _j
          _tmp1 := _tmp_array[_cur,S__CONT,_k]
          Private &_tmp1
        next
      endif
      _cur := _tmp_array[_cur,S__NEXT]
    case _tmp_array[_cur,S__TYPE] == T__STM
      usl := _tmp_array[_cur,S__CONT]
      eval( COMPILE( usl ) )
      _cur := _tmp_array[_cur,S__NEXT]
    case (_tmp_array[_cur,S__TYPE] == T__DO) .or.  ;
         (_tmp_array[_cur,S__TYPE] == T__IF) .or.  ;
         (_tmp_array[_cur,S__TYPE] == T__ELIF)
      usl := _tmp_array[_cur,S__CONT]
      if &usl
        _cur := _tmp_array[_cur,S__NEXT]
      else
        _cur := _tmp_array[_cur,S__JUMP]
      endif
    case (_tmp_array[_cur,S__TYPE] == T__ENDDO) .or. ;
         (_tmp_array[_cur,S__TYPE] == T__EXIT)  .or. ;
         (_tmp_array[_cur,S__TYPE] == T__LOOP)  .or. ;
         (_tmp_array[_cur,S__TYPE] == T__ELSE)  .or. ;
         (_tmp_array[_cur,S__TYPE] == T__ENDIF) .or. ;
         (_tmp_array[_cur,S__TYPE] == T__GO)
      _cur := _tmp_array[_cur,S__NEXT]
  endcase
  if _fl_return ; exit ; endif
enddo
RECOVER USING error
  cMessage := ErrorMessage(error)
  _tmp := "�訡�� � "+lstr(_tmp_array[_cur,1])+" ��ப� 䠩�� "+in_file
  func_error(4,_tmp)
  func_error(4,cMessage)
  if type("DIR_SERVER") != "C"
    Private dir_server := ""
  endif
  _tmp := dtoc(date())+"  "+sectotime(seconds())+"  "+StripPath(exename())+;
          eos+_tmp+eos+cMessage+eos+replicate("*",79)+eos
  strfile(_tmp,dir_server+"error.txt",.t.)
END
ERRORBLOCK(bSaveHandler)
del_err_compiler()
restscreen(buf)
return _param_return
