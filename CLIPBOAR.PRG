* Функции для работы с CLIPBOARD
#include 'function.ch'
#include 'inkey.ch'

Static clipboard

** функция установки - вызывается в функции first()
PROCEDURE clipboard()

  clipboard := StackNew()
  // поместить содержимое активного GET'а в clipboard
  SetKey( K_CTRL_F4, {|p, l, v| put_clpbrd(p, l, v)} )
  // вернуть содержимое "верхнего" элемента, помещенного в clipboard
  SetKey( K_SH_F4, {|p, l, v| get_clpbrd(p, l, v)} )
  // включить режим работы с clipboard через меню
  SetKey( K_ALT_F4, {|p, l, v| menu_clpbrd(p, l, v)} )
  return NIL

** занести строку в стек
Static Function put_clpbrd()
  Local i, s, name_var, type_var, val_var

  if len(GetList) > 0 //проверяем наличие активной Get системы
    name_var := readvar()         // наименование переменной
    val_var  := &name_var         // значение переменной
    type_var := valtype(val_var)  // тип переменной
    if !empty(name_var) .and. !empty(val_var)
      do case
        case type_var == 'C'
          s := alltrim(val_var)
        case type_var == 'D'
          s := full_date(val_var)
        case type_var == 'N'
          s := lstr(val_var)
      endcase
      if s != NIL
        i := ascan(clipboard, {|x| x[1] == s})
        StackPush( clipboard, {s, type_var} )  // добавить в конец
        if i > 0   // если уже была такая строка где-то в середине - удаляем
          Del_Array(clipboard, i)
        endif
        do while len(clipboard) > 10 // оставим не более 10 элементов
          Del_Array(clipboard, 1)
        enddo
        music_m('OK')
      endif
    endif
  endif
  RETURN NIL

*

***** получить "верхний" элемент стека (ltip=1) или n_poz элемент (ltip=2)
Static Function get_clpbrd(_1,_2,_3,ltip,n_poz)
DEFAULT ltip TO 1, n_poz TO 1
if len(GetList) > 0 // проверяем наличие активной Get системы
  if ltip == 1
    if StackIsEmpty( clipboard )
      music_m("ERROR")
    else
      music_m("OK")
      keyboard StackGetTop(clipboard)[1]  // "верхний" элемент стека
    endif
  else
    music_m("OK")
    keyboard clipboard[n_poz,1]
  endif
endif
RETURN NIL

*

***** начать работу с меню clipboard
Static Function menu_clpbrd()
Local i, j := 1, k, l, buf, mas, arr, nKey, n_poz, arr_keys, tmp_gets
if len(GetList) > 0 .and. !StackIsEmpty( clipboard )
  buf := savescreen()
  arr_keys := my_savekey()  // запретить все ф-ии по прерываниям
  SAVE GETS TO tmp_gets     // сохранить все активные GET'ы
  arr := {} // занесем в arr массив clipboard в обратном порядке
  for i := len(clipboard) to 1 step -1
    aadd(arr, aclone(clipboard[i]) )
  next
  box_shadow(11,2,22,77,"N/W","Стек буфера клавиатуры","B/W")
  status_key("^<Esc>^ выход ^<Enter>^ выбор ^<Ctrl+Enter>^ ред-ие ^<Del>^ удалить ^<Ins>^ сделать 1-ым")
  do while len(arr) > 0
    mas := {}  // сделаем массив для отображения в popup
    for i := 1 to len(arr)
      aadd(mas, left(arr[i,1],72) )
    next
    SETCURSOR(0)  // убрать курсор
    k := my_achoice(12,4,21,75,mas,j,1,"N/W,GR+/R","func_clpbrd")
    if k == NIL
      exit
    elseif (nKey := lastkey()) == K_ENTER
      if f_Esc_Enter("смены поля ввода")
        n_poz := k[1]
      endif
      exit
    elseif nKey == K_CTRL_RET
      j := k[1]
      Private mvar := padr(arr[j,1],500)
      @ 11+j,4 get mvar pict "@S72"
      myread()
      if lastkey() != K_ESC .and. !empty(mvar)
        arr[j,1] := alltrim(mvar)
      endif
    elseif nKey == K_DEL
      Del_Array(arr,k[1])        // удалить данный элемент
      j := k[1] - 1
    elseif nKey == K_INS
      mas := aclone(arr[k[1]])   // запомнить данный элемент
      Del_Array(arr,k[1])        // удалить данный элемент
      Ins_Array(arr,1,mas)       // теперь сделать его 1-ым в массиве
      j := 1
    endif
  enddo
  RESTORE GETS FROM tmp_gets
  my_restkey(arr_keys)
  restscreen(buf)
  setcursor()    // поставить курсор
  clipboard := {}   // сделаем clipboard = arr наоборот
  for i := len(arr) to 1 step -1
    aadd(clipboard, {alltrim(arr[i,1]),arr[i,2]} )
  next
  if n_poz != NIL  // была нажата клавиша Enter
    n_poz := len(arr)+1-n_poz  // т.к. массив был наоборот, изменим индекс
    get_clpbrd(,,,2,n_poz)
  endif
endif
return NIL

*****
Function func_clpbrd(k,nKey)
Local fl1 := .f., fl2 := .f.
if equalany(nKey,K_CTRL_RET,K_INS,K_DEL)
  fl1 := fl2 := .t.
endif
return {fl1,fl2}
