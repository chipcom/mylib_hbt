***** составить ключ для шифрования (расшифровки)
Function ret_gpasskod()
Local i, s := ""
for i := 91 to 160 step 4
  s += chr(i)
next
for i := 120 to 91 step -2
  s += chr(i)
next
return s
