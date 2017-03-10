***** Очистить буфер клавиатуры (5 попыток)
Function clear_keyboard()
Local i
for i := 1 to 5
  keyboard ""
  inkey(0.1)
next
return NIL
