#include "function.ch"

***** аналог макроса LSTR (для использования в шаблонах)
Function FLSTR(n,l,d)
DEFAULT l TO 19, d TO 0
return ltrim(str(n,l,d))
