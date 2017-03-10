#include "function.ch"
#include "edit_spr.ch"
#include "inkey.ch"
#include "getexit.ch"

Static i_read := 0
Static s_a := 0
Static a_old := {}

***** процедура READ с некоторыми "удобствами"
Function myread(arr,/*@*/nPos,k)
LOCAL i, ko, kn, fl, a_new := {}, bSaveHandler, count_edit := 0,;
      i_a, fl_arr := (arr != NIL .and. valtype(arr) == "A")
DEFAULT nPos TO 0, k TO 1
if fl_arr
  aeval(arr, {|x,i| arr[i] := upper(x)})
  if ascan(arr, {|x| "CONFIRM" $ x }) > 0 ;  set confirm on  ;  endif
  if ascan(arr, {|x| "BELL"    $ x }) > 0 ;  set bell on     ;  endif
  if ascan(arr, {|x| "ESCAPE"  $ x }) > 0 ;  set escape off  ;  endif
  if ascan(arr, {|x| "UP"   $ x }) > 0 ; set key K_UP   to clear_gets ; endif
  if ascan(arr, {|x| "DOWN" $ x }) > 0 ; set key K_DOWN to clear_gets ; endif
endif
SETCURSOR()
if k == 1 // если "myread" в цикле, то только для 1-го раза запоминаем Getlist
  if i_read == 0 // для первого "myread" (в псевдорекурсии)
    s_a := 0
    a_old := {}  // очистим массив
  endif
  ++s_a
  do while len(a_old) < s_a
    aadd(a_old,{})
  enddo
  aeval(Getlist, {|oGet| aadd(a_old[s_a],oGet:varGet()) })
endif
i_a := s_a
++i_read // кол-во запущенных ReadModal (через псевдорекурсию)
ReadModal(GetList,@nPos) // запуск обработчика GETSYS, возврат текущей позиции
--i_read //
aeval(Getlist, {|oGet| aadd(a_new,oGet:varGet()) })
ko := len(a_old[i_a])
kn := len(a_new)
//
bSaveHandler := ERRORBLOCK( {|x| BREAK(x)} )
BEGIN SEQUENCE
  for i := 1 to max(ko,kn)
    if i <= ko .and. i <= kn .and. valtype(a_old[i_a,i]) == valtype(a_new[i])
      fl := !(a_old[i_a,i] == a_new[i])
    else
      fl := .t.
    endif
    if fl
      count_edit++
    endif
  next
RECOVER USING error
  //
END
ERRORBLOCK(bSaveHandler)
GetList := {} // очистим список GET-переменных
SETCURSOR(0)
if fl_arr
  if ascan(arr, {|x| "DOWN" $ x }) > 0
    set key K_DOWN to
    if lastkey() == K_DOWN
      keyboard chr(K_DOWN)
    endif
  endif
  if ascan(arr, {|x| "UP" $ x }) > 0
    set key K_UP to
    if lastkey() == K_UP
      keyboard chr(K_UP)
    endif
  endif
  if ascan(arr, {|x| "ESCAPE"  $ x }) > 0 ;  set escape on   ;  endif
  if ascan(arr, {|x| "BELL"    $ x }) > 0 ;  set bell off    ;  endif
  if ascan(arr, {|x| "CONFIRM" $ x }) > 0 ;  set confirm off ;  endif
endif
return count_edit
