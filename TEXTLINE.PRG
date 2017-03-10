#include "function.ch"

***** аналог ф-ии MEMOLINE
Function textline(s,n)
* s - текст (содержимое файла, строки разделены через EOS)
* n - номер строки, которую необходимо "вынуть" из s
s := token(s,chr(10),n)
return charrem(chr(13),s)  // удалить из строки chr(13)

***** аналог ф-ии MLCOUNT
Function textcount(s)
* s - текст (содержимое файла, строки разделены через EOS)
return numtoken(s,chr(10))
