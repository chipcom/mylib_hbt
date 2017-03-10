Static ss := 16  // система счисления - шестнадцатеричная

***** преобразовать два числа (от 0 до 15) в один символ
Function N2_TO_C(a,b)
return chr( cton( ntoc(a,ss) + ntoc(b,ss), ss ) )

***** преобразовать символ в два числа (от 0 до 15)
Function C_TO_N2(c)
Local a := asc(c)
c := ntoc( a, ss )
if a < ss  // если число на входе < 15 (т.е. первое из двух чисел 0)
  c := "0"+c
endif
return { cton(substr(c,1,1),ss), cton(substr(c,2,1),ss) }
