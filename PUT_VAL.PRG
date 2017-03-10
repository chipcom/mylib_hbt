#include "function.ch"

***** преобразовать число в строку; если оно == 0, то вернуть пробелы
Function put_val(v,l,d,c)
Local s
DEFAULT l TO 10, d TO 0, c TO " "
s := lstr(v,19,d)
if empty(val(s))
  s := replicate(c,l)
else
  if len(s) > l
    s := replicate("*",l)
  else
    s := padleft(s,l,c)
  endif
endif
return s

***** заменить последние два нуля в дес.знаках на пробелы (копейки)
Function put_kop(v,l)
Local s := lstr(v,20,2)
if len(s) <= l
  s := padl(s,l)
  if right(s,3) == ".00"
    s := left(s,l-3)+space(3)
  endif
else  // если получаемая строка в длину больше необходимой
  if right(s,3) == ".00"
    s := beforatnum(".",s)  // то выводим без копеек
    s := padl(s,l)
  else
    s := padr(s,l)
  endif
endif
return s

***** если = 0, то вывести пробелы
Function put_kopE(v,l)
Local s := put_kop(v,l)
if alltrim(s) == "0"
  s := space(l)
endif
return s

***** заменить последние два нуля в дес.знаках на пробелы (копейки)
Function lput_kop(v,fl)      // и убрать пробелы слева
Local s := put_kop(v,20)
DEFAULT fl TO .f.
if fl
  s := rtrim(s)  // убрать пробелы справа
endif
return ltrim(s)

***** преобразовать дату в строку; если она пустая, то вернуть пробелы
Function put_date(d)
Local k := if(__SetCentury(), 10, 8)
return if(empty(d), space(k), dtoc(d))

***** уместить число n в l символов, max кол-во дес.знаков - d
Function umest_val(n,l,d,yes_zero,yes_plus)
Local s, k
DEFAULT l TO 10, d TO 0, yes_zero TO .f., yes_plus TO .f.
s := lstr(n,19,d)
if empty(val(s))
  s := padl(iif(yes_zero, "0", ""), l)
else
  if d > 0
    do while (c := right(s,1)) == "0" .or. c == "."
      s := substr(s,1,len(s)-1)
      if c == "." ; exit ; endif
    enddo
  endif
  if n > 0 .and. yes_plus
    s := "+"+s
  endif
  if len(s) > l
    if "." $ s
      if (k := at(".",s)) > l+1
        s := replicate("*",l)
      else
        s := substr(s,1,l)
        if right(s,1) == "."
          s := substr(s,1,l-1)
        endif
      endif
    else
      s := replicate("*",l)
    endif
  else
    s := padleft(s,l)
  endif
endif
return padleft(s,l)

***** уместить сумму n в l символов (копейки будут корректно выглядеть)
Function umest_kop(n,l,d)
Local s
DEFAULT d TO 2
s := umest_val(n,l,d)
if substr(s,l-1,1) == "." ;     // если только один знак после запятой
     .and. left(s,1) == " "  // и в длину еще есть место
  s := substr(s,2)+"0"    // то дополнить дробную часть вторым знаком (копейки)
endif
return s
