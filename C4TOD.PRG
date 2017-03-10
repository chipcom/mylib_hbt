// Операции для хранения даты в "скрученном" формате (С4)
// Пример: исходная дата     - 21.08.1990
//         результат DTOS()  - "19900821"
//         результат DTOC4() - chr(19)+chr(90)+chr(08)+chr(21) = "Z"
// Примечание: по данному полю индексация проходит аналогично DTOS()

*****
Function c4tod(s)
Local d, m, y
if s == space(4) ; return ctod("") ; endif
d := strzero(asc(substr(s,4,1)), 2)
m := strzero(asc(substr(s,3,1)), 2)
y := strzero(asc(substr(s,1,1)), 2) + strzero(asc(substr(s,2,1)), 2)
set date german
return ctod(d+"."+m+"."+y)

*****
Function dtoc4(d)
Local i, s, s1 := ""
if empty(d) ; return space(4) ; endif
s := dtos(d)
for i := 1 to 4
  s1 += chr(val(substr(s,i*2-1,2)))
next
return s1
