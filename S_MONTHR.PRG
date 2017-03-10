#include "function.ch"

***** месяц в родительном падеже
function month_r(md)
Local mas := {"января","февраля","марта","апреля","мая","июня",;
              "июля","августа","сентября","октября","ноября","декабря"}
if valtype(md) == "C"
  md := ctod(md)
endif
if valtype(md) == "D"
  return mas[month(md)]
endif
return ""
