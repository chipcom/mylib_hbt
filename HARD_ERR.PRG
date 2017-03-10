#include "inkey.ch"
#include "function.ch"

*****
Function hard_err(p)
// k = 1 - проверка диска на наличие временного файла hard_err.meh
//         и, если он есть, вывод текста о необходимости переиндексирования;
//         создание временного файла hard_err.meh "CREATE"
// k = 2 - удаление временного файла hard_err.meh "DELETE"
Local k := 3, arr := {}
if valtype(p) == "N"
  k := p
elseif valtype(p) == "C"
  p := upper(p)
  do case
    case p == "CREATE"
      k := 1
    case p == "DELETE"
      k := 2
  endcase
endif
do case
  case k == 1
    if file("hard_err.meh")
      FillScreen(p_char_screen,p_color_screen)
      aadd(arr,"1. Вполне вероятно, что Вы запустили ВТОРУЮ копию задачи!")
      aadd(arr,"В этом случае выйдите из задачи.")
      aadd(arr,". . .")
      aadd(arr,"2. Последний раз при выходе из задачи был сбой по питанию.")
      aadd(arr,"В этом случае Вам настоятельно рекомендуется выполнить")
      aadd(arr,'режим "Переиндексирование", т.к. вполне вероятно, что')
      aadd(arr,"некоторые индексные файлы были испорчены или разрушены.")
      keyboard ""
      f_message(arr,,color1,color8,,,color1)
      if f_alert({padc("Выберите действие",60,".")},;
               {" Выход из задачи "," Продолжение работы "},;
               1,"W+/N","N+/N",20,,"W+/N,N/BG" ) != 2
        SET COLOR TO
        SET CURSOR ON
        CLS
        QUIT
      endif
      FillScreen(p_char_screen,p_color_screen)
    endif
    strfile("hard_error","hard_err.meh")
  case k == 2
    delete file hard_err.meh
endcase
return NIL
