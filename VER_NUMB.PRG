***** функция проверки строки на то, чтобы все ее символы были цифровыми
Function ver_number(s)
if empty(s) ; return .f. ; endif   // если строка пустая - вернуть .f.
return EMPTY(CHARREPL("0123456789", s, SPACE(10)))
