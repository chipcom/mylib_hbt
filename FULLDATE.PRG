***** �-�� dtoc � ����� ����� (10 ������)
Function full_date(_d)
Local _s, old_set := __SetCentury( "on" )
_s := iif(empty(_d), space(10), dtoc(_d))
__SetCentury( old_set )
return _s

***** �-�� dtoc � ᮪�饭�� ����� (8 ������)
Function date_8(_d)
Local _s, old_set := __SetCentury( "off" )
_s := iif(empty(_d), space(8), dtoc(_d))
__SetCentury( old_set )
return _s
