***** ф-ия dtoc с полным годом (10 знаков)
Function full_date(_d)
Local _s, old_set := __SetCentury( "on" )
_s := iif(empty(_d), space(10), dtoc(_d))
__SetCentury( old_set )
return _s

***** ф-ия dtoc с сокращенным годом (8 знаков)
Function date_8(_d)
Local _s, old_set := __SetCentury( "off" )
_s := iif(empty(_d), space(8), dtoc(_d))
__SetCentury( old_set )
return _s
