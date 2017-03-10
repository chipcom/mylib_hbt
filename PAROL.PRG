#include "inkey.ch"
#include "function.ch"
#include "edit_spr.ch"

// inp_password() - в модуле main()
// для ввода/редактирования
//               aadd(first_menu,   "Па~роли")
//               aadd(first_message,"Редактирование паролей")
//               aadd(func_menu,    "edit_pass()")
// init_pass() - в ф-ии initializ()

*****
Function edit_pass(k)
Static si1 := 1
Local mas_pmt, mas_msg, mas_fun, j
DEFAULT k TO 1
do case
  case k == 1
    mas_pmt := {"~Редактирование",;
                "~Добавление",;
                "~Удаление"}
    mas_msg := {"Редактирование паролей (уровней доступа)",;
                "Добавление паролей",;
                "Удаление паролей"}
    mas_fun := {"edit_pass(11)",;
                "edit_pass(12)",;
                "edit_pass(13)"}
    popup_prompt(T_ROW,T_COL-7,si1,mas_pmt,mas_msg,mas_fun)
  case k == 11
    edit1_pass(A__EDIT)
  case k == 12
    edit1_pass(A__APPEND)
  case k == 13
    edit1_pass(A__DELETE)
endcase
if k > 10
  j := int(val(right(lstr(k),1)))
  if between(k,11,19)
    si1 := j
  endif
endif
return NIL

*****
Function inp_password()
Local pss := space(10), i, fl, tmp_pss := my_parol(),;
      tmp_select := select(), pr, pw
Public TIP_ADM := 0, TIP_OPER := 1
Public kod_polzovat := 0, tip_polzovat := TIP_ADM, gpasskod := ret_gpasskod()
Public pravo_read := .t., pravo_write := .t.
pss := get_parol()
if lastkey() == K_ESC
  f_end()
else
  mywait()
  if ascan(tmp_pss, crypt(pss,gpasskod)) == 0
    pss := padr(crypt(pss,gpasskod),10)
    if !hb_FileExists(dir_server+"base1.dbf")
      // БД паролей отсутствует => администратор
    elseif R_Use(dir_server+"base1",,"B1",.t.)
      COUNT TO i FOR !empty(fio)
      if i == 0
        // БД паролей пуста => администратор
        b1->(dbCloseArea())
      else
        locate for b1->password == pss .and. !empty(b1->fio)
        if (fl := found())
          kod_polzovat := recno()
          tip_polzovat := int(val(crypt(b1->tip_dostup,gpasskod)))
          oper_parol := int(val(crypt(pss,gpasskod)))
        endif
        b1->(dbCloseArea())
        if !fl
          func_error("Пароль не зарегистрирован. Нет прав доступа к системе!")
          f_end()
        endif
      endif
    else
      func_error("В данный момент нет доступа к системе!")
      f_end()
    endif
  endif
endif
keyboard ""
if tmp_select > 0
  select (tmp_select)
endif
Return tip_polzovat

*****
Function edit1_pass(reg)
Local tm, mfio, mt, mp, mr, md, i, str_sem
if tip_polzovat != TIP_ADM
  return func_error(4,"Оператору доступ в данный режим запрещен!")
endif
delete file tmp.dbf
init_base("tmp",,gmenu_passw,0)
if reg == A__APPEND
  use tmp
  zap
  close databases
  if f_edit_spr(reg,gmenu_passw,"оператору","G_Use('tmp')",0,0) > 0
    use tmp
    mfio := crypt(tmp->fio,gpasskod)
    mt :=   crypt(str(tmp->tip_dostup,1),gpasskod)
    mp :=   crypt(tmp->password,gpasskod)
    G_Use(dir_server+"base1")
    locate for empty(fio)
    if !found()
      G_RLock("forever",.t.)
    else
      G_RLock("forever")
    endif
    replace fio with mfio, tip_dostup with mt, password with mp
    close databases
  endif
elseif (tm := input_fio(T_ROW,T_COL-7)) != NIL
  use tmp
  zap
  append blank
  replace fio with tm[1], tip_dostup with tm[2], password with tm[3]
  close databases
  if f_edit_spr(reg,gmenu_passw,"оператору","G_Use('tmp')",0,1) > 0
    if reg == A__EDIT
      use tmp
      mfio := crypt(tmp->fio,gpasskod)
      mt :=   crypt(str(tmp->tip_dostup,1),gpasskod)
      mp :=   crypt(tmp->password,gpasskod)
      G_Use(dir_server+"base1")
      goto (glob_passw)
      G_RLock("forever")
      replace fio with mfio, tip_dostup with mt, password with mp
      UNLOCK
      close databases
    else
      G_Use(dir_server+"base1")
      goto (glob_passw)
      G_RLock("forever")
      replace fio with " ", password with " "
      UNLOCK
      close databases
    endif
  endif
endif
close databases
memowrit("tmp.dbf","1")
delete file tmp.dbf
return NIL

*****
Function init_pass()
Public glob_passw := 0, gmenu_passw := {}, ;
       gmenu_tipdostup := {{"администратор",0},{"оператор",1}}
aadd(gmenu_passw, {"fio","C",20,0,NIL,NIL,space(20),NIL,;
                   "Ф.И.О.",NIL})
aadd(gmenu_passw, {"tip_dostup","N",1,0,NIL,;
                   {|x|menu_reader(x,gmenu_tipdostup,A__MENUVERT)},;
                   1,{|x|inieditspr(A__MENUVERT,gmenu_tipdostup,x)},;
                   "Тип доступа",NIL})
aadd(gmenu_passw, {"password","C",10,0,"@!",NIL,;
                   space(10),NIL,;
                   "Пароль",NIL})
if !file(dir_server+"base1.dbf")
  adbf := aclone(gmenu_passw)
  aeval(adbf, {|x,i| asize(adbf[i],4), adbf[i,2] := "C" })
  dbcreate(dir_server+"base1", adbf)
  close databases
endif
return NIL

*****
Function input_fio(r,c)
Local t_mas := {}, fio_mas := {}, buf, ret_m := NIL, i
G_Use(dir_server+"base1",,,.t.)
dbeval({|| aadd(t_mas, crypt(FIELD->fio,gpasskod)+;
                       crypt(FIELD->tip_dostup,gpasskod)+;
                       crypt(FIELD->password,gpasskod)+;
                       str(recno(),3)) },;
       {|| !empty(FIELD->fio) } ;
      )
use
if len(t_mas) == 0
  func_error(4,"База данных паролей пуста.")
  return NIL
endif
save screen to buf
mywait()
asort(t_mas)
aeval(t_mas, {|x,i| aadd(fio_mas,left(t_mas[i],20)) })
if (rb := r + 1 + len(t_mas)) > 22
  rb := 22
endif
if c+33 > 79
  c := 26
endif
status_key("^<Esc>^ - выход,  ^<Enter>^ - подтверждение ввода")
i := ascan(t_mas, {|x| int(val(substr(x,32))) == glob_passw } )
if (i := popup(r,c,rb,c+31,fio_mas,i,0,.t.)) > 0
  ret_m := array(3)
  ret_m[1] := fio_mas[i]
  ret_m[2] := int(val(substr(t_mas[i],21,1)))
  ret_m[3] := substr(t_mas[i],22,10)
  glob_passw := int(val(substr(t_mas[i],32)))
endif
restore screen from buf
return ret_m
