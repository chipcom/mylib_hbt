***** удалить символ "c" в конце строки "s" (при его наличии)
Function DelEndSymb(s,c)
if right((s := alltrim(s)),1) == c
  s := substr(s,1,len(s)-1)
endif
return s
