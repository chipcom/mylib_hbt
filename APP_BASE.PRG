#include "set.ch"
#include "inkey.ch"
#include "function.ch"

#define A_B dir_server+"app_base"
#define LEN_NAME 30

***** инициализация дополнительной БД
Function AB_init()
Local adbf := {;
   {"BASE",   "N",       1, 0},;
   {"KOD",    "N",       6, 0},;
   {"STROKE", "C",       1, 0},;
   {"NAME",   "C",LEN_NAME, 0};
  }
reconstruct(A_B,adbf,"AB_index(1)","APP_BASE",.t.)
return NIL

***** Индекс для доп.БД
Function AB_index(k)
Local buf, lOldDeleted := SET(_SET_DELETED, .F.)
DEFAULT k TO 0  // для переиндексирования из программы
if k == 0
  G_Use(A_B,,"APP_B",.t.,.t.)
  buf := save_maxrow()
  mywait("Упаковка БД APP_BASE.DBF")
  pack
  rest_box(buf)
endif
index on str(base,1)+str(kod,6)+stroke to (A_B) progress
if k == 0
  AB_close()
endif
SET(_SET_DELETED, lOldDeleted)  // Восстановление среды
return NIL

***** открыть доп.БД
Function AB_open()
G_Use(A_B,A_B,"APP_B")
return NIL

***** закрыть доп.БД
Function AB_close()
app_b->(dbCloseArea())
return NIL

*

***** прочитать запись номер _i_kod для таблицы _i_base в доп.БД
Function AB_read(_i_base,_i_kod,_is_open)
Local s := "", tmp_select := select()
DEFAULT _is_open TO .f.
if _is_open
  select APP_B
else
  AB_open()
endif
find (str(_i_base,1)+str(_i_kod,6))
do while app_b->base == _i_base .and. app_b->kod == _i_kod
  s += app_b->name
  skip
enddo
if !_is_open
  AB_close()
endif
if tmp_select > 0
  select (tmp_select)
endif
return AB_getFields(s)

***** разобрать строку на составляющие поля
Function AB_getFields(_s_)
Local _ret_ := {}, i, j, k, c, _n, _l
if len(_s_) > 0
  // Структура строки в БД APP_B
  // 1б - кол-во полей
  //   1б - номер поля в БД  \
  //   1б - тип поля, "CND"   |__ для каждого
  //   2б - начало поля offset|   поля (6б)
  //   2б - длина поля (N)   /
  // Nб - содержимое каждого поля
  k := asc(left(_s_,1))
  _ret_ := array(k,3)
  for i := 1 to k
    j := 6*(i-1)+2  // начало блока описателя поля
    _ret_[i,1] := asc( substr(_s_,j,1) )  // номер поля в БД
    _ret_[i,2] := substr(_s_,j+1,1)       // тип поля
    _n := bin2i( substr(_s_,j+2,2) )
    _l := bin2i( substr(_s_,j+4,2) )
    c := substr(_s_,_n,_l)                // содержимое поля
    do case
      case _ret_[i,2] == "N"
        c := val(c)
      case _ret_[i,2] == "D"
        c := c4tod(c)
    endcase
    _ret_[i,3] := c
  next
endif
return _ret_

*

***** записать массив полей в доп.БД
Function AB_write(_ar_,_i_base,_i_kod,_is_open,_is_commit)
Local s, _l, i, j, k, _ta, tmp_select := select()
DEFAULT _is_open TO .f., _is_commit TO .t.
if (_l := len(s := AB_putFields(_ar_))) == 0
  return .f.  // ошибка записи!
endif
_ar_ := {} ; k := 1
do while k <= _l
  aadd(_ar_, substr(s,k,LEN_NAME) )
  k += LEN_NAME
enddo
if _is_open
  select APP_B
else
  AB_open()
endif
_ta := {}
find (str(_i_base,1)+str(_i_kod,6))
do while app_b->base == _i_base .and. app_b->kod == _i_kod
  aadd(_ta, app_b->(recno()) )
  skip
enddo
j := len(_ta)
for i := 1 to min(255,len(_ar_))
  if j > 0
    goto (_ta[j])
    G_RLock(forever)
    --j
  else
    AddRec(1)
  endif
  app_b->BASE := _i_base
  app_b->KOD := _i_kod
  app_b->STROKE := chr(i)
  app_b->NAME := _ar_[i]
  UnLock
next
// удаление остатков
for i := 1 to j
  goto (_ta[i])
  DeleteRec(.t.)
next
if _is_commit
  app_b->(dbCommit())
endif
if !_is_open
  AB_close()
endif
if tmp_select > 0
  select (tmp_select)
endif
return .t.

***** составить строку из составляющих полей
Function AB_putFields(_arr_)
Local i, j, k, c, _v, _n, _l, s := "", s1 := ""
if (k := len(_arr_)) > 255
  return ""
endif
s := chr(k)  // кол-во полей
j := 6*k + 2
for i := 1 to k
  do case
    case _arr_[i,2] == "N"
      _v := alltrim(str_0(_arr_[i,3],20,3))
    case _arr_[i,2] == "D"
      _v := dtoc4(_arr_[i,3])
    otherwise
      _v := alltrim(_arr_[i,3])
      if len(_v) == 0
        _v := " "
      endif
  endcase
  _l := len(_v)
  s += chr(_arr_[i,1])+;  //   1б - номер поля в БД  \
       _arr_[i,2]+;       //   1б - тип поля, "CND"   |__ для каждого
       i2bin(j)+;         //   2б - начало поля offset|   поля (6б)
       i2bin(_l)          //   2б - длина поля (N)   /
  j += _l
  s1 += _v
next
return s + s1

***** удалить запись(и) в доп.БД
Function AB_delete(_i_base,_i_kod,_is_open,_is_commit)
Local k := 0, tmp_select := select()
DEFAULT _is_open TO .f., _is_commit TO .t.
if _is_open
  select APP_B
else
  AB_open()
endif
do while .t.
  find (str(_i_base,1)+str(_i_kod,6))
  if !found() ; exit ; endif
  DeleteRec(.t.)
  ++k
enddo
if k > 0 .and. _is_commit
  app_b->(dbCommit())
endif
if !_is_open
  AB_close()
endif
if tmp_select > 0
  select (tmp_select)
endif
return .t.
